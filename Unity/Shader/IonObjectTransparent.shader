HLSLINCLUDE
#define IonShader
ENDHLSL

Shader "Ion/IonObjectTransparent"
{
    Properties
    {
        Input_MainTex            ("材质",                        2D)     = "white" {}
        Input_ColorMask          ("颜色遮罩",   2D)     = "white" {}
        Input_ColorMask1          ("颜色遮罩1",   2D)     = "white" {}
        Input_ColorMask2          ("颜色遮罩2",   2D)     = "white" {}
        Input_ColorMask3          ("颜色遮罩3",   2D)     = "white" {}
        Input_ColorMask4          ("颜色遮罩4",   2D)     = "white" {}

        [Space(20)]
        Input_Color1             ("主色",                   Color)  = (1.00, 1.00, 1.00, 1)
        Input_Color2             ("次色",                   Color)  = (0.80, 0.80, 0.80, 1)
        Input_Color3             ("附加色",                 Color)  = (0.60, 0.60, 0.60, 1)
        Input_Color4             ("高亮色",                 Color)  = (1.00, 1.00, 0.50, 1)
        
        [Space(20)]
        [Toggle] Input_BaseRampToggle  ("附加渐变色",                   Int) = 0
        Input_BaseRampDir        ("照射位置",                        Vector)     = (0, 1, 0, 0)
        Input_BaseRampColor1     ("深暗色",                     Color)      = (0.20, 0.20, 0.25, 1)
        Input_BaseRampColor2     ("偏暗色",                     Color)      = (0.60, 0.60, 0.60, 1)
        Input_BaseRampColor3     ("基准色",                     Color)      = (0.85, 0.85, 0.85, 1)
        Input_BaseRampColor4     ("偏亮色",                     Color)      = (1.00, 1.00, 1.00, 1)
        Input_BaseRampColor5     ("高亮色",                     Color)      = (1.00, 1.00, 1.00, 1)
        [Space(10)]
        Input_BaseRampThreshold1 ("阈值1",                      Range(0,1)) = 0.3
        Input_BaseRampThreshold2 ("阈值2",                      Range(0,1)) = 0.7
        Input_BaseRampThreshold3 ("阈值3",                      Range(0,1)) = 0.9
        Input_BaseRampThreshold4 ("阈值4",                      Range(0,1)) = 0.9
        [Space(10)]
        Input_BaseRampSoftness1  ("过渡1",                       Range(0,1)) = 0.5
        Input_BaseRampSoftness2  ("过渡2",                       Range(0,1)) = 0.5
        Input_BaseRampSoftness3  ("过渡3",                       Range(0,1)) = 0.5
        Input_BaseRampSoftness4  ("过渡4",                       Range(0,1)) = 0.5

        [Space(20)]
        Input_EmissiveIntensity  ("自发光",                       Range(0,1))  = 0.1
        Input_EmissiveTex        ("自发光遮罩",       2D)     = "white" {}

        [Space(20)]
        Input_LightInfluence      ("光照色影响",                        Range(0,1))  = 0.2
        Input_LightMax 	    ("光照最大值",                       Range(0,1))  = 1.0
        Input_LightMin 	    ("光照最小值",                       Range(0,1))  = 0
        Input_LightRampThreshold      ("光照阈值",                        Range(0,1)) = 0.5
        Input_LightRampSoftness       ("光照过渡",                         Range(0,1)) = 0.5

        [Space(20)]
        Input_RimIntensity       ("透光强度",                        Range(0,1))  = 0.25
        Input_RimPower           ("透光阈值",                            Range(0,1)) = 0.5
        [Space(20)]
        Input_BackRimIntensity   ("背光强度",                        Range(0,1))  = 0.25
        Input_BackRimPower       ("背光阈值",                            Range(0,1)) = 0.5
        
        [Header(Metal)]
        Input_Metallic              ("金属度",              Range(0,1)) = 0
        Input_MetalMask             ("金属遮罩 R",          2D) = "white" {}
        Input_MetalSpecularPower    ("高光锐度",            Range(0,1)) = 64
        Input_MetalSpecularIntensity("高光强度",            Range(0,10)) = 1
        Input_MetalReflectIntensity ("反射强度",            Range(0,10)) = 0.8
        Input_MetalRoughness        ("粗糙度",              Range(0,2)) = 0.2
        Input_MetalMatCap           ("MatCap 反射",         2D) = "gray" {}
        Input_MetalProbeInfluence   ("探针混合",            Range(0,1)) = 0.3
        Input_MetalDiffuseScale     ("漫反射比例",          Range(-2,2)) = 0.05

        [Space(20)]
        Input_OutlineColor              ("描边颜色",                           Color)  = (0, 0, 0, 1)
        Input_OutlineScale              ("描边大小",                           Float)  = 0

        [Space(20)]
        [Toggle] Input_StarNestToggle  ("星云启用",           Int)  = 0
        Input_StarNestlens 		("星云天空盒透镜",           Range(-2,2))  = 0

        [Space(20)]
        Input_Cutoff             ("透明度裁剪",                    Range(0,1)) = 0.5
    }

    //===[URP 管线]===================================================
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Opaque" "Queue" = "Geometry" }

        // ===[描边]===
        Pass
        {
            Name "OUTLINE"
            Tags { "LightMode" = "SRPDefaultUnlit" }
            Cull Front
            ZWrite On
            ZTest LEqual
            HLSLPROGRAM
            #define IonArg_Color Input_OutlineColor
            #define IonArg_Scale Input_OutlineScale
            #define Link_IonPassOutline
            #include "../IonCoreUnity.hlsl"
            ENDHLSL
        }

        // ===[简单渲染]===
        Pass
        {
            Tags { "LightMode" = "UniversalForward" }
            Cull Back
            ZWrite On
            ZTest LEqual
            Blend Off
            HLSLPROGRAM
            #define IonArg_MainTex    Input_MainTex
            #define IonArg_MainTex_ST Input_MainTex_ST
            #define Link_IonPassMain
            #include "../IonCoreUnity.hlsl"
            ENDHLSL
        }

        // ===[阴影投射]===
        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }
            Cull Back
            ZWrite On
            ZTest LEqual
            ColorMask 0
            HLSLPROGRAM
            #define Link_IonPassShadowCaster
            #include "../IonCoreUnity.hlsl"
            ENDHLSL
        }
    }

    //===[BRP 管线]===================================================
    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
        LOD 100

        // ===[描边]===
        Pass
        {
            Name "OUTLINE"
            Tags { "LightMode" = "Always" }
            Cull Front
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            HLSLPROGRAM
            #define IonArg_Color Input_OutlineColor
            #define IonArg_Scale Input_OutlineScale
            #define Link_IonPassOutline
            #include "../IonCoreUnity.hlsl"
            ENDHLSL
        }

        // ===[深度预写 Pass]===
        // 先把前面深度写入缓冲区，内部面 ZTest 时失败，不会错误覆盖外面。
        Pass
        {
            Name "DEPTH_PREPASS"
            Tags { "LightMode" = "Always" }
            Cull Back
            ZWrite On
            ColorMask 0
            HLSLPROGRAM
            #define IonArg_MainTex    Input_MainTex
            #define IonArg_MainTex_ST Input_MainTex_ST
            #define IonArg_Cutoff     Input_Cutoff
            #define Link_IonPassDepthPre
            #include "../IonCoreUnity.hlsl"
            ENDHLSL
        }

        // ===[主光照 ForwardBase]===
        Pass
        {
            Name "FORWARD"
            Tags { "LightMode" = "ForwardBase" }
             // Cull Front  

            ZWrite Off
            ZTest LEqual
            Offset 0, -1    // 固定单位偏移（不含斜率项），轻推深度避免 Z-Fighting
            Blend SrcAlpha OneMinusSrcAlpha

            HLSLPROGRAM

            #define IonArg_MainTex           Input_MainTex
            #define IonArg_MainTex_ST        Input_MainTex_ST

            #define IonArg_ColorMask         Input_ColorMask
            #define IonArg_ColorMask1         Input_ColorMask1
            #define IonArg_ColorMask2         Input_ColorMask2
            #define IonArg_ColorMask3         Input_ColorMask3
            #define IonArg_ColorMask4         Input_ColorMask4

            #define IonArg_Color1            Input_Color1
            #define IonArg_Color2            Input_Color2
            #define IonArg_Color3            Input_Color3
            #define IonArg_Color4            Input_Color4

            #define IonArg_LightInfluence   Input_LightInfluence
            #define IonArg_LightMax        Input_LightMax
            #define IonArg_LightMin        Input_LightMin

            #define IonArg_EmissiveTex        Input_EmissiveTex
            #define IonArg_EmissiveIntensity  Input_EmissiveIntensity

            #define IonArg_BaseRampToggle       Input_BaseRampToggle
            #define IonArg_StarNestEnable       Input_StarNestEnable
            #define IonArg_BaseRampDir        Input_BaseRampDir
            #define IonArg_BaseRampColor1     Input_BaseRampColor1
            #define IonArg_BaseRampColor2     Input_BaseRampColor2
            #define IonArg_BaseRampColor3     Input_BaseRampColor3
            #define IonArg_BaseRampColor4     Input_BaseRampColor4
            #define IonArg_BaseRampColor5     Input_BaseRampColor5

            #define IonArg_BaseRampThreshold1 Input_BaseRampThreshold1
            #define IonArg_BaseRampThreshold2 Input_BaseRampThreshold2
            #define IonArg_BaseRampThreshold3 Input_BaseRampThreshold3
            #define IonArg_BaseRampThreshold4 Input_BaseRampThreshold4

            #define IonArg_BaseRampSoftness1  Input_BaseRampSoftness1
            #define IonArg_BaseRampSoftness2  Input_BaseRampSoftness2
            #define IonArg_BaseRampSoftness3  Input_BaseRampSoftness3
            #define IonArg_BaseRampSoftness4  Input_BaseRampSoftness4

            #define IonArg_LightRampThreshold  Input_LightRampThreshold
            #define IonArg_LightRampSoftness   Input_LightRampSoftness

            #define IonArg_RimPower           Input_RimPower
            #define IonArg_RimIntensity       Input_RimIntensity

            #define IonArg_BackRimPower        Input_BackRimPower
            #define IonArg_BackRimIntensity    Input_BackRimIntensity

            #define IonArg_Metallic              Input_Metallic
            #define IonArg_MetalMask             Input_MetalMask
            #define IonArg_MetalSpecularPower    Input_MetalSpecularPower
            #define IonArg_MetalSpecularIntensity Input_MetalSpecularIntensity
            #define IonArg_MetalReflectIntensity Input_MetalReflectIntensity
            #define IonArg_MetalRoughness        Input_MetalRoughness
            #define IonArg_MetalMatCap           Input_MetalMatCap
            #define IonArg_MetalProbeInfluence   Input_MetalProbeInfluence
            #define IonArg_MetalDiffuseScale     Input_MetalDiffuseScale

            #define IonArg_StarNestToggle	   Input_StarNestToggle
            #define IonArg_StarNestlens	    Input_StarNestlens


            #define Link_IonPassMainSimple
            #include "../IonCoreUnity.hlsl"
            ENDHLSL
        }

        // ===[附加光照 ForwardAdd]===
        Pass
        {
            Name "ADDITIONAL"
            Tags { "LightMode" = "ForwardAdd" }
            Blend One One
            ZWrite Off
            HLSLPROGRAM

            #define IonArg_MainTex       Input_MainTex
            #define IonArg_MainTex_ST    Input_MainTex_ST
            #define IonArg_ColorMask     Input_ColorMask
            #define IonArg_Color1        Input_Color1
            #define IonArg_Color2        Input_Color2
            #define IonArg_Color3        Input_Color3
            #define IonArg_Color4        Input_Color4
            #define IonArg_EmissiveTex        Input_EmissiveTex
            #define IonArg_EmissiveIntensity  Input_EmissiveIntensity
            #define IonArg_LambertScale       Input_LambertScale
            #define IonArg_LambertOffset      Input_LambertOffset
            #define IonArg_LightRampThreshold      Input_LightRampThreshold
            #define IonArg_LightRampSoftness       Input_LightRampSoftness
            #define IonArg_BaseRampColor1     Input_BaseRampColor1
            #define IonArg_BaseRampThreshold1 Input_BaseRampThreshold1
            #define IonArg_BaseRampSoftness1  Input_BaseRampSoftness1
            #define IonArg_BaseRampColor2     Input_BaseRampColor2
            #define IonArg_BaseRampThreshold2 Input_BaseRampThreshold2
            #define IonArg_BaseRampSoftness2  Input_BaseRampSoftness2
            #define IonArg_BaseRampColor3     Input_BaseRampColor3
            #define IonArg_BaseRampThreshold3 Input_BaseRampThreshold3
            #define IonArg_BaseRampSoftness3  Input_BaseRampSoftness3
            #define IonArg_BaseRampColor4     Input_BaseRampColor4
            #define IonArg_BaseRampDir        Input_BaseRampDir
            #define IonArg_BaseRampToggle       Input_BaseRampToggle
            #define IonArg_BackRimColor        Input_BackRimColor
            #define IonArg_BackRimPower        Input_BackRimPower
            #define IonArg_BackRimIntensity    Input_BackRimIntensity
            #define Link_IonPassMainAdd
            #include "../IonCoreUnity.hlsl"
            ENDHLSL
        }

        // ===[阴影投射]===
        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }
            Cull Back
            ZWrite On
            ZTest LEqual
            ColorMask 0
            HLSLPROGRAM
            #define Link_IonPassShadowCaster
            #include "../IonCoreUnity.hlsl"
            ENDHLSL
        }
    }
    //FallBack "Diffuse"

}
