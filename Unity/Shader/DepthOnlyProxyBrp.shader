
HLSLINCLUDE
#define IonShader
ENDHLSL

Shader "Ion/DepthOnlyProxyBrp"
{
    Properties
    {
        Input_Scale      ("背",                        Range(0,2))  = 1
       
    }
    SubShader
    {
        Tags {"RenderType" = "Opaque" "Queue" = "Geometry" }

        // Pass
        // {
        //     Name "DEPTH_PREPASS"
        //     Tags { "LightMode" = "Always" }
        //     Cull Off
        //     ZWrite On
        //     ColorMask 0
        //     HLSLPROGRAM
        //     // #define IonArg_MainTex    Input_MainTex
        //     #define IonArg_MainTex_ST Input_MainTex_ST
        //     #define IonArg_Cutoff     Input_Cutoff
        //     #define Link_IonPassDepthPre
        //     #include "../IonCoreUnity.hlsl"
        //     ENDHLSL
        // }


        Pass
        {

            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }
            Cull Back
            ZWrite On
           // ZTest LEqual
            ColorMask 0
            HLSLPROGRAM
            #define IonArg_Scale Input_Scale 
            #define Link_IonPassShadowCaster
            #include "../IonCoreUnity.hlsl"
            ENDHLSL
        }
    }
    FallBack Off
}
