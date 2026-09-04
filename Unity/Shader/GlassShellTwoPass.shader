Shader "Ion/GlassShellTwoPass"
{
    Properties
    {
        [Header(Glass)]
        Input_Color             ("玻璃颜色",            Color)      = (0.55, 0.80, 1.00, 1)
        Input_Alpha             ("基础透明度",          Range(0,1)) = 0.10
        Input_InnerAlpha        ("内壁透明度倍率",      Range(0,2)) = 0.60

        [Space(20)]
        Input_FresnelIntensity  ("边缘强度",            Range(0,2)) = 0.90
        Input_FresnelPower      ("边缘收窄",            Range(0.5,8)) = 3.0
        Input_Dispersion        ("色散火彩",            Range(0,1)) = 0.0
        Input_ThinFilm          ("薄膜虹彩",            Range(0,1)) = 0.0

        [Space(20)]
        Input_Distortion        ("透镜扭曲",            Range(0,1)) = 1.0

        [Space(20)]
        Input_Smoothness        ("光滑度",              Range(0,1)) = 0.85
        Input_SpecIntensity     ("高光强度",            Range(0,4)) = 1.0
        Input_ReflectIntensity  ("环境反射强度",        Range(0,2)) = 0.35
    }

    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
            "RenderType" = "Transparent"
            "IgnoreProjector" = "True"
            "ForceNoShadowCasting" = "True"
        }

        // 抓屏，给透镜折射用。带名字表示每帧只抓一次、多个玻璃共享。
        // 注意抓到的只有本物体之前绘制的内容，所以玻璃看不到自己的内壁和其他半透明物体。
        GrabPass { "IonArg_GlassGrabTex" }

        // 内外壁共用这一份代码，靠片元的 SV_IsFrontFace 区分正背面，
        // 所以下面两个 Pass 只差 Cull 方向。
        HLSLINCLUDE
        // HLSLPROGRAM 不像 CGPROGRAM 会自动包含 HLSLSupport / UnityShaderVariables，
        // 这里靠 UnityCG.cginc 的包含链补齐（UnityCG -> UnityShaderVariables -> HLSLSupport）。
        #include "UnityCG.cginc"
        #include "Lighting.cginc"

        float4 Input_Color;
        float  Input_Alpha;
        float  Input_InnerAlpha;
        float  Input_FresnelIntensity;
        float  Input_FresnelPower;
        float  Input_Dispersion;
        float  Input_ThinFilm;
        float  Input_Distortion;
        float  Input_Smoothness;
        float  Input_SpecIntensity;
        float  Input_ReflectIntensity;

        sampler2D IonArg_GlassGrabTex;

        // 玻璃折射率。物理常数，不作为参数暴露：1.0 等于关闭透镜，1.5 就是普通玻璃。
        #define IonDef_GlassIor 1.5

        // 光谱采样次数。只拆 R/G/B 三份的话，通道之间会漏出品红和青色，
        // 看起来像 RGB 错位的故障效果；沿光谱多采几次再按波长权重累加，
        // 才会出现宝石那种连续的火彩。
        #define IonDef_SpectrumSteps 6

        // 色散强度为 1 时折射率上下各偏多少。真实宝石很小（钻石约 2%），
        // 这里放大到 15%，否则实时下几乎看不出火彩。
        #define IonDef_DispersionSpread 0.3

        // 表面薄膜的折射率，取水膜的 1.33。
        #define IonDef_FilmIor 1.33
        // 基准膜厚，单位纳米。420nm 差不多正好跨一个干涉级次，
        // 再厚色相震荡就会快过像素采样能力，出现摩尔纹和闪烁。
        #define IonDef_FilmThicknessNm 420.0
        // 顶薄底厚的厚度起伏比例，模拟重力让膜液下沉。
        #define IonDef_FilmVariation 0.55

        struct IonAttr_Glass
        {
            float4 PosOs : POSITION;
            float3 NrmOs : NORMAL;
            UNITY_VERTEX_INPUT_INSTANCE_ID
        };

        struct IonVary_Glass
        {
            float4 PosCs     : SV_POSITION;
            float3 NrmWs     : TEXCOORD0;
            float3 PosWs     : TEXCOORD1;
            float  LensDist  : TEXCOORD2;
            float  FilmThick : TEXCOORD3;
            UNITY_VERTEX_OUTPUT_STEREO
        };

        IonVary_Glass IonVert_Glass(IonAttr_Glass attr)
        {
            IonVary_Glass vary;
            UNITY_SETUP_INSTANCE_ID(attr);
            UNITY_INITIALIZE_OUTPUT(IonVary_Glass, vary);
            UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(vary);

            vary.PosCs = UnityObjectToClipPos(attr.PosOs);
            vary.PosWs = mul(unity_ObjectToWorld, attr.PosOs).xyz;
            vary.NrmWs = UnityObjectToWorldNormal(attr.NrmOs);

            // 透镜光线在玻璃后要走多远：取轴心到该顶点的世界距离，约等于这个壳的半径。
            // 物体越大、缩放越大，扭曲自然越强，所以不需要"折射强度"参数。
            vary.LensDist = length(mul((float3x3)unity_ObjectToWorld, attr.PosOs.xyz));

            // 薄膜厚度。真实泡泡受重力影响顶薄底厚，用物体空间的归一化高度做梯度：
            // 它跟着物体走，不会因为角色移动而游移，也与物体缩放无关。
            half heightFactor = attr.PosOs.y / max(length(attr.PosOs.xyz), 1e-4);
            vary.FilmThick = IonDef_FilmThicknessNm * (1.0 + heightFactor * IonDef_FilmVariation);
            return vary;
        }

        // 环境图采样。用显式 LOD，所以放在分支里也不会因为缺少屏幕导数出问题。
        half3 IonEnvRgb_Glass(half3 dirWs, half lod)
        {
            half4 raw = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, dirWs, lod);
            return DecodeHDR(raw, unity_SpecCube0_HDR);
        }

        // 透镜折射后的背景。做法是沿折射方向往前走一段，再把落点投影回屏幕取抓屏，
        // 透视、FOV、单眼渲染全部由 VP 矩阵和 ComputeGrabScreenPos 自己处理，
        // 所以不需要任何经验系数；折射率等于 1 时落点就在原视线上，偏移自动为 0。
        half3 IonLensBg_Glass(half3 posWs, half3 refrWs, half march)
        {
            float4 posCs   = mul(UNITY_MATRIX_VP, float4(posWs + refrWs * march, 1.0));
            float4 grabPos = ComputeGrabScreenPos(posCs);
            // 显式 LOD，这样放在分支里也不依赖屏幕导数（抓屏本来也没有 mip）
            float2 grabUv  = grabPos.xy / max(grabPos.w, 1e-5);
            return tex2Dlod(IonArg_GlassGrabTex, float4(grabUv, 0, 0)).rgb;
        }

        // 波长到 RGB 的粗略响应。t = 0 是红端，t = 1 是紫端。
        // 三条钟形曲线故意留出重叠，中间才会过渡出黄和青；
        // 不重叠就退化成红绿蓝三条硬边，那就是廉价的 RGB 错位感。
        half3 IonSpectrumWeight_Glass(half t)
        {
            return saturate(1.0 - abs(t - half3(0.0, 0.5, 1.0)) * 1.4);
        }

        // 宝石火彩。折射率随波长变化（长波折射率低、短波高），每个波长的折射方向
        // 就不一样，沿光谱逐个采样再按权重累加，出射时便分离成彩色。
        // 这是宝石色散和"轮廓彩边"的本质区别：它长在折射路径里，出现在石身内部。
        half3 IonLensFire_Glass(half3 posWs, half3 viewWs, half3 nrmLens, half march, half dispersion)
        {
            half3 sumRgb = 0.0;
            half3 sumW   = 0.0;

            [unroll]
            for (int s = 0; s < IonDef_SpectrumSteps; s++)
            {
                half  t   = (s + 0.5) / IonDef_SpectrumSteps;
                half  ior = IonDef_GlassIor * (1.0 + (t - 0.5) * dispersion * IonDef_DispersionSpread);
                half3 dir = refract(-viewWs, nrmLens, 1.0 / ior);

                half3 w = IonSpectrumWeight_Glass(t);
                sumRgb += IonLensBg_Glass(posWs, dir, march) * w;
                sumW   += w;
            }
            return sumRgb / max(sumW, 1e-4);
        }

        // 薄膜干涉（泡泡虹彩）。光在膜的前后两个界面各反射一次，两束反射光的光程差
        // 与波长同量级时发生干涉，某些波长被增强、某些被抵消。
        // 这跟色散是两套物理：色散是折射角随波长变化，这里是反射光自己干涉，
        // 所以它作用在表面反射上，不需要知道物体背后有什么，也就不用采样抓屏。
        half3 IonThinFilm_Glass(half ndotv, half thicknessNm)
        {
            // 斯涅尔定律求膜内折射角。掠射时膜内路径变长，色相会随视角推移。
            half sinT2 = (1.0 - ndotv * ndotv) / (IonDef_FilmIor * IonDef_FilmIor);
            half cosT  = sqrt(saturate(1.0 - sinT2));

            // 光程差：在膜内往返一次的几何路径乘膜的折射率
            half opd = 2.0 * IonDef_FilmIor * thicknessNm * cosT;

            // RGB 各取一个代表波长（纳米）。干涉强度对每个波长是平滑的余弦，
            // 色相会自然循环，所以三点采样就够，不像色散必须沿光谱多采。
            half3 lambda = half3(650.0, 550.0, 450.0);

            // 减号来自第一个界面上的半波损失（π 相位翻转），
            // 少了它整条色相会偏移半个周期。
            // 结果均值 0.5，乘 2 归一化后均值为 1，开启虹彩不会整体变暗。
            return (0.5 - 0.5 * cos(6.2831853 * opd / lambda)) * 2.0;
        }

        // 输出预乘 Alpha（配合 Blend One OneMinusSrcAlpha），
        // 这样高光和环境反射是纯加光，不会被 Alpha 压暗。
        half4 IonFrag_Glass(IonVary_Glass vary, bool isFront : SV_IsFrontFace) : SV_Target
        {
            UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(vary);

            // 内壁看到的是背面，法线要翻过来才算得对
            half3 nrmGeoWs = normalize(vary.NrmWs);
            half3 nrmWs   = nrmGeoWs * (isFront ? 1.0 : -1.0);
            half3 viewWs  = normalize(_WorldSpaceCameraPos - vary.PosWs);
            half3 lightWs = normalize(_WorldSpaceLightPos0.xyz);
            half  ndotv   = saturate(dot(nrmWs, viewWs));

            half fresnel = pow(1.0 - ndotv, Input_FresnelPower);

            // 反射不分波长（介质的反射角与颜色无关），所以这里没有色散，
            // 色散全部集中在下面内壁 Pass 的折射路径上。
            half  envLod = (1.0 - Input_Smoothness) * 6.0;
            half3 reflWs = reflect(-viewWs, nrmWs);
            half3 envRgb = IonEnvRgb_Glass(reflWs, envLod) * Input_ReflectIntensity * lerp(0.15, 1.0, fresnel);

            half3 halfWs  = normalize(lightWs + viewWs);
            half  specPow = exp2(Input_Smoothness * 10.0) + 1.0;
            half3 specRgb = pow(saturate(dot(nrmWs, halfWs)), specPow) * Input_SpecIntensity * _LightColor0.rgb;

            // 薄膜干涉染色。干涉只发生在表面反射上，所以只乘到反射类的项，
            // 强度为 0 时是全白，等于不参与。
            half3 filmRgb = lerp(1.0, IonThinFilm_Glass(ndotv, vary.FilmThick), Input_ThinFilm);

            half3 baseRgb = Input_Color.rgb;
            half3 rgb = baseRgb * Input_Alpha                             // 本体（已预乘）
                      + baseRgb * fresnel * Input_FresnelIntensity * filmRgb  // 边缘
                      + baseRgb * envRgb * filmRgb                        // 环境反射
                      + specRgb * filmRgb;                                // 高光

            half alpha = saturate(Input_Alpha + fresnel * Input_FresnelIntensity);

            // 内壁整体压暗压透，跟外壁拉开层次
            half innerScale = isFront ? 1.0 : Input_InnerAlpha;
            rgb   *= innerScale;
            alpha *= innerScale;

            // 内壁 Pass 画在最底层，所以由它负责铺透镜折射后的背景。
            if (!isFront)
            {
                // 背面法线的横向分量和外壁是反的，直接折射会变成发散（凹透镜）。
                // 先沿视线把它镜像一次，得到与外壁同向、迎着相机的法线，凸壳才会汇聚放大。
                half3 nrmLens = nrmGeoWs - 2.0 * dot(nrmGeoWs, viewWs) * viewWs;

                // 扭曲强度直接缩放行进距离：为 0 时落点就是本片元自身，
                // 投影回屏幕正好是原位置，扭曲自然归零，背景照样透过来。
                half march = vary.LensDist * Input_Distortion;

                // 这是个 uniform 分支，整个 Draw 走同一条路径，
                // 关掉色散时只采一次抓屏，不会付光谱采样的代价。
                half3 bgRgb;
                if (Input_Dispersion > 0.0001)
                {
                    bgRgb = IonLensFire_Glass(vary.PosWs, viewWs, nrmLens, march, Input_Dispersion);
                }
                else
                {
                    half3 refrWs = refract(-viewWs, nrmLens, 1.0 / IonDef_GlassIor);
                    bgRgb = IonLensBg_Glass(vary.PosWs, refrWs, march);
                }

                // 玻璃颜色同时也是透光的染色
                rgb  += bgRgb * baseRgb * (1.0 - alpha);
                alpha = 1.0;   // 背景已经并进这一层，直接顶掉后面
            }

            return half4(rgb, alpha);
        }
        ENDHLSL

        // ===[内壁（背面）]===
        // 画在最底层，负责透镜折射后的背景 + 内壁自身的边缘和高光
        Pass
        {
            Name "INNER"
            Tags { "LightMode" = "ForwardBase" }
            Cull Front
            ZWrite Off
            ZTest LEqual
            Blend One OneMinusSrcAlpha

            HLSLPROGRAM
            #pragma vertex   IonVert_Glass
            #pragma fragment IonFrag_Glass
            #pragma target 3.0
            #pragma multi_compile_instancing
            ENDHLSL
        }

        // ===[外壁（正面）]===
        // 叠在内壁上面，只负责表面：环境反射、高光、菲涅尔彩边
        Pass
        {
            Name "OUTER"
            Tags { "LightMode" = "ForwardBase" }
            Cull Back
            ZWrite Off
            ZTest LEqual
            Blend One OneMinusSrcAlpha

            HLSLPROGRAM
            #pragma vertex   IonVert_Glass
            #pragma fragment IonFrag_Glass
            #pragma target 3.0
            #pragma multi_compile_instancing
            ENDHLSL
        }
    }
    FallBack Off
}
