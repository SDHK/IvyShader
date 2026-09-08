
HLSLINCLUDE
#define IvyShader
ENDHLSL

Shader "Ivy/DepthOnlyProxyBrp"
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
        //     // #define IvyArg_MainTex    Input_MainTex
        //     #define IvyArg_MainTex_ST Input_MainTex_ST
        //     #define IvyArg_Cutoff     Input_Cutoff
        //     #define Link_IvyPassDepthPre
        //     #include "../IvyCoreUnity.hlsl"
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
            #define IvyArg_Scale Input_Scale 
            // #define Link_IvyPassShadowCaster
            // #include "../IvyCoreUnity.hlsl"
            ENDHLSL
        }
    }
    FallBack Off
}
