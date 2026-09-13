Shader "Ion/DecalSimpleTopDown"
{
    Properties
    {
        _MainTex ("印花", 2D) = "white" {}
        _Color ("颜色", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }

        //印花可以用于360度星空投影仪。
        //-------------------------------------------------------------------
        // 代理几何 = 场景里挂这个材质的 Cube
        // - Frag 仍然只跑在「Cube 三角形盖住的屏幕像素」上（没有无网格开像素）
        // - Cube 自己几乎不当实体：不写深度、总通过深度测试
        // - 真正「被印」的是深度缓冲里已经存在的表面（地板等）
        //-------------------------------------------------------------------

        // Cull Off  
        ZWrite Off
        Cull Front
        ZTest Always
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;

            // 场景画完后留下的深度图：每个屏幕像素「最近不透明表面」有多远
            sampler2D _CameraDepthTexture;

            struct appdata
            {
                float4 vertex : POSITION; // Cube 顶点（代理网格）
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 screenPos : TEXCOORD0;
                // 观察空间：从相机指向「Cube 表面这一点」的位置/射线信息
                float3 viewRay : TEXCOORD1;
            };

            v2f vert(appdata v)
            {
                v2f o;

                // 【有网格】把 Cube 顶点投到裁剪空间 → 光栅化后这些像素才会进 frag
                o.pos = UnityObjectToClipPos(v.vertex);

                // 当前 Cube 片元对应的屏幕坐标（用来采深度图）
                o.screenPos = ComputeScreenPos(o.pos);

                // Cube 顶点在「观察空间」的位置（相机在原点，前方 -Z）
                // 片元里会用它表示：这一屏幕像素对应的视线方向
                o.viewRay = UnityObjectToViewPos(v.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                //===========================================================
                // 重要：此时 GPU 正在画的是「Cube 上的一个像素」
                // 下面用深度「算出」视线撞到的地板点，再用那个点去采贴图
                // 所以看起来像画在地板上，但 return 的颜色仍写在 Cube 这个像素上
                //===========================================================

                // 屏幕 UV（0~1）
                float2 uv = i.screenPos.xy / i.screenPos.w;

                //-----------------------------------------------------------
                // 1) 读深度：这个屏幕像素后面，场景里最近的表面有多远？
                //    （地板先画过且写了深度，这里读到的通常就是地板）
                //-----------------------------------------------------------
                float raw = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv);

                // 非线性深度 → 相机前方的线性距离（眼空间，正值）
                float eyeZ = LinearEyeDepth(raw);

                //-----------------------------------------------------------
                // 2) 沿视线走到「深度里的那个表面」
                //
                //    i.viewRay = 相机 → Cube 表面某点（观察空间）
                //    同一方向拉长/缩短，使走到距离 = eyeZ
                //    → viewPos 落在地板上（或手上），而不是停在 Cube 皮上
                //
                //    观察空间前方 z < 0，所以用 -viewRay.z
                //-----------------------------------------------------------
                float3 viewPos = i.viewRay * (eyeZ / -i.viewRay.z);

                //-----------------------------------------------------------
                // 3) 观察空间 → 世界坐标
                //    worldPos ≈ 地板（或其它写了深度的物体）上的一点
                //    注意：这只是「算出来的位置」，不是又跑了一次地板的 Frag
                //-----------------------------------------------------------
                float3 worldPos = mul(UNITY_MATRIX_I_V, float4(viewPos, 1)).xyz;

                //-----------------------------------------------------------
                // 4) 世界 → 印花盒（Cube）物体空间
                //    用来：① 判断该表面点是否在盒子投影范围内
                //         ② 用局部 XZ 当俯视 UV（从上往下印）
                //-----------------------------------------------------------
                float3 localPos = mul(unity_WorldToObject, float4(worldPos, 1)).xyz;

                // 表面点落在盒子外 → 这个 Cube 像素什么都不画
                if (any(abs(localPos) > 0.5))discard;

                // 俯视：把盒子局部 XZ 映射成 0~1 UV，采印花图
                float2 decalUV = localPos.xz + 0.5;
                decalUV = TRANSFORM_TEX(decalUV, _MainTex);
                fixed4 col = tex2D(_MainTex, decalUV) * _Color;

                // 靠近盒壁变淡，减少硬边
                float3 edge = saturate(1.0 - abs(localPos) * 2.0);
                col.a *= min(edge.x, min(edge.y, edge.z));
                // if(col.a!=0)col.a=1;

                //-----------------------------------------------------------
                // 5) return：颜色写入「当前 Cube 片元」
                //
                //    数据流小结：
                //      触发绘制 = Cube 网格（代理，有三角形）
                //      对齐位置 = 深度重建出的地板点（无新网格）
                //      最终画面 = Cube 像素上叠一层半透明色，眼睛以为钉在地板上
                //-----------------------------------------------------------
                return col;
            }
            ENDCG
        }
    }
}
