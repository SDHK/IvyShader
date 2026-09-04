HLSLINCLUDE
#define IvyShader
ENDHLSL

Shader "Ivy/IvyObjectTransparent"
{
    Properties
    {
        [Header(Ivy)]
        
        // Input_MainTex            ("无用主材质",                        2D)     = "white" {}
        [Space(20)]
        Input_SkinMask0          ("花纹0",   2D)     = "white" {}
        Input_SkinMask1          ("花纹1",   2D)     = "white" {}
        Input_SkinMask2          ("花纹2",   2D)     = "white" {}
        Input_SkinMask3          ("花纹3",   2D)     = "white" {}
        
        [Space(20)]
        Input_EmissiveIntensity  ("自发光强度",                       Range(0,1))  = 0.1
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
        Input_SkinObjRampPos      ("方向渐变照射位置",                 Vector)     = (0, 1, 0, 0)
        Input_SkinObjRampRgb1     ("方向渐变亮色",                     Color)      = (0.60, 0.60, 0.60, 1)
        Input_SkinObjRampRgb0     ("方向渐变暗色",                     Color)      = (0.60, 0.60, 0.60, 1)
        Input_SkinObjRampThreshold1 ("方向渐变亮色阈值",                  Range(0,1)) = 0.1
        Input_SkinObjRampThreshold0 ("方向渐变暗色阈值",                  Range(0,1)) = 0.3
        Input_SkinObjRampSoftness   ("方向渐变柔和度",                   Range(0,1)) = 0.5
        
        [Space(10)]
        Input_SkinViewRampRgb1 		    ("视线渐变亮色",                        Color)  = (1, 1, 1, 1)
        Input_SkinViewRampRgb0 		    ("视线渐变暗色",                        Color)  = (1, 1, 1, 1)
        Input_SkinViewRampThreshold1    ("视线渐变亮色阈值",                       Range(0,1)) = 0.1
        Input_SkinViewRampThreshold0    ("视线渐变暗色阈值",                       Range(0,1)) = 0.5
        Input_SkinViewRampSoftness      ("视线渐变柔和度",                       Range(0,1)) = 0.5

        [Space(20)]
        Input_LightMin                  ("光照下限",                       Range(0,1))  = 0.1
        Input_LightMax 	                ("光照上限",                       Range(0,1))  = 0.9
        Input_LightInfluence            ("光照色影响",                       Range(0,1))  = 0.2
        Input_EnvLightInfluence 	    ("环境光影响",                       Range(0,1))  = 1

        Input_LightShadowMin 	        ("光照阴影值",                       Range(0,1))  = 0.3
        Input_LightRampThreshold        ("光影阈值",                         Range(0,1)) = 0.5
        Input_LightRampSoftness         ("光影柔和度",                       Range(0,1)) = 0.25

        [Space(20)]
        Input_RimIntensity          ("边光强度（伪次表面散射）",                        Range(0,1))  = 0.25
        Input_LightRimSoftness      ("边光柔和度（伪次表面散射）",                            Range(0,1)) = 0.5
        [Space(10)]
        Input_BackRimIntensity      ("背光强度",                        Range(0,1))  = 0.25
        Input_BackLightRimSoftness  ("背光柔和度",                            Range(0,1)) = 0.5
    
        [Space(10)]
        Input_ReflectIntensity       ("反射强度",            Range(0,1)) = 0
        Input_ReflectSmoothness      ("反射光滑度",          Range(0,1)) = 0


        [Space(20)]
        Input_EnvMapTex           ("环境反射图",         2D) = "gray" {}
        Input_EnvMapInfluence     ("环境图混合",            Range(0,1)) = 0.5
        [Space(20)]
        Input_MatCapTex             ("MatCap",               2D) = "gray" {}
        Input_MatCapInfluence       ("MatCap混合",            Range(0,1)) = 0.5       

        [Space(20)]
        [Header(Null Star3d Crystal3d Star2d)]
        [IntRange] Input_EffectMap  ("特效",                Range(0,3))     = 0
        //扰动，移动
        [Header(Null white black all)]
        [IntRange] Input_EffectMap0 ("特效注入0",           Range(0,3))     = 0
        [IntRange] Input_EffectMap1 ("特效注入1",           Range(0,3))     = 0
        [IntRange] Input_EffectMap2 ("特效注入2",           Range(0,3))     = 0
        [IntRange] Input_EffectMap3 ("特效注入3",           Range(0,3))     = 0
        [Toggle]   Input_EffectMapInside ("内部特效",       Int)            = 0

        [Space(20)]
        [Header(SkyOs0 SkyWs1 CamVs2 Reflect3 NrmOs4 NrmWs5 NrmVs6)]
        [IntRange] Input_VecMap0			 ("向量映射0",       Range(0,6))     = 0
        [Space(20)]
        Input_Cutoff             ("透明度裁剪",                    Range(0,5)) = 0.5
    
        [Space(20)]
        Input_OutlineColor              ("描边颜色",                           Color)  = (0, 0, 0, 1)
        Input_OutlineScale              ("描边大小",                           Float)  = 0

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
            #define IvyArg_Color Input_OutlineColor
            #define IvyArg_Scale Input_OutlineScale
            #define Link_IvyPassOutline
            #include "../IvyCoreUnity.hlsl"
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
            // #define IvyArg_MainTex    Input_MainTex
            #define IvyArg_MainTex_ST Input_MainTex_ST
            #define Link_IvyPassMain
            #include "../IvyCoreUnity.hlsl"
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
            #define Link_IvyPassShadowCaster
            #include "../IvyCoreUnity.hlsl"
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
            #define IvyArg_Color Input_OutlineColor
            #define IvyArg_Scale Input_OutlineScale
            #define Link_IvyPassOutline
            #include "../IvyCoreUnity.hlsl"
            ENDHLSL
        }

        // ===[深度预写 Pass]===
        // 先把前面深度写入缓冲区，内部面 ZTest 时失败，不会错误覆盖外面。
        // Pass
        // {
        //     Name "DEPTH_PREPASS"
        //     Tags { "LightMode" = "Always" }
        //     Cull Off
        //     ZWrite On
        //     ColorMask 0
        //     HLSLPROGRAM
        //     // #define IvyArg_MainTex    Input_MainTex
        //     #define IvyArg_MainTex_ST Input_MainTex_ST
        //     #define IvyArg_Cutoff     Input_Cutoff
        //     #define Link_IvyPassDepthPre
        //     #include "../IvyCoreUnity.hlsl"
        //     ENDHLSL
        // } //开启后内部消失



        // ===[GrabPass]===
        GrabPass { "IvyArg_GrabTexture" }
        // ===[主光照 ForwardBase]===

        Pass
        {
            Name "FORWARD"
            Tags { "LightMode" = "ForwardBase" }
            ZWrite On
            Cull Off  
            // Cull Back
            // Cull Front
            // ZWrite Off
            ZTest LEqual
            Blend SrcAlpha OneMinusSrcAlpha

            HLSLPROGRAM

            // #define IvyArg_MainTex           Input_MainTex
            #define IvyArg_MainTex_ST                   Input_MainTex_ST

            #define IvyArg_SkinMask0                    Input_SkinMask0
            #define IvyArg_SkinMask1                    Input_SkinMask1
            #define IvyArg_SkinMask2                    Input_SkinMask2
            #define IvyArg_SkinMask3                    Input_SkinMask3

            #define IvyArg_SkinRgb00                    Input_SkinRgb00
            #define IvyArg_SkinRgb01                    Input_SkinRgb01
            #define IvyArg_SkinRgb10                    Input_SkinRgb10
            #define IvyArg_SkinRgb11                    Input_SkinRgb11
            #define IvyArg_SkinRgb20                    Input_SkinRgb20
            #define IvyArg_SkinRgb21                    Input_SkinRgb21
            #define IvyArg_SkinRgb30                    Input_SkinRgb30
            #define IvyArg_SkinRgb31                    Input_SkinRgb31


            #define IvyArg_LightInfluence               Input_LightInfluence
            #define IvyArg_EnvLightInfluence            Input_EnvLightInfluence
            #define IvyArg_LightMin                     Input_LightMin
            #define IvyArg_LightMax                     Input_LightMax
            #define IvyArg_LightShadowMin               Input_LightShadowMin

            #define IvyArg_EmissiveTex                  Input_EmissiveTex
            #define IvyArg_EmissiveIntensity            Input_EmissiveIntensity
            #define IvyArg_SkinRampToggle               Input_SkinRampToggle
            #define IvyArg_StarNestEnable               Input_StarNestEnable
            #define IvyArg_SkinObjRampPos               Input_SkinObjRampPos
            #define IvyArg_RampRgbBase                  Input_RampRgbBase
            #define IvyArg_SkinViewRampRgb0             Input_SkinViewRampRgb0
            #define IvyArg_SkinViewRampRgb1             Input_SkinViewRampRgb1

            #define IvyArg_SkinObjRampRgb0              Input_SkinObjRampRgb0
            #define IvyArg_SkinObjRampRgb1              Input_SkinObjRampRgb1
            #define IvyArg_SkinObjRampThreshold0        Input_SkinObjRampThreshold0
            #define IvyArg_SkinObjRampThreshold1        Input_SkinObjRampThreshold1
            #define IvyArg_SkinObjRampSoftness          Input_SkinObjRampSoftness
            #define IvyArg_SkinViewRampThreshold0       Input_SkinViewRampThreshold0
            #define IvyArg_SkinViewRampThreshold1       Input_SkinViewRampThreshold1
            #define IvyArg_SkinViewRampSoftness         Input_SkinViewRampSoftness

            #define IvyArg_LightRampThreshold           Input_LightRampThreshold
            #define IvyArg_LightRampSoftness            Input_LightRampSoftness

            #define IvyArg_LightRimSoftness             Input_LightRimSoftness
            #define IvyArg_RimIntensity                 Input_RimIntensity

            #define IvyArg_BackLightRimSoftness         Input_BackLightRimSoftness
            #define IvyArg_BackRimIntensity             Input_BackRimIntensity

            #define IvyArg_ReflectSmoothness            Input_ReflectSmoothness
            #define IvyArg_ReflectIntensity             Input_ReflectIntensity

            #define IvyArg_MatCapTex                    Input_MatCapTex
            #define IvyArg_MatCapInfluence              Input_MatCapInfluence
            
            #define IvyArg_EnvMapTex                    Input_EnvMapTex
            #define IvyArg_EnvMapInfluence              Input_EnvMapInfluence

            #define IvyArg_EffectMap                    Input_EffectMap
            #define IvyArg_EffectMap0                   Input_EffectMap0
            #define IvyArg_EffectMap1                   Input_EffectMap1
            #define IvyArg_EffectMap2                   Input_EffectMap2
            #define IvyArg_EffectMap3                   Input_EffectMap3
            #define IvyArg_EffectMapInside              Input_EffectMapInside

            #define IvyArg_VecMap0 Input_VecMap0

            #define Link_IvyPassMainSimple
            #include "../IvyCoreUnity.hlsl"
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

            // #define IvyArg_MainTex       Input_MainTex
            #define IvyArg_MainTex_ST    Input_MainTex_ST
            #define IvyArg_SkinMask     Input_SkinMask
            #define IvyArg_Color1        Input_SkinRgb1
            #define IvyArg_Color2        Input_SkinRgb2
            #define IvyArg_Color3        Input_SkinRgb3
            #define IvyArg_Color4        Input_SkinRgb4
            #define IvyArg_EmissiveTex        Input_EmissiveTex
            #define IvyArg_EmissiveIntensity  Input_EmissiveIntensity
            #define IvyArg_LambertScale       Input_LambertScale
            #define IvyArg_LambertOffset      Input_LambertOffset
            #define IvyArg_LightRampThreshold      Input_LightRampThreshold
            #define IvyArg_LightRampSoftness       Input_LightRampSoftness
            #define IvyArg_RampRgbBase     Input_RampRgbBase
            #define IvyArg_SkinRampThreshold Input_SkinRampThreshold
            #define IvyArg_SkinObjRampSoftness  Input_SkinObjRampSoftness
            #define IvyArg_SkinObjRampRgb0     Input_SkinObjRampRgb0
            #define IvyArg_SkinRampThreshold2 Input_SkinRampThreshold2
            #define IvyArg_SkinObjRampSoftness2  Input_SkinObjRampSoftness2
            #define IvyArg_SkinObjRampRgb1     Input_SkinObjRampRgb1
            #define IvyArg_SkinRampThreshold3 Input_SkinRampThreshold3
            #define IvyArg_SkinObjRampSoftness3  Input_SkinObjRampSoftness3
            #define IvyArg_SkinRampRgb4     Input_SkinRampRgb4
            #define IvyArg_SkinObjRampPos        Input_SkinObjRampPos
            #define IvyArg_SkinRampToggle       Input_SkinRampToggle

            #define IvyArg_RimRgb               Input_RimRgb
            #define IvyArg_BackLightRimSoftness        Input_BackLightRimSoftness
            #define IvyArg_BackRimIntensity    Input_BackRimIntensity
            #define Link_IvyPassMainAdd
            #include "../IvyCoreUnity.hlsl"
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
            #define Link_IvyPassShadowCaster
            #include "../IvyCoreUnity.hlsl"
            ENDHLSL
        }


    }
    //FallBack "Diffuse"

}
