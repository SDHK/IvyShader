Shader "Ion/GlassShellEnvTwoPass"
{
    Properties
    {
        [Header(Glass)]
        Input_Color             ("玻璃颜色",            Color)      = (0.55, 0.80, 1.00, 1)
        Input_Alpha             ("基础透明度",          Range(0,1)) = 0.10
        Input_InnerAlpha        ("内壁透明度倍率",      Range(0,2)) = 0.60

        [Space(20)]
        [Header(Env Refract)]
        Input_EnvTex            ("360环境图 2:1",       2D)         = "black" {}
        Input_EnvBlend          ("环境图混合",          Range(0,1)) = 0.0
        Input_Ior               ("折射率",              Range(1,2.5)) = 1.50
        Input_RefractIntensity  ("折射叠加强度",        Range(0,2)) = 0.80

        [Space(20)]
        Input_FresnelIntensity  ("边缘强度",            Range(0,2)) = 0.90
        Input_FresnelPower      ("边缘收窄",            Range(0.5,8)) = 3.0
        Input_Dispersion        ("色散火彩",            Range(0,1)) = 0.0
        Input_ThinFilm          ("薄膜虹彩",            Range(0,1)) = 0.0

        [Space(20)]
        Input_Smoothness        ("光滑度",              Range(0,1)) = 0.85
        Input_SpecIntensity     ("高光强度",            Range(0,4)) = 1.0
        Input_ReflectIntensity  ("环境反射强度",        Range(0,2)) = 0.35
    }

    SubShader
    {
        // 排在 Transparent 之后一点，默认让这层玻璃盖在半透明的身体和衣服外面。
        // 如果玻璃应该在它们里面（比如包住身体的罩子），把 +10 去掉或改成负数。
        Tags
        {
            "Queue" = "Transparent"
            "RenderType" = "Transparent"
            "IgnoreProjector" = "True"
            "ForceNoShadowCasting" = "True"
        }

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

        sampler2D Input_EnvTex;
        float  Input_EnvBlend;
        float  Input_Ior;
        float  Input_RefractIntensity;

        float  Input_FresnelIntensity;
        float  Input_FresnelPower;
        float  Input_Dispersion;
        float  Input_ThinFilm;
        float  Input_Smoothness;
        float  Input_SpecIntensity;
        float  Input_ReflectIntensity;

        // 光谱采样次数。只拆 R/G/B 三份的话，通道之间会漏出品红和青色，
        // 看起来像 RGB 错位；沿光谱多采几次再按波长权重累加，才有连续的火彩。
        #define IonDef_SpectrumSteps 6

        // 色散为 1 时折射率上下各偏 15%。真实宝石只有约 2%（钻石 0.044），
        // 实时下必须放大才看得见。
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
            float  FilmThick : TEXCOORD2;
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

            // 薄膜厚度。真实泡泡受重力影响顶薄底厚，用物体空间的归一化高度做梯度：
            // 它跟着物体走，不会因为角色移动而游移，也与物体缩放无关。
            half heightFactor = attr.PosOs.y / max(length(attr.PosOs.xyz), 1e-4);
            vary.FilmThick = IonDef_FilmThicknessNm * (1.0 + heightFactor * IonDef_FilmVariation);
            return vary;
        }

        // 方向转 2:1 等距柱状（LatLong）UV。和 Unity 自带的 Skybox/Panoramic 用同一套约定，
        // 所以同一张 360 图拿去当天空盒、和在这里当环境图，朝向是一致的。
        half2 IonDirToLatLongUv_Glass(half3 dirWs)
        {
            half3 dir = normalize(dirWs);
            half  latitude  = acos(clamp(dir.y, -1.0, 1.0));
            half  longitude = atan2(dir.z, dir.x);
            return half2(0.5, 1.0) - half2(longitude * (0.5 / UNITY_PI), latitude * (1.0 / UNITY_PI));
        }

        // 世界反射探针。和 Standard 里金属的反射用的是同一个来源，
        // 所以什么贴图都不挂也能正常融入所在世界。
        half3 IonProbeRgb_Glass(half3 dirWs, half lod)
        {
            half4 probe = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, dirWs, lod);
            return DecodeHDR(probe, unity_SpecCube0_HDR);
        }

        // 自定义 360 图。全程显式 LOD，不依赖屏幕导数，
        // 所以等距柱状最常见的那道 ±180° 接缝（导数突变导致取到最低 mip）不会出现。
        half3 IonPanoRgb_Glass(half3 dirWs, half lod)
        {
            return tex2Dlod(Input_EnvTex, float4(IonDirToLatLongUv_Glass(dirWs), 0.0, lod)).rgb;
        }

        // 环境采样。混合为 0 是纯世界探针（默认），为 1 是纯自定义 360 图。
        // 两端各做了一个 uniform 分支，所以只用一边时只付一次采样。
        half3 IonEnvRgb_Glass(half3 dirWs, half lod)
        {
            if (Input_EnvBlend < 0.001) { return IonProbeRgb_Glass(dirWs, lod); }
            if (Input_EnvBlend > 0.999) { return IonPanoRgb_Glass(dirWs, lod); }

            return lerp(IonProbeRgb_Glass(dirWs, lod),
                        IonPanoRgb_Glass(dirWs, lod),
                        Input_EnvBlend);
        }

        // 波长到 RGB 的粗略响应。t = 0 是红端，t = 1 是紫端。
        // 三条钟形曲线故意留出重叠，中间才会过渡出黄和青；
        // 不重叠就退化成红绿蓝三条硬边，那就是廉价的 RGB 错位感。
        half3 IonSpectrumWeight_Glass(half t)
        {
            return saturate(1.0 - abs(t - half3(0.0, 0.5, 1.0)) * 1.4);
        }

        // 宝石火彩。折射率随波长变化（长波折射率低、短波高），每个波长折射到
        // 环境图上的位置就不一样，沿光谱累加便分离成彩色。
        // 和抓屏版唯一的区别是采样源换成了环境图，所以不再依赖绘制顺序。
        half3 IonEnvFire_Glass(half3 nrmWs, half3 viewWs, half lod, half dispersion)
        {
            half3 sumRgb = 0.0;
            half3 sumW   = 0.0;

            [unroll]
            for (int s = 0; s < IonDef_SpectrumSteps; s++)
            {
                half  t   = (s + 0.5) / IonDef_SpectrumSteps;
                half  ior = Input_Ior * (1.0 + (t - 0.5) * dispersion * IonDef_DispersionSpread);
                half3 dir = refract(-viewWs, nrmWs, 1.0 / max(ior, 1.0));

                half3 w = IonSpectrumWeight_Glass(t);
                sumRgb += IonEnvRgb_Glass(dir, lod) * w;
                sumW   += w;
            }
            return sumRgb / max(sumW, 1e-4);
        }

        // 薄膜干涉（泡泡虹彩）。光在膜的前后两个界面各反射一次，两束反射光的光程差
        // 与波长同量级时发生干涉，某些波长被增强、某些被抵消。
        // 这跟色散是两套物理：色散是折射角随波长变化，这里是反射光自己干涉。
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

            // 减号来自第一个界面上的半波损失（π 相位翻转），少了它整条色相会偏半个周期。
            // 结果均值 0.5，乘 2 归一化后均值为 1，开启虹彩不会整体变暗。
            return (0.5 - 0.5 * cos(6.2831853 * opd / lambda)) * 2.0;
        }

        // 输出预乘 Alpha（配合 Blend One OneMinusSrcAlpha），
        // 这样高光、环境反射和折射影像都是纯加光，不会被 Alpha 压暗。
        half4 IonFrag_Glass(IonVary_Glass vary, bool isFront : SV_IsFrontFace) : SV_Target
        {
            UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(vary);

            // 内壁看到的是背面，法线要翻过来才算得对
            half3 nrmWs   = normalize(vary.NrmWs) * (isFront ? 1.0 : -1.0);
            half3 viewWs  = normalize(_WorldSpaceCameraPos - vary.PosWs);
            half3 lightWs = normalize(_WorldSpaceLightPos0.xyz);
            half  ndotv   = saturate(dot(nrmWs, viewWs));

            half fresnel = pow(1.0 - ndotv, Input_FresnelPower);
            half envLod  = (1.0 - Input_Smoothness) * 6.0;

            // 反射不分波长（介质的反射角与颜色无关），所以这里没有色散
            half3 reflWs = reflect(-viewWs, nrmWs);
            half3 envRgb = IonEnvRgb_Glass(reflWs, envLod) * Input_ReflectIntensity * lerp(0.15, 1.0, fresnel);

            half3 halfWs  = normalize(lightWs + viewWs);
            half  specPow = exp2(Input_Smoothness * 10.0) + 1.0;
            half3 specRgb = pow(saturate(dot(nrmWs, halfWs)), specPow) * Input_SpecIntensity * _LightColor0.rgb;

            // 薄膜干涉只染表面反射，强度为 0 时返回全白，等于不参与
            half3 filmRgb = lerp(1.0, IonThinFilm_Glass(ndotv, vary.FilmThick), Input_ThinFilm);

            half3 baseRgb = Input_Color.rgb;
            half3 rgb = baseRgb * Input_Alpha                                  // 本体（已预乘）
                      + baseRgb * fresnel * Input_FresnelIntensity * filmRgb   // 边缘
                      + baseRgb * envRgb * filmRgb                             // 环境反射
                      + specRgb * filmRgb;                                     // 高光

            half alpha = saturate(Input_Alpha + fresnel * Input_FresnelIntensity);

            // 内壁整体压暗压透，跟外壁拉开层次
            half innerScale = isFront ? 1.0 : Input_InnerAlpha;
            rgb   *= innerScale;
            alpha *= innerScale;

            // 假折射放在外壁：光本来就是从正面进入玻璃的，这里的法线就是正确的入射面法线，
            // 不需要像抓屏版那样把背面法线沿视线镜像回来。放在正面也让单面网格照样有效果。
            if (isFront)
            {
                // uniform 分支，整个 Draw 走同一条路径，关掉色散时只采一次环境图
                half3 refrRgb;
                if (Input_Dispersion > 0.0001)
                {
                    refrRgb = IonEnvFire_Glass(nrmWs, viewWs, envLod, Input_Dispersion);
                }
                else
                {
                    half3 refrWs = refract(-viewWs, nrmWs, 1.0 / max(Input_Ior, 1.0));
                    refrRgb = IonEnvRgb_Glass(refrWs, envLod);
                }

                // 纯加光，不动 alpha。这样背后的真实物体照样按 (1-alpha) 透过来，
                // 折射影像只是叠在上面的一层，不会像抓屏版那样把后面的半透明顶掉。
                rgb += refrRgb * baseRgb * Input_RefractIntensity;
            }

            return half4(rgb, alpha);
        }
        ENDHLSL

        // ===[内壁（背面）]===
        // 先画，负责内壁自身的边缘、反射和高光，给外壁当底色
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
        // 叠在内壁上面，负责表面反射、高光、边缘，以及环境图的假折射叠加
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
