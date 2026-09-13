/****************************************
*
* 作者： 闪电黑客
* 日期： 2026/9/13
*
* 说明： URP 环境履约 · 光照
*
* 合同方法使用 IvyEnvLight_ 前缀
* 本管线私货使用 IvyUrpLight_ 前缀，不得进入 Flow
*
*/

#if Def(IvyEnvLight)
#define Def_IvyEnvLight

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

float3 _LightDirection;
float3 _LightPosition;

//===[管线私货]===

IvyStruct_LightData IvyUrpLight_FromUrp(Light urpLight)
{
    IvyStruct_LightData light;
    light.Dir = urpLight.direction;
    light.Rgb = urpLight.color;
    light.DistAtten = urpLight.distanceAttenuation;
    light.ShadowAtten = urpLight.shadowAttenuation;
    return light;
}

//===[合同]===

IvyStruct_LightData IvyEnvLight_GetMainLight(float4 shadowCoord)
{
    return IvyUrpLight_FromUrp(GetMainLight(shadowCoord));
}

IvyStruct_LightData IvyEnvLight_GetMainLight(float4 shadowCoord, float3 posWs)
{
    return IvyEnvLight_GetMainLight(shadowCoord);
}

uint IvyEnvLight_GetAddLightCount()
{
    return GetAdditionalLightsCount();
}

IvyStruct_LightData IvyEnvLight_GetAddLight(uint index, float3 posWs)
{
    return IvyUrpLight_FromUrp(GetAdditionalLight(index, posWs));
}

half3 IvyEnvLight_LightSH(float3 nrmWs)
{
    return SampleSH(nrmWs);
}

half3 IvyEnvLight_ProbeReflect(float3 reflectWs, half mipMap)
{
    half4 encoded = SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, reflectWs, mipMap);
    return DecodeHDREnvironment(encoded, unity_SpecCube0_HDR);
}

float4 IvyEnvLight_ShadowCoord(float4 positionOS, float4 positionCS, float3 positionWS)
{
    return TransformWorldToShadowCoord(positionWS);
}

float4 IvyEnvLight_ShadowCasterPositionCS(float4 positionOS, float3 normalOS)
{
    float3 positionWS = TransformObjectToWorld(positionOS.xyz);
#if defined(_CASTING_PUNCTUAL_LIGHT_SHADOW)
    float3 lightDirectionWS = normalize(_LightPosition - positionWS);
#else
    float3 lightDirectionWS = _LightDirection;
#endif
    positionWS = positionWS + lightDirectionWS * _ShadowBias.xxx;
    float4 positionCS = TransformWorldToHClip(positionWS);
#if UNITY_REVERSED_Z
    positionCS.z = min(positionCS.z, UNITY_NEAR_CLIP_VALUE);
#else
    positionCS.z = max(positionCS.z, UNITY_NEAR_CLIP_VALUE);
#endif
    return positionCS;
}

float3 IvyEnvLight_ShadowCasterVector(float4 positionOS)
{
    return float3(0, 0, 0);
}

half IvyEnvLight_ShadowCasterFragment(float3 vec)
{
    return 0;
}

#endif // Def_IvyEnvLight
