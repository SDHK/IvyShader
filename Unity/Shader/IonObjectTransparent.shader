HLSLINCLUDE
#define IonShader
ENDHLSL

Shader "Ion/IonObjectTransparent"
{
    Properties
    {
        
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
    
        [Header(Metal)]
        [Space(10)]
        Input_Metal              ("金属度",              Range(0,1)) = 0
        Input_MetalSmoothness    ("金属光滑度",          Range(0,1)) = 0
        Input_MetalRimIntensity    ("边缘反射",            Range(0,1)) = 0

        [Space(20)]
        Input_EnvMapTex           ("环境反射图",         2D) = "gray" {}
        Input_EnvMapInfluence     ("环境图混合",            Range(0,1)) = 0.5
        [Space(20)]
        Input_MatCapTex             ("MatCap",               2D) = "gray" {}
        Input_MatCapInfluence       ("MatCap混合",            Range(0,1)) = 0.5       

        //Input_MetalDiffuseScale     ("金属漫反射比例",          Range(0,1)) = 0.05
       
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
            // #define IonArg_MainTex    Input_MainTex
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
            // #define IonArg_MainTex    Input_MainTex
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

            ZWrite On
            // ZTest Always
            ZTest LEqual
            //Offset 0, -1    // 固定单位偏移（不含斜率项），轻推深度避免 Z-Fighting
            Blend SrcAlpha OneMinusSrcAlpha

            HLSLPROGRAM

            // #define IonArg_MainTex           Input_MainTex
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
            #define IonArg_EnvLightInfluence   Input_EnvLightInfluence
            #define IonArg_LightMin        Input_LightMin
            #define IonArg_LightMax        Input_LightMax
            #define IonArg_LightShadowMin        Input_LightShadowMin

            #define IonArg_EmissiveTex        Input_EmissiveTex
            #define IonArg_EmissiveIntensity  Input_EmissiveIntensity

            #define IonArg_SkinRampToggle       Input_SkinRampToggle
            #define IonArg_StarNestEnable       Input_StarNestEnable
            #define IonArg_SkinObjRampPos        Input_SkinObjRampPos
            #define IonArg_RampRgbBase     Input_RampRgbBase
            #define IonArg_SkinViewRampRgb0              Input_SkinViewRampRgb0
            #define IonArg_SkinViewRampRgb1              Input_SkinViewRampRgb1

            #define IonArg_SkinObjRampRgb0     Input_SkinObjRampRgb0
            #define IonArg_SkinObjRampRgb1     Input_SkinObjRampRgb1
            #define IonArg_SkinObjRampThreshold0 Input_SkinObjRampThreshold0
            #define IonArg_SkinObjRampThreshold1 Input_SkinObjRampThreshold1
            #define IonArg_SkinObjRampSoftness  Input_SkinObjRampSoftness
            #define IonArg_SkinViewRampThreshold0  Input_SkinViewRampThreshold0
            #define IonArg_SkinViewRampThreshold1  Input_SkinViewRampThreshold1
            #define IonArg_SkinViewRampSoftness      Input_SkinViewRampSoftness

            #define IonArg_LightRampThreshold  Input_LightRampThreshold
            #define IonArg_LightRampSoftness   Input_LightRampSoftness

            #define IonArg_LightRimSoftness           Input_LightRimSoftness
            #define IonArg_RimIntensity       Input_RimIntensity

            #define IonArg_BackLightRimSoftness        Input_BackLightRimSoftness
            #define IonArg_BackRimIntensity    Input_BackRimIntensity

            #define IonArg_Metal              Input_Metal
            #define IonArg_MetalSmoothness    Input_MetalSmoothness
            #define IonArg_MetalRimIntensity    Input_MetalRimIntensity

            #define IonArg_MatCapTex            Input_MatCapTex
            #define IonArg_MatCapInfluence      Input_MatCapInfluence
            
            #define IonArg_EnvMapTex           Input_EnvMapTex
            #define IonArg_EnvMapInfluence   Input_EnvMapInfluence

            #define IonArg_MetalDiffuseScale     Input_MetalDiffuseScale

            #define IonArg_EffectMap            Input_EffectMap
            #define IonArg_EffectMap0           Input_EffectMap0
            #define IonArg_EffectMap1           Input_EffectMap1
            #define IonArg_EffectMap2           Input_EffectMap2
            #define IonArg_EffectMap3           Input_EffectMap3
            #define IonArg_EffectMapInside      Input_EffectMapInside

            #define IonArg_VecMap0 Input_VecMap0

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

            // #define IonArg_MainTex       Input_MainTex
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
            #define IonArg_SkinObjRampSoftness  Input_SkinObjRampSoftness
            #define IonArg_SkinObjRampRgb0     Input_SkinObjRampRgb0
            #define IonArg_SkinRampThreshold2 Input_SkinRampThreshold2
            #define IonArg_SkinObjRampSoftness2  Input_SkinObjRampSoftness2
            #define IonArg_SkinObjRampRgb1     Input_SkinObjRampRgb1
            #define IonArg_SkinRampThreshold3 Input_SkinRampThreshold3
            #define IonArg_SkinObjRampSoftness3  Input_SkinObjRampSoftness3
            #define IonArg_SkinRampRgb4     Input_SkinRampRgb4
            #define IonArg_SkinObjRampPos        Input_SkinObjRampPos
            #define IonArg_SkinRampToggle       Input_SkinRampToggle

            #define IonArg_RimRgb               Input_RimRgb
            #define IonArg_BackLightRimSoftness        Input_BackLightRimSoftness
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
