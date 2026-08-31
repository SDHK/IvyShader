HLSLINCLUDE
#define IonShader
ENDHLSL

Shader "Ion/IonObject"
{
    Properties
    {
        [Header(Textures)]
        Input_MainTex            ("Main Tex",                        2D)     = "white" {}
        Input_ColorMask          ("Color Mask (RGBA to Color1-4)",   2D)     = "black" {}
        Input_EmissiveTex        ("Emissive Mask (R=发光亮度)",       2D)     = "black" {}

        [Space(8)]
        [Header(Color System)]
        Input_Color1             ("Color 1  主色",                   Color)  = (1.00, 1.00, 1.00, 1)
        Input_Color2             ("Color 2  次色",                   Color)  = (0.80, 0.80, 0.80, 1)
        Input_Color3             ("Color 3  附加色",                 Color)  = (0.60, 0.60, 0.60, 1)
        Input_Color4             ("Color 4  高亮色",                 Color)  = (1.00, 1.00, 0.50, 1)

        [Space(8)]
        [Header(Emissive)]
        Input_EmissiveIntensity  ("Intensity",                       Float)  = 1.0
      
        [Space(8)]
        [Header(Base Ramp  Structural Shading)]
        Input_BaseRampEnable  ("附加渐变色权重",                        Range(0,1)) = 0.5
        Input_BaseRampDir        ("投射位置",                        Vector)     = (0, 1, 0, 0)
        Input_BaseRampColor0     ("变量色",                     Color)      = (0.20, 0.20, 0.25, 1)
      
        [Space(8)]
        Input_BaseRampColor1     ("深暗色",                     Color)      = (0.20, 0.20, 0.25, 1)
        Input_BaseRampColor2     ("偏暗色",                     Color)      = (0.60, 0.60, 0.60, 1)
        Input_BaseRampColor3     ("基准色",                     Color)      = (0.85, 0.85, 0.85, 1)
        Input_BaseRampColor4     ("偏亮色",                     Color)      = (1.00, 1.00, 1.00, 1)
        Input_BaseRampColor5     ("高亮色",                     Color)      = (1.00, 1.00, 1.00, 1)
        
        [Space(8)]
        Input_BaseRampThreshold1 ("阈值1",                      Range(0,1)) = 0.3
        Input_BaseRampThreshold2 ("阈值2",                      Range(0,1)) = 0.7
        Input_BaseRampThreshold3 ("阈值3",                      Range(0,1)) = 0.9
        Input_BaseRampThreshold4 ("阈值4",                      Range(0,1)) = 0.9
      
        [Space(8)]
        Input_BaseRampSoftness1  ("过渡1",                       Range(0,0.5)) = 0.05
        Input_BaseRampSoftness2  ("过渡2",                       Range(0,0.5)) = 0.05
        Input_BaseRampSoftness3  ("过渡3",                       Range(0,0.5)) = 0.05
        Input_BaseRampSoftness4  ("过渡4",                       Range(0,0.5)) = 0.05

        [Space(8)]
        [Header(Fixed Rim Light  Ambient Backlight)]
        Input_FixedRimPower      ("Power",                            Range(1,16)) = 4.0
        Input_FixedRimIntensity  ("Intensity  Color = BaseRampColor4", Range(0,2)) = 0.0

        [Space(8)]
        [Header(Ramp  Dynamic Light Shading)]
        Input_LightRampThreshold      ("Threshold",                        Range(0,1)) = 0.5
        Input_LightRampSoftness       ("Softness",                         Range(0,0.5)) = 0.05

        [Space(8)]
        [Header(Rim Light  Fresnel)]
        Input_RimColor           ("Color",                            Color)      = (1, 1, 1, 1)
        Input_RimPower           ("Power",                            Range(1,16)) = 4.0
        Input_RimIntensity       ("Intensity",                        Range(0,2))  = 0.5

        [Space(8)]
        [Header(Back Rim Light  Backlight)]
        Input_BackRimColor       ("Color",                            Color)      = (1, 1, 1, 1)
        Input_BackRimPower       ("Power",                            Range(1,16)) = 4.0
        Input_BackRimIntensity   ("Intensity",                        Range(0,2))  = 0.5

        [Space(8)]
        [Header(Outline)]
        Input_OutlineColor              ("Color",                           Color)  = (0, 0, 0, 1)
        Input_OutlineScale              ("Scale",                           Float)  = 0.1
        Input_OutlineScale123           ("Scale",                           Float)  = 0.1
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
            #define IonArg_Color _Color
            #define IonArg_Scale _Scale
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
            #define IonArg_MainTex    _MainTex
            #define IonArg_MainTex_ST _MainTex_ST
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
        Tags { "RenderType" = "Opaque" "Queue" = "Geometry" }
        LOD 100

        // ===[描边]===
        Pass
        {
            Name "OUTLINE"
            Tags { "LightMode" = "Always" }
            Cull Front
            ZWrite On
            ZTest LEqual
            HLSLPROGRAM
            #define IonArg_Color Input_OutlineColor
            #define IonArg_Scale Input_OutlineScale
            #define Link_IonPassOutline
            // #include "../IonCoreUnity.hlsl"
            ENDHLSL
        }

        // ===[主光照 ForwardBase]===
        // 不透明版：ZWrite On + 屏幕空间阴影（正确接收方向光阴影）
        Pass
        {
            Name "FORWARD"
            Tags { "LightMode" = "ForwardBase" }
            Cull Back
            ZWrite On
            ZTest LEqual
            Blend Off
            HLSLPROGRAM
            #define IonSet_ShadowScreen               // 不透明物体使用屏幕空间阴影
            
            #define IonArg_MainTex           Input_MainTex
            #define IonArg_MainTex_ST        Input_MainTex_ST
            #define IonArg_ColorMask         Input_ColorMask
            #define IonArg_Color1            Input_Color1
            #define IonArg_Color2            Input_Color2
            #define IonArg_Color3            Input_Color3
            #define IonArg_Color4            Input_Color4
            #define IonArg_EmissiveTex        Input_EmissiveTex
            #define IonArg_EmissiveIntensity  Input_EmissiveIntensity
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
            #define IonArg_BaseRampEnable  Input_BaseRampEnable
            #define IonArg_RimColor           Input_RimColor
            #define IonArg_RimPower           Input_RimPower
            #define IonArg_RimIntensity       Input_RimIntensity
            #define IonArg_BackRimColor        Input_BackRimColor
            #define IonArg_BackRimPower        Input_BackRimPower
            #define IonArg_BackRimIntensity    Input_BackRimIntensity
            #define IonArg_FixedRimPower       Input_FixedRimPower
            #define IonArg_FixedRimIntensity   Input_FixedRimIntensity
            #define Link_IonPassMainSimple
            // #include "../IonCoreUnity.hlsl"
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
            #define IonArg_BaseRampEnable  Input_BaseRampEnable
            #define IonArg_BackRimColor        Input_BackRimColor
            #define IonArg_BackRimPower        Input_BackRimPower
            #define IonArg_BackRimIntensity    Input_BackRimIntensity
            #define Link_IonPassMainAdd
            // #include "../IonCoreUnity.hlsl"
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
