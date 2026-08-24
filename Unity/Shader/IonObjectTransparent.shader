HLSLINCLUDE
#define IonShader
ENDHLSL

Shader "Ion/IonObjectTransparent"
{
    Properties
    {
        Input_MainTex            ("材质",                        2D)     = "white" {}
        Input_SkinMask0          ("颜色遮罩0",   2D)     = "white" {}
        Input_SkinMask1          ("颜色遮罩1",   2D)     = "white" {}
        Input_SkinMask2          ("颜色遮罩2",   2D)     = "white" {}
        Input_SkinMask3          ("颜色遮罩3",   2D)     = "white" {}

        [Space(20)]
        Input_EmissiveIntensity  ("自发光",                       Range(0,1))  = 0.1
        Input_EmissiveTex        ("自发光遮罩",       2D)     = "white" {}

        
        //皮肤颜色
        [Space(20)]
        Input_SkinRgb01             ("主要亮",              Color)  = (1.00, 1.00, 1.00, 1)
        Input_SkinRgb00             ("主要暗",              Color)  = (1.00, 1.00, 1.00, 1)
        [Space(10)]
        Input_SkinRgb11             ("次要亮",              Color)  = (1.00, 1.00, 1.00, 1)
        Input_SkinRgb10             ("次要暗",              Color)  = (1.00, 1.00, 1.00, 1)
        [Space(10)]
        Input_SkinRgb21             ("金属亮",              Color)  = (0.80, 0.80, 0.80, 1)
        Input_SkinRgb20             ("金属暗",              Color)  = (0.80, 0.80, 0.80, 1)
        [Space(10)]
        Input_SkinRgb31             ("高亮亮",              Color)  = (0.60, 0.60, 0.60, 1)
        Input_SkinRgb30             ("高亮暗",              Color)  = (0.60, 0.60, 0.60, 1)
        //皮肤渐变颜色

        [Space(20)]
        Input_RampRgbBase           ("渐变基准色",                   Color)      = (0.20, 0.20, 0.25, 1)
        
        [Space(20)]
        [Toggle] Input_SkinRampToggle  ("皮肤渐变色启用",            Int) = 0
        Input_SkinRampDir      ("渐变照射位置",                 Vector)     = (0, 1, 0, 0)
        Input_SkinRampRgb1     ("渐变亮色",                     Color)      = (0.60, 0.60, 0.60, 1)
        Input_SkinRampRgb0     ("渐变暗色",                     Color)      = (0.60, 0.60, 0.60, 1)
        Input_SkinRampThreshold1 ("渐变亮色阈值",                      Range(0,1)) = 0.9
        Input_SkinRampThreshold0 ("渐变暗色阈值",                      Range(0,1)) = 0.3
        Input_SkinRampSoftness  ("渐变柔和度",                       Range(0,1)) = 0.5
        [Space(10)]
        Input_RampRgb0 		        ("边缘色",                        Color)  = (1, 1, 1, 1)
        Input_SkinRimThreshold      ("边缘阈值",                       Range(0,1)) = 0.5
        Input_SkinRimSoftness       ("边缘柔和度",                       Range(0,1)) = 0.5

        [Space(20)]
        Input_LightInfluence      ("光照色影响",                        Range(0,1))  = 0.2
        Input_LightMax 	    ("光照最大值",                       Range(0,1))  = 0.9
        Input_LightMin 	    ("光照最小值",                       Range(0,1))  = 0.3
        Input_LightRampThreshold      ("光照阈值",                        Range(0,1)) = 0.5
        Input_LightRampSoftness       ("光照柔和度",                         Range(0,1)) = 0.25

        [Space(10)]
        Input_RampRgb1 		        ("附加光色",                        Color)  = (1, 1, 1, 1)
        [Space(20)]
        Input_RimIntensity       ("边光强度",                        Range(0,1))  = 0.25
        Input_RimPower           ("边光阈值",                            Range(0,1)) = 0.5
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
        [Header(Null0 Star3d1 Crystal3d2 Star2d3)]
        [IntRange] Input_EffectMap0 ("特效图0",       Range(0,3))     = 0
        [IntRange] Input_EffectMap1 ("特效图1",       Range(0,3))     = 0
        [IntRange] Input_EffectMap2 ("特效图2",       Range(0,3))     = 0
        [IntRange] Input_EffectMap3 ("特效图3",       Range(0,3))     = 0
        [IntRange] Input_EffectMap4 ("特效图4",       Range(0,3))     = 0
        [IntRange] Input_EffectMapInside ("内部特效", Range(0,3))     = 0

        [Space(20)]
        [Header(SkyOs0 SkyWs1 CamVs2 Reflect3 NrmOs4 NrmWs5 NrmVs6)]
        [IntRange] Input_DirMap0			 ("方向映射0",       Range(0,6))     = 0
        [IntRange] Input_DirMap1			 ("方向映射1",       Range(0,6))     = 0
        [IntRange] Input_DirMap2			 ("方向映射2",       Range(0,6))     = 0
        [IntRange] Input_DirMap3			 ("方向映射3",       Range(0,6))     = 0
        [IntRange] Input_DirMap4			 ("方向映射4",       Range(0,6))     = 0

        [Space(20)]
        Input_Cutoff             ("透明度裁剪",                    Range(0,5)) = 0.5
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
            Cull Off
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

        // ===[GrabPass]===
        GrabPass { "IonArg_GrabTexture" }
        // ===[主光照 ForwardBase]===
        Pass
        {
            Name "FORWARD"
            Tags { "LightMode" = "ForwardBase" }
             Cull Off  

            ZWrite Off
            ZTest LEqual
            //Offset 0, -1    // 固定单位偏移（不含斜率项），轻推深度避免 Z-Fighting
            Blend SrcAlpha OneMinusSrcAlpha

            HLSLPROGRAM

            #define IonArg_MainTex           Input_MainTex
            #define IonArg_MainTex_ST        Input_MainTex_ST

            #define IonArg_SkinMask0         Input_SkinMask0
            #define IonArg_SkinMask1         Input_SkinMask1
            #define IonArg_SkinMask2         Input_SkinMask2
            #define IonArg_SkinMask3         Input_SkinMask3

            #define IonArg_SkinRgb00          Input_SkinRgb00
            #define IonArg_SkinRgb01		  Input_SkinRgb01
            #define IonArg_SkinRgb10          Input_SkinRgb10
            #define IonArg_SkinRgb11          Input_SkinRgb11
            #define IonArg_SkinRgb20          Input_SkinRgb20
            #define IonArg_SkinRgb21          Input_SkinRgb21
            #define IonArg_SkinRgb30          Input_SkinRgb30
            #define IonArg_SkinRgb31          Input_SkinRgb31


            #define IonArg_LightInfluence   Input_LightInfluence
            #define IonArg_LightMax        Input_LightMax
            #define IonArg_LightMin        Input_LightMin

            #define IonArg_EmissiveTex        Input_EmissiveTex
            #define IonArg_EmissiveIntensity  Input_EmissiveIntensity

            #define IonArg_SkinRampToggle       Input_SkinRampToggle
            #define IonArg_StarNestEnable       Input_StarNestEnable
            #define IonArg_SkinRampDir        Input_SkinRampDir
            #define IonArg_RampRgbBase     Input_RampRgbBase
            #define IonArg_RampRgb0              Input_RampRgb0
            #define IonArg_RampRgb1              Input_RampRgb1

            #define IonArg_SkinRampRgb0     Input_SkinRampRgb0
            #define IonArg_SkinRampRgb1     Input_SkinRampRgb1
            #define IonArg_SkinRampThreshold0 Input_SkinRampThreshold0
            #define IonArg_SkinRampThreshold1 Input_SkinRampThreshold1
            #define IonArg_SkinRampSoftness  Input_SkinRampSoftness
            #define IonArg_SkinRimThreshold  Input_SkinRimThreshold
            #define IonArg_SkinRimSoftness      Input_SkinRimSoftness

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

            #define IonArg_EffectMap0 Input_EffectMap0
            #define IonArg_EffectMap1 Input_EffectMap1
            #define IonArg_EffectMap2 Input_EffectMap2
            #define IonArg_EffectMap3 Input_EffectMap3
            #define IonArg_EffectMap4 Input_EffectMap4
            #define IonArg_EffectMapInside Input_EffectMapInside

            #define IonArg_DirMap0 Input_DirMap0
            #define IonArg_DirMap1 Input_DirMap1
            #define IonArg_DirMap2 Input_DirMap2
            #define IonArg_DirMap3 Input_DirMap3
            #define IonArg_DirMap4 Input_DirMap4


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
            #define IonArg_SkinMask     Input_SkinMask
            #define IonArg_Color1        Input_SkinRgb1
            #define IonArg_Color2        Input_SkinRgb2
            #define IonArg_Color3        Input_SkinRgb3
            #define IonArg_Color4        Input_SkinRgb4
            #define IonArg_EmissiveTex        Input_EmissiveTex
            #define IonArg_EmissiveIntensity  Input_EmissiveIntensity
            #define IonArg_LambertScale       Input_LambertScale
            #define IonArg_LambertOffset      Input_LambertOffset
            #define IonArg_LightRampThreshold      Input_LightRampThreshold
            #define IonArg_LightRampSoftness       Input_LightRampSoftness
            #define IonArg_RampRgbBase     Input_RampRgbBase
            #define IonArg_SkinRampThreshold Input_SkinRampThreshold
            #define IonArg_SkinRampSoftness  Input_SkinRampSoftness
            #define IonArg_SkinRampRgb0     Input_SkinRampRgb0
            #define IonArg_SkinRampThreshold2 Input_SkinRampThreshold2
            #define IonArg_SkinRampSoftness2  Input_SkinRampSoftness2
            #define IonArg_SkinRampRgb1     Input_SkinRampRgb1
            #define IonArg_SkinRampThreshold3 Input_SkinRampThreshold3
            #define IonArg_SkinRampSoftness3  Input_SkinRampSoftness3
            #define IonArg_SkinRampRgb4     Input_SkinRampRgb4
            #define IonArg_SkinRampDir        Input_SkinRampDir
            #define IonArg_SkinRampToggle       Input_SkinRampToggle

            #define IonArg_RimRgb               Input_RimRgb
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
