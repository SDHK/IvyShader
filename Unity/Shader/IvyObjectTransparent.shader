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
        Input_SkinMask0                     ("花纹0",   2D)     = "white" {}
        Input_SkinMask1                     ("花纹1",   2D)     = "white" {}
        Input_SkinMask2                     ("花纹2",   2D)     = "white" {}
        Input_SkinMask3                     ("花纹3",   2D)     = "white" {}
        
        [Space(20)]
        Input_EmissiveIntensity             ("自发光强度",           Range(0,1))  = 0.1
        Input_EmissiveTex                   ("自发光遮罩",           2D)     = "white" {}
        
        //皮肤颜色
        [Space(20)]
        Input_SkinRgb01                     ("主要亮",              Color)  = (1.00, 1.00, 1.00, 1)
        Input_SkinRgb00                     ("主要暗",              Color)  = (1.00, 1.00, 1.00, 1)
        [Space(10)]
        Input_SkinRgb11                     ("次要亮",              Color)  = (1.00, 1.00, 1.00, 1)
        Input_SkinRgb10                     ("次要暗",              Color)  = (1.00, 1.00, 1.00, 1)
        [Space(10)]
        Input_SkinRgb21                     ("金属亮",              Color)  = (0.80, 0.80, 0.80, 1)
        Input_SkinRgb20                     ("金属暗",              Color)  = (0.80, 0.80, 0.80, 1)
        [Space(10)]
        Input_SkinRgb31                     ("高亮亮",              Color)  = (0.60, 0.60, 0.60, 1)
        Input_SkinRgb30                     ("高亮暗",              Color)  = (0.60, 0.60, 0.60, 1)
        //皮肤渐变颜色

        [Space(20)]
        Input_RampRgbBase                   ("渐变基准颜色",               Color)      = (0.20, 0.20, 0.25, 1)
        
        [Space(20)]
        [Toggle] Input_SkinRampToggle       ("渐变启用",                  Int) = 0
        Input_SkinObjRampPos                ("方向渐变位置",              Vector)     = (0, 1, 0, 0)
        Input_SkinObjRampRgb1               ("方向渐变亮色",              Color)      = (0.60, 0.60, 0.60, 1)
        Input_SkinObjRampRgb0               ("方向渐变暗色",              Color)      = (0.60, 0.60, 0.60, 1)
        Input_SkinObjRampThreshold1         ("方向渐变亮色阈值",          Range(0,1)) = 0.1
        Input_SkinObjRampThreshold0         ("方向渐变暗色阈值",          Range(0,1)) = 0.3
        Input_SkinObjRampSoftness           ("方向渐变柔和度",            Range(0,1)) = 0.5
        
        [Space(10)]
        Input_SkinViewRampRgb1 		        ("视线渐变亮色",               Color)  = (1, 1, 1, 1)
        Input_SkinViewRampRgb0 		        ("视线渐变暗色",               Color)  = (1, 1, 1, 1)
        Input_SkinViewRampThreshold1        ("视线渐变亮色阈值",           Range(0,1)) = 0.1
        Input_SkinViewRampThreshold0        ("视线渐变暗色阈值",           Range(0,1)) = 0.5
        Input_SkinViewRampSoftness          ("视线渐变柔和度",             Range(0,1)) = 0.5

        [Space(20)]
        Input_LightMin                      ("光照度下限",               Range(0,1))  = 0.1
        Input_LightMax 	                    ("光照度上限",               Range(0,1))  = 0.9
        [Space(10)]
        Input_LightInfluence                ("光照色影响",               Range(0,1))  = 0.2
        Input_EnvLightInfluence 	        ("环境色影响",               Range(0,1))  = 1
        [Space(10)]
        Input_LightShadowMin 	            ("光照阴影",                Range(0,1))  = 0.3
        Input_LightRampThreshold            ("光影阈值",                Range(0,1)) = 0.5
        Input_LightRampSoftness             ("光影柔和",                Range(0,1)) = 0.25

        [Space(20)]
        Input_RimIntensity                  ("边光强度（伪次表面散射）",        Range(0,1))  = 0.25
        Input_LightRimSoftness              ("边光柔和（伪次表面散射）",       Range(0,1)) = 0.5
        [Space(10)]
        Input_BackRimIntensity              ("背光强度",                        Range(0,1))  = 0.25
        Input_BackLightRimSoftness          ("背光柔和",                       Range(0,1)) = 0.5
    
        [Space(40)]
        Input_EnvMapInfluence               ("环境图混合",           Range(0,1)) = 0.5
        Input_EnvMapTex                     ("环境反射图",           2D) = "gray" {}
        [Space(10)]
        Input_MatCapInfluence               ("MatCap混合",            Range(0,1)) = 0.5    
        Input_MatCapTex                     ("MatCap贴图",            2D) = "gray" {}


        [Space(20)]
        Input_ReflectIntensity01            ("反射强度0亮",          Range(0,1)) = 0
        Input_ReflectSmoothness01           ("反射光滑0亮",          Range(0,1)) = 0
        Input_Transmit01                    ("透明折射0亮",          Range(0,1)) = 0
        Input_Glitter01                     ("闪片高光0亮",          Range(0,1)) = 0
        [Space(5)]
        Input_ReflectIntensity00            ("反射强度0暗",          Range(0,1)) = 0
        Input_ReflectSmoothness00           ("反射光滑0暗",          Range(0,1)) = 0
        Input_Transmit00                    ("透明折射0暗",          Range(0,1)) = 0
        Input_Glitter00                     ("闪片高光0暗",          Range(0,1)) = 0

        [Space(10)]
        Input_ReflectIntensity11            ("反射强度1亮",          Range(0,1)) = 0
        Input_ReflectSmoothness11           ("反射光滑1亮",          Range(0,1)) = 0
        Input_Transmit11                    ("透明折射1亮",          Range(0,1)) = 0
        Input_Glitter11                     ("闪片高光1亮",          Range(0,1)) = 0
        [Space(5)]
        Input_ReflectIntensity10            ("反射强度1暗",          Range(0,1)) = 0
        Input_ReflectSmoothness10           ("反射光滑1暗",          Range(0,1)) = 0
        Input_Transmit10                    ("透明折射1暗",          Range(0,1)) = 0
        Input_Glitter10                     ("闪片高光1暗",          Range(0,1)) = 0
        [Space(10)]
        Input_ReflectIntensity21            ("反射强度2亮",          Range(0,1)) = 0
        Input_ReflectSmoothness21           ("反射光滑2亮",          Range(0,1)) = 0
        Input_Transmit21                    ("透明折射2亮",          Range(0,1)) = 0
        Input_Glitter21                     ("闪片高光2亮",          Range(0,1)) = 0
        [Space(5)]
        Input_ReflectIntensity20            ("反射强度2暗",          Range(0,1)) = 0
        Input_ReflectSmoothness20           ("反射光滑2暗",          Range(0,1)) = 0
        Input_Transmit20                    ("透明折射2暗",          Range(0,1)) = 0
        Input_Glitter20                     ("闪片高光2暗",          Range(0,1)) = 0
        [Space(10)]
        Input_ReflectIntensity31            ("反射强度3亮",          Range(0,1)) = 0
        Input_ReflectSmoothness31           ("反射光滑3亮",          Range(0,1)) = 0
        Input_Transmit31                    ("透明折射3亮",          Range(0,1)) = 0
        Input_Glitter31                     ("闪片高光3亮",          Range(0,1)) = 0
        [Space(5)]
        Input_ReflectIntensity30            ("反射强度3暗",          Range(0,1)) = 0
        Input_ReflectSmoothness30           ("反射光滑3暗",          Range(0,1)) = 0
        Input_Transmit30                    ("透明折射3暗",          Range(0,1)) = 0
        Input_Glitter30                     ("闪片高光3暗",          Range(0,1)) = 0

        [Space(20)]
        Input_IridescenceHue                ("虹彩色相",              Range(0,1)) = 0.55
        Input_IridescenceSpread             ("虹彩展开",              Range(0,2)) = 0.25
        [IntRange] Input_IridescenceBands   ("虹彩档数",              Range(0,16)) = 0
        Input_FilmMaskTex                   ("彩虹遮罩(EnvMap)",      2D) = "white" {}
        [Space(10)]
        Input_Film01                        ("虹彩变色0亮",              Range(0,1)) = 0
        Input_Film00                        ("虹彩变色0暗",              Range(0,1)) = 0
        [Space(5)]
        Input_Film11                        ("虹彩变色1亮",              Range(0,1)) = 0
        Input_Film10                        ("虹彩变色1暗",              Range(0,1)) = 0
        [Space(5)]
        Input_Film21                        ("虹彩变色2亮",              Range(0,1)) = 0
        Input_Film20                        ("虹彩变色2暗",              Range(0,1)) = 0
        [Space(5)]
        Input_Film31                        ("虹彩变色3亮",              Range(0,1)) = 0
        Input_Film30                        ("虹彩变色3暗",              Range(0,1)) = 0

        [Space(20)]
        [Header(Null Star3d Crystal3d Nest3d)]
        [IntRange] Input_EffectMap          ("3d特效类型",            Range(0,3))     = 0
        [Space(10)]
        [Header(Null Cloud Line Star2d)]
        [IntRange] Input_Effect2DMap        ("2d特效类型",            Range(0,3))     = 0
        [Space(10)]
        Input_EffectIntensity01             ("特效强度0亮",          Range(0,1)) = 0
        Input_EffectIntensity00             ("特效强度0暗",          Range(0,1)) = 0
        [Space(5)]
        Input_EffectIntensity11             ("特效强度1亮",          Range(0,1)) = 0
        Input_EffectIntensity10             ("特效强度1暗",          Range(0,1)) = 0
        [Space(5)]
        Input_EffectIntensity21             ("特效强度2亮",          Range(0,1)) = 0
        Input_EffectIntensity20             ("特效强度2暗",          Range(0,1)) = 0
        [Space(5)]
        Input_EffectIntensity31             ("特效强度3亮",          Range(0,1)) = 0
        Input_EffectIntensity30             ("特效强度3暗",          Range(0,1)) = 0
        [Space(10)]
        Input_EffectInside                  ("内部特效",            Range(0,1)) = 0

        [Space(40)]
        [Header(SkyOs0 SkyWs1 CamVs2 Reflect3 NrmOs4 NrmWs5 NrmVs6)]
        [IntRange] Input_VecMap0			("2d特效向量映射0",       Range(0,6))     = 0
        [Space(20)]
        Input_Cutoff                        ("透明度裁剪",           Range(0,5)) = 0.5
    
        [Space(20)]
        Input_OutlineColor                  ("描边颜色",            Color)  = (0, 0, 0, 1)
        Input_OutlineScale                  ("描边大小",            Float)  = 0

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

        // ===[内壁：先画，不写深度]===
        Pass
        {
            Name "FORWARD_INNER"
            Tags { "LightMode" = "ForwardBase" }
            Cull Front
            ZWrite On
            ZTest LEqual
            Blend One OneMinusSrcAlpha

            HLSLPROGRAM
            #include "IvyObjectTransparentMain.hlsl"
            ENDHLSL
        }

        // ===[外壁：后画，写深度，恢复和世界的层级]===
        Pass
        {
            Name "FORWARD_OUTER"
            Tags { "LightMode" = "ForwardBase" }
            Cull Back
            ZWrite On
            ZTest LEqual
            Blend One OneMinusSrcAlpha

            HLSLPROGRAM
            #include "IvyObjectTransparentMain.hlsl"
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
