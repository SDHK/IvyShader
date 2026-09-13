/****************************************
*
* 作者： 闪电黑客
* 日期： 2026/9/13
*
* 说明： BRP 环境履约 · 光照
*
* 合同方法使用 IvyEnvLight_ 前缀
* 本管线私货使用 IvyBrpLight_ 前缀，不得进入 Flow
*
*/

#if Def(IvyEnvLight)
#define Def_IvyEnvLight

#include "Lighting.cginc"
#include "AutoLight.cginc"

//===[管线私货]===

float3 IvyBrpLight_Direction(float3 positionWS)
{
    float4 lightPos = _WorldSpaceLightPos0;
    float3 lightDir = lightPos.xyz - positionWS * lightPos.w;
    return normalize(lightDir);
}

IvyStruct_LightData IvyBrpLight_MainLight()
{
    IvyStruct_LightData light;
    float4 lightPos = _WorldSpaceLightPos0;
    light.Dir = lightPos.xyz;
    light.DistAtten = 1.0;
    light.Rgb = _LightColor0.rgb;
    light.ShadowAtten = 1.0;
    return light;
}

IvyStruct_LightData IvyBrpLight_MainLight(float4 shadowCoord)
{
    IvyStruct_LightData light = IvyBrpLight_MainLight();
    #if defined(SHADOWS_SCREEN)
        #if defined(UNITY_NO_SCREENSPACE_SHADOWS)
            #if defined(SHADOWS_NATIVE)
                light.ShadowAtten = UNITY_SAMPLE_SHADOW(_ShadowMapTexture, shadowCoord.xyz);
                light.ShadowAtten = _LightShadowData.r + light.ShadowAtten * (1 - _LightShadowData.r);
            #else
                unityShadowCoord dist = SAMPLE_DEPTH_TEXTURE(_ShadowMapTexture, shadowCoord.xy);
                unityShadowCoord threshold = shadowCoord.z;
                light.ShadowAtten = max(dist > threshold, _LightShadowData.x);
            #endif
        #else
            light.ShadowAtten = UNITY_SAMPLE_SCREEN_SHADOW(_ShadowMapTexture, shadowCoord);
        #endif
    #elif defined(SHADOWS_DEPTH) && !defined(SPOT) && !defined(UNITY_PASS_SHADOWCASTER)
        #if defined(SHADOWS_NATIVE)
            light.ShadowAtten = UNITY_SAMPLE_SHADOW(_ShadowMapTexture, shadowCoord.xyz);
        #else
            unityShadowCoord dist = SAMPLE_DEPTH_TEXTURE(_ShadowMapTexture, shadowCoord.xy);
            light.ShadowAtten = max(dist > shadowCoord.z, _LightShadowData.x);
        #endif
        light.ShadowAtten = _LightShadowData.r + light.ShadowAtten * (1 - _LightShadowData.r);
    #endif
    return light;
}

float IvyBrpLight_Attenuation(float4 lightCoord, float4 shadowCoord)
{
    float shadowAttenuation = 1.0;
    #if defined(SHADOWS_DEPTH) && defined(SPOT)
        shadowAttenuation = UnitySampleShadowmap(shadowCoord);
    #elif defined(SHADOWS_CUBE)
        shadowAttenuation = UnitySampleShadowmap(shadowCoord.xyz);
    #endif

    float distanceAttenuation = 1.0;
    #if defined(POINT)
        distanceAttenuation = tex2D(_LightTexture0, dot(lightCoord.xyz, lightCoord.xyz).rr).r;
    #elif defined(SPOT)
        distanceAttenuation = (lightCoord.z > 0.0) * UnitySpotCookie(lightCoord) * UnitySpotAttenuate(lightCoord.xyz);
    #endif

    return distanceAttenuation * shadowAttenuation;
}

float4 IvyBrpLight_LightCoord(float4 positionOS)
{
    #if defined(POINT)
        float3 lightCoord3 = mul(unity_WorldToLight, mul(unity_ObjectToWorld, positionOS)).xyz;
        return float4(lightCoord3, 0.0);
    #elif defined(SPOT)
        return mul(unity_WorldToLight, mul(unity_ObjectToWorld, positionOS));
    #elif defined(POINT_COOKIE)
        float3 lightCoord3 = mul(unity_WorldToLight, mul(unity_ObjectToWorld, positionOS)).xyz;
        return float4(lightCoord3, 0.0);
    #elif defined(DIRECTIONAL_COOKIE)
        float2 lightCoord2 = mul(unity_WorldToLight, mul(unity_ObjectToWorld, positionOS)).xy;
        return float4(lightCoord2, 0.0, 0.0);
    #else
        return float4(0, 0, 0, 0);
    #endif
}

float4 IvyBrpLight_LightCoord(float3 posWs)
{
    #if defined(POINT) || defined(POINT_COOKIE)
        return float4(mul(unity_WorldToLight, float4(posWs, 1.0)).xyz, 0.0);
    #elif defined(SPOT)
        return mul(unity_WorldToLight, float4(posWs, 1.0));
    #elif defined(DIRECTIONAL_COOKIE)
        return float4(mul(unity_WorldToLight, float4(posWs, 1.0)).xy, 0.0, 0.0);
    #else
        return float4(0, 0, 0, 0);
    #endif
}

//===[合同]===

IvyStruct_LightData IvyEnvLight_GetMainLight(float4 shadowCoord)
{
    return IvyBrpLight_MainLight(shadowCoord);
}

IvyStruct_LightData IvyEnvLight_GetMainLight(float4 shadowCoord, float3 posWs)
{
    IvyStruct_LightData light = IvyBrpLight_MainLight(shadowCoord);
    light.Dir = IvyBrpLight_Direction(posWs);
    #if defined(POINT) || defined(SPOT) || defined(POINT_COOKIE) || defined(DIRECTIONAL_COOKIE)
        light.DistAtten = IvyBrpLight_Attenuation(IvyBrpLight_LightCoord(posWs), shadowCoord);
        light.ShadowAtten = 1.0;
    #endif
    return light;
}

uint IvyEnvLight_GetAddLightCount()
{
    return 0;
}

IvyStruct_LightData IvyEnvLight_GetAddLight(uint index, float3 posWs)
{
    return (IvyStruct_LightData)0;
}

half3 IvyEnvLight_LightSH(float3 nrmWs)
{
    return ShadeSH9(float4(nrmWs, 1));
}

half3 IvyEnvLight_ProbeReflect(float3 reflectWs, half mipMap)
{
    half4 envRaw = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectWs, mipMap);
    return DecodeHDR(envRaw, unity_SpecCube0_HDR);
}

float4 IvyEnvLight_ShadowCoord(float4 positionOS, float4 positionCS, float3 positionWS)
{
    #if defined(SHADOWS_SCREEN)
        #if defined(UNITY_NO_SCREENSPACE_SHADOWS)
            return mul(unity_WorldToShadow[0], float4(positionWS, 1.0));
        #else
            return ComputeScreenPos(positionCS);
        #endif
    #elif defined(SHADOWS_DEPTH) && !defined(SPOT)
        return mul(unity_WorldToShadow[0], float4(positionWS, 1.0));
    #elif defined(SHADOWS_DEPTH) && defined(SPOT)
        return mul(unity_WorldToShadow[0], float4(positionWS, 1.0));
    #elif defined(SHADOWS_CUBE)
        float3 shadowCoord3 = positionWS - _LightPositionRange.xyz;
        return float4(shadowCoord3, 0.0);
    #else
        return float4(0, 0, 0, 0);
    #endif
}

float4 IvyEnvLight_ShadowCasterPositionCS(float4 positionOS, float3 normalOS)
{
    #if defined(SHADOWS_CUBE) && !defined(SHADOWS_CUBE_IN_DEPTH_TEX)
        return UnityObjectToClipPos(positionOS);
    #else
        float4 positionCS = UnityObjectToClipPos(positionOS);
        return UnityApplyLinearShadowBias(positionCS);
    #endif
}

float3 IvyEnvLight_ShadowCasterVector(float4 positionOS)
{
    #if defined(SHADOWS_CUBE) && !defined(SHADOWS_CUBE_IN_DEPTH_TEX)
        return mul(unity_ObjectToWorld, positionOS).xyz - _LightPositionRange.xyz;
    #else
        return float3(0, 0, 0);
    #endif
}

half IvyEnvLight_ShadowCasterFragment(float3 vec)
{
    #if defined(SHADOWS_CUBE) && !defined(SHADOWS_CUBE_IN_DEPTH_TEX)
        return UnityEncodeCubeShadowDepth((length(vec) + unity_LightShadowBias.x) * _LightPositionRange.w);
    #else
        return 0;
    #endif
}

#endif // Def_IvyEnvLight
