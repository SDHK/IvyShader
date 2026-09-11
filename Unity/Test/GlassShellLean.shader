Shader "Ivy/GlassShellLean"
{
    Properties
    {
        [Header(Glass)]
        Input_Color             ("玻璃颜色",            Color)      = (0.55, 0.80, 1.00, 1)
        Input_Alpha             ("透明度",              Range(0,1)) = 0.10
        Input_Refract           ("折射 玻璃到宝石",      Range(0,1)) = 0.35

        [Space(20)]
        [Header(Reflect)]
        Input_EnvTex            ("360环境图 2:1",       2D)         = "black" {}
        Input_EnvBlend          ("环境图混合",          Range(0,1)) = 0.0
        Input_FresnelIntensity  ("边缘强度",            Range(0,2)) = 0.90
        Input_Smoothness        ("光滑度",              Range(0,1)) = 0.85
        Input_SpecIntensity     ("高光强度",            Range(0,4)) = 1.0
        Input_ReflectIntensity  ("环境反射强度",        Range(0,2)) = 0.35
    }

    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
            "RenderType" = "Transparent"
            "IgnoreProjector" = "True"
            "ForceNoShadowCasting" = "True"
        }

        HLSLINCLUDE
        #include "UnityCG.cginc"
        #include "Lighting.cginc"
        #include "../../Ivy/IvyMacro.hlsl"
        #include "../../Ivy/Core/Stage/IvyTransmit.hlsl"

        float4 Input_Color;
        float  Input_Alpha;

        sampler2D Input_EnvTex;
        float  Input_EnvBlend;
        float  Input_Refract;

        float  Input_FresnelIntensity;
        float  Input_Smoothness;
        float  Input_SpecIntensity;
        float  Input_ReflectIntensity;

        struct IvyAttr_Glass
        {
            float4 PosOs : POSITION;
            float3 NrmOs : NORMAL;
            UNITY_VERTEX_INPUT_INSTANCE_ID
        };

        struct IvyVary_Glass
        {
            float4 PosCs : SV_POSITION;
            float3 NrmWs : TEXCOORD0;
            float3 PosWs : TEXCOORD1;
            UNITY_VERTEX_OUTPUT_STEREO
        };

        IvyVary_Glass IvyVert_Glass(IvyAttr_Glass attr)
        {
            IvyVary_Glass vary;
            UNITY_SETUP_INSTANCE_ID(attr);
            UNITY_INITIALIZE_OUTPUT(IvyVary_Glass, vary);
            UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(vary);

            vary.PosCs = UnityObjectToClipPos(attr.PosOs);
            vary.PosWs = mul(unity_ObjectToWorld, attr.PosOs).xyz;
            vary.NrmWs = UnityObjectToWorldNormal(attr.NrmOs);
            return vary;
        }

        half2 IvyDirToLatLongUv_Glass(half3 dirWs)
        {
            half3 dir = normalize(dirWs);
            half  latitude  = acos(clamp(dir.y, -1.0, 1.0));
            half  longitude = atan2(dir.z, dir.x);
            return half2(0.5, 1.0) - half2(longitude * (0.5 / UNITY_PI), latitude * (1.0 / UNITY_PI));
        }

        half3 IvyProbeRgb_Glass(half3 dirWs, half lod)
        {
            half4 probe = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, dirWs, lod);
            return DecodeHDR(probe, unity_SpecCube0_HDR);
        }

        half3 IvyPanoRgb_Glass(half3 dirWs, half lod)
        {
            return tex2Dlod(Input_EnvTex, float4(IvyDirToLatLongUv_Glass(dirWs), 0.0, lod)).rgb;
        }

        half3 IvyEnvRgb_Glass(half3 dirWs, half lod)
        {
            if (Input_EnvBlend < 0.001) { return IvyProbeRgb_Glass(dirWs, lod); }
            if (Input_EnvBlend > 0.999) { return IvyPanoRgb_Glass(dirWs, lod); }
            return lerp(IvyProbeRgb_Glass(dirWs, lod), IvyPanoRgb_Glass(dirWs, lod), Input_EnvBlend);
        }

        half4 IvyFrag_Glass(IvyVary_Glass vary, bool isFront : SV_IsFrontFace) : SV_Target
        {
            UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(vary);

            half3 nrmWs   = normalize(vary.NrmWs) * (isFront ? 1.0 : -1.0);
            half3 viewWs  = normalize(_WorldSpaceCameraPos - vary.PosWs);
            half3 lightWs = normalize(_WorldSpaceLightPos0.xyz);
            half  ndotv   = saturate(dot(nrmWs, viewWs));

            half fresnel = pow(1.0 - ndotv, 3.0);
            half envLod  = (1.0 - Input_Smoothness) * 6.0;

            half3 reflWs = reflect(-viewWs, nrmWs);
            half3 envRgb = IvyEnvRgb_Glass(reflWs, envLod) * Input_ReflectIntensity * lerp(0.15, 1.0, fresnel);

            half3 halfWs  = normalize(lightWs + viewWs);
            half  specPow = exp2(Input_Smoothness * 10.0) + 1.0;
            half3 specRgb = pow(saturate(dot(nrmWs, halfWs)), specPow) * Input_SpecIntensity;

            half3 baseRgb = Input_Color.rgb;
            half fresnelLit = fresnel * Input_FresnelIntensity;
            half3 reflectRgb = baseRgb * fresnelLit
                             + baseRgb * envRgb
                             + specRgb;

            half3 refractRgb = 0;
            half refractAmt = saturate(Input_Refract);
            if (isFront && refractAmt > 1e-4)
            {
                half ior = lerp(1.0, 2.42, refractAmt);
                half3 refrWs = refract(-viewWs, nrmWs, 1.0 / ior);
                refractRgb = IvyEnvRgb_Glass(refrWs, envLod);
            }

            IvyTransmit_BlendIn transmitIn;
            transmitIn.Rgb = baseRgb;
            transmitIn.Alpha = Input_Alpha;
            transmitIn.Refract = Input_Refract;
            transmitIn.IsFront = isFront;
            transmitIn.ReflectRgb = reflectRgb;
            transmitIn.RefractRgb = refractRgb;
            transmitIn.Fresnel = fresnelLit;
            half4 rgba = IvyTransmit_Blend(transmitIn).Rgba;
            rgba.rgb *= _LightColor0.rgb + ShadeSH9(float4(nrmWs, 1));
            return rgba;
        }
        ENDHLSL

        Pass
        {
            Name "INNER"
            Tags { "LightMode" = "ForwardBase" }
            Cull Front
            ZWrite Off
            ZTest LEqual
            Blend One OneMinusSrcAlpha

            HLSLPROGRAM
            #pragma vertex   IvyVert_Glass
            #pragma fragment IvyFrag_Glass
            #pragma target 3.0
            #pragma multi_compile_instancing
            ENDHLSL
        }

        Pass
        {
            Name "OUTER"
            Tags { "LightMode" = "ForwardBase" }
            Cull Back
            ZWrite Off
            ZTest LEqual
            Blend One OneMinusSrcAlpha

            HLSLPROGRAM
            #pragma vertex   IvyVert_Glass
            #pragma fragment IvyFrag_Glass
            #pragma target 3.0
            #pragma multi_compile_instancing
            ENDHLSL
        }
    }
    FallBack Off
}
