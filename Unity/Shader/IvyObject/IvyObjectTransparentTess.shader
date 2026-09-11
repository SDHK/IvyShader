HLSLINCLUDE
#define IvyShader
#define Link_IvyObjectTransparentTess
ENDHLSL

Shader "Ivy/IvyObjectTransparentTess"
{
    Properties
    {
        [Header(Ivy)]
        
        // IvyArg_MainTex            ("无用主材质",                        2D)     = "white" {}
        [Space(20)]
        IvyArg_SkinMask0                     ("花纹0",   2D)     = "white" {}
        IvyArg_SkinMask1                     ("花纹1",   2D)     = "white" {}
        IvyArg_SkinMask2                     ("花纹2",   2D)     = "white" {}
        IvyArg_SkinMask3                     ("花纹3",   2D)     = "white" {}
        
        [Space(20)]
        IvyArg_EmissiveIntensity             ("特效亮度下限",         Range(0,1))  = 0
        IvyArg_AudioPulse                    ("特效音频脉冲",         Range(0,1))  = 0
        [IntRange] IvyArg_AudioBand          ("音频频段",             Range(0,3))  = 0
        
        //皮肤颜色
        [Space(20)]
        IvyArg_SkinRgb01                     ("主要亮",              Color)  = (1.00, 1.00, 1.00, 1)
        IvyArg_SkinRgb00                     ("主要暗",              Color)  = (1.00, 1.00, 1.00, 1)
        [Space(10)]
        IvyArg_SkinRgb11                     ("次要亮",              Color)  = (1.00, 1.00, 1.00, 1)
        IvyArg_SkinRgb10                     ("次要暗",              Color)  = (1.00, 1.00, 1.00, 1)
        [Space(10)]
        IvyArg_SkinRgb21                     ("金属亮",              Color)  = (0.80, 0.80, 0.80, 1)
        IvyArg_SkinRgb20                     ("金属暗",              Color)  = (0.80, 0.80, 0.80, 1)
        [Space(10)]
        IvyArg_SkinRgb31                     ("高亮亮",              Color)  = (0.60, 0.60, 0.60, 1)
        IvyArg_SkinRgb30                     ("高亮暗",              Color)  = (0.60, 0.60, 0.60, 1)
        //皮肤渐变颜色

        [Space(20)]
        IvyArg_RampRgbBase                   ("渐变基准颜色",               Color)      = (0.20, 0.20, 0.25, 1)
        
        [Space(20)]
        [Toggle] IvyArg_SkinRampToggle       ("渐变启用",                  Int) = 0
        IvyArg_SkinObjRampPos                ("方向渐变位置",              Vector)     = (0, 1, 0, 0)
        IvyArg_SkinObjRampRgb1               ("方向渐变亮色",              Color)      = (0.60, 0.60, 0.60, 1)
        IvyArg_SkinObjRampRgb0               ("方向渐变暗色",              Color)      = (0.60, 0.60, 0.60, 1)
        IvyArg_SkinObjRampThreshold1         ("方向渐变亮色阈值",          Range(0,1)) = 0.1
        IvyArg_SkinObjRampThreshold0         ("方向渐变暗色阈值",          Range(0,1)) = 0.3
        IvyArg_SkinObjRampSoftness           ("方向渐变柔和度",            Range(0,1)) = 0.5
        
        [Space(10)]
        IvyArg_SkinViewRampRgb1 		        ("视线渐变亮色",               Color)  = (1, 1, 1, 1)
        IvyArg_SkinViewRampRgb0 		        ("视线渐变暗色",               Color)  = (1, 1, 1, 1)
        IvyArg_SkinViewRampThreshold1        ("视线渐变亮色阈值",           Range(0,1)) = 0.1
        IvyArg_SkinViewRampThreshold0        ("视线渐变暗色阈值",           Range(0,1)) = 0.5
        IvyArg_SkinViewRampSoftness          ("视线渐变柔和度",             Range(0,1)) = 0.5

        [Space(20)]
        IvyArg_LightMin                      ("光照度下限",               Range(0,1))  = 0.1
        IvyArg_LightMax 	                    ("光照度上限",               Range(0,1))  = 0.9
        [Space(10)]
        IvyArg_LightInfluence                ("光照色影响",               Range(0,1))  = 0.2
        IvyArg_EnvLightInfluence 	        ("环境色影响",               Range(0,1))  = 1
        [Space(10)]
        IvyArg_LightShadowMin 	            ("光照阴影",                Range(0,1))  = 0.3
        IvyArg_LightRampThreshold            ("光影阈值",                Range(0,1)) = 0.5
        IvyArg_LightRampSoftness             ("光影柔和",                Range(0,1)) = 0.25

        [Space(20)]
        IvyArg_RimIntensity                  ("边光强度（伪次表面散射）",        Range(0,1))  = 0.25
        IvyArg_LightRimSoftness              ("边光柔和（伪次表面散射）",       Range(0,1)) = 0.5
        [Space(10)]
        IvyArg_BackRimIntensity              ("背光强度",                        Range(0,1))  = 0.25
        IvyArg_BackLightRimSoftness          ("背光柔和",                       Range(0,1)) = 0.5
    
        [Space(40)]
        IvyArg_EnvMapInfluence               ("环境图混合",           Range(0,1)) = 0.5
        IvyArg_EnvMapTex                     ("环境反射图",           2D) = "gray" {}
        [Space(10)]
        IvyArg_MatCapInfluence               ("MatCap混合",            Range(0,1)) = 0.5    
        IvyArg_MatCapTex                     ("MatCap贴图",            2D) = "gray" {}


        [Space(20)]
        IvyArg_ReflectIntensity01            ("反射强度0亮",          Range(0,1)) = 0
        IvyArg_ReflectSmoothness01           ("反射光滑0亮",          Range(0,1)) = 0
        IvyArg_Transmit01                    ("透明折射0亮",          Range(0,1)) = 0
        IvyArg_Glitter01                     ("闪片高光0亮",          Range(0,1)) = 0
        [Space(5)]
        IvyArg_ReflectIntensity00            ("反射强度0暗",          Range(0,1)) = 0
        IvyArg_ReflectSmoothness00           ("反射光滑0暗",          Range(0,1)) = 0
        IvyArg_Transmit00                    ("透明折射0暗",          Range(0,1)) = 0
        IvyArg_Glitter00                     ("闪片高光0暗",          Range(0,1)) = 0

        [Space(10)]
        IvyArg_ReflectIntensity11            ("反射强度1亮",          Range(0,1)) = 0
        IvyArg_ReflectSmoothness11           ("反射光滑1亮",          Range(0,1)) = 0
        IvyArg_Transmit11                    ("透明折射1亮",          Range(0,1)) = 0
        IvyArg_Glitter11                     ("闪片高光1亮",          Range(0,1)) = 0
        [Space(5)]
        IvyArg_ReflectIntensity10            ("反射强度1暗",          Range(0,1)) = 0
        IvyArg_ReflectSmoothness10           ("反射光滑1暗",          Range(0,1)) = 0
        IvyArg_Transmit10                    ("透明折射1暗",          Range(0,1)) = 0
        IvyArg_Glitter10                     ("闪片高光1暗",          Range(0,1)) = 0
        [Space(10)]
        IvyArg_ReflectIntensity21            ("反射强度2亮",          Range(0,1)) = 0
        IvyArg_ReflectSmoothness21           ("反射光滑2亮",          Range(0,1)) = 0
        IvyArg_Transmit21                    ("透明折射2亮",          Range(0,1)) = 0
        IvyArg_Glitter21                     ("闪片高光2亮",          Range(0,1)) = 0
        [Space(5)]
        IvyArg_ReflectIntensity20            ("反射强度2暗",          Range(0,1)) = 0
        IvyArg_ReflectSmoothness20           ("反射光滑2暗",          Range(0,1)) = 0
        IvyArg_Transmit20                    ("透明折射2暗",          Range(0,1)) = 0
        IvyArg_Glitter20                     ("闪片高光2暗",          Range(0,1)) = 0
        [Space(10)]
        IvyArg_ReflectIntensity31            ("反射强度3亮",          Range(0,1)) = 0
        IvyArg_ReflectSmoothness31           ("反射光滑3亮",          Range(0,1)) = 0
        IvyArg_Transmit31                    ("透明折射3亮",          Range(0,1)) = 0
        IvyArg_Glitter31                     ("闪片高光3亮",          Range(0,1)) = 0
        [Space(5)]
        IvyArg_ReflectIntensity30            ("反射强度3暗",          Range(0,1)) = 0
        IvyArg_ReflectSmoothness30           ("反射光滑3暗",          Range(0,1)) = 0
        IvyArg_Transmit30                    ("透明折射3暗",          Range(0,1)) = 0
        IvyArg_Glitter30                     ("闪片高光3暗",          Range(0,1)) = 0

        [Space(20)]
        IvyArg_IridescenceHue                ("虹彩色相",              Range(0,1)) = 0.55
        IvyArg_IridescenceSpread             ("虹彩展开",              Range(0,2)) = 0.25
        [IntRange] IvyArg_IridescenceBands   ("虹彩档数",              Range(0,16)) = 0
        IvyArg_FilmMaskTex                   ("彩虹遮罩(EnvMap)",      2D) = "white" {}
        [Space(10)]
        IvyArg_Film01                        ("虹彩变色0亮",              Range(0,1)) = 0
        IvyArg_Film00                        ("虹彩变色0暗",              Range(0,1)) = 0
        [Space(5)]
        IvyArg_Film11                        ("虹彩变色1亮",              Range(0,1)) = 0
        IvyArg_Film10                        ("虹彩变色1暗",              Range(0,1)) = 0
        [Space(5)]
        IvyArg_Film21                        ("虹彩变色2亮",              Range(0,1)) = 0
        IvyArg_Film20                        ("虹彩变色2暗",              Range(0,1)) = 0
        [Space(5)]
        IvyArg_Film31                        ("虹彩变色3亮",              Range(0,1)) = 0
        IvyArg_Film30                        ("虹彩变色3暗",              Range(0,1)) = 0

        [Space(20)]
        [Header(Null Star3d Crystal3d Nest3d)]
        [IntRange] IvyArg_EffectMap          ("3d特效类型",            Range(0,3))     = 0
        [Space(10)]
        [Header(Null Cloud Line Star2d)]
        [IntRange] IvyArg_Effect2DMap        ("2d特效类型",            Range(0,3))     = 0
        [Space(10)]
        IvyArg_EffectIntensity01             ("特效强度0亮",          Range(0,1)) = 0
        IvyArg_EffectIntensity00             ("特效强度0暗",          Range(0,1)) = 0
        [Space(5)]
        IvyArg_EffectIntensity11             ("特效强度1亮",          Range(0,1)) = 0
        IvyArg_EffectIntensity10             ("特效强度1暗",          Range(0,1)) = 0
        [Space(5)]
        IvyArg_EffectIntensity21             ("特效强度2亮",          Range(0,1)) = 0
        IvyArg_EffectIntensity20             ("特效强度2暗",          Range(0,1)) = 0
        [Space(5)]
        IvyArg_EffectIntensity31             ("特效强度3亮",          Range(0,1)) = 0
        IvyArg_EffectIntensity30             ("特效强度3暗",          Range(0,1)) = 0
        [Space(10)]
        IvyArg_EffectInside                  ("内部特效",            Range(0,1)) = 0

        [Space(40)]
        [Header(SkyOs0 SkyWs1 CamVs2 Reflect3 NrmOs4 NrmWs5 NrmVs6)]
        [IntRange] IvyArg_VecMap0			("2d特效向量映射0",       Range(0,6))     = 0
        [Space(20)]
        IvyArg_Cutoff                        ("透明度裁剪",           Range(0,5)) = 0.5
    
        [Space(20)]
        IvyArg_Color                         ("描边颜色",            Color)  = (0, 0, 0, 1)
        IvyArg_Scale                         ("描边大小",            Float)  = 0
       
        IvyArg_PressDepth                    ("按压深度",            Range(-1, 1)) = 0
        IvyArg_PressPos                      ("触摸位置(世界)",       Vector)     = (0, 0, 0, 0)
        IvyArg_PressRadius                   ("触摸半径",            Range(0, 2)) = 0
        IvyArg_TessFactor                    ("细分密度",            Range(1, 8)) = 4

    }

    //===[URP 管线]===================================================
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Transparent" "Queue" = "Transparent" }

        Pass
        {
            Name "OUTLINE"
            Tags { "LightMode" = "UniversalForward" }
            Cull Front
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            HLSLPROGRAM
            #define Link_IvyPassOutline
            #include "../../IvyCoreUnity.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "FORWARD_INNER"
            Tags { "LightMode" = "UniversalForward" }
            Cull Front
            ZWrite On
            ZTest LEqual
            Blend One OneMinusSrcAlpha
            HLSLPROGRAM
            #define Link_IvyPassMain
            #include "../../IvyCoreUnity.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "FORWARD_OUTER"
            Tags { "LightMode" = "UniversalForward" }
            Cull Back
            ZWrite On
            ZTest LEqual
            Blend One OneMinusSrcAlpha
            HLSLPROGRAM
            #define Link_IvyPassMain
            #include "../../IvyCoreUnity.hlsl"
            ENDHLSL
        }

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
            #include "../../IvyCoreUnity.hlsl"
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
            #define Link_IvyPassOutline
            #include "../../IvyCoreUnity.hlsl"
            ENDHLSL
        }

        // ===[GrabPass]===
        //GrabPass { "IvyArg_GrabTexture" }

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
            #define Link_IvyPassMain
            #include "../../IvyCoreUnity.hlsl"
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
            #define Link_IvyPassMain
            #include "../../IvyCoreUnity.hlsl"
            ENDHLSL
        }

        // ===[附加光照 ForwardAdd]===
        Pass
        {
            Name "ADDITIONAL"
            Tags { "LightMode" = "ForwardAdd" }
            Cull Back
            Blend One One
            ZWrite Off
            ZTest LEqual
            HLSLPROGRAM
            #define Link_IvyPassAdd
            #include "../../IvyCoreUnity.hlsl"
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
            #include "../../IvyCoreUnity.hlsl"
            ENDHLSL
        }
    }
    //FallBack "Diffuse"

}
