/****************************************
*
* 描述： URP 光照库转接层
*
****************************************/

#if DefPart(IvyLight, Library)
#define Def_IvyLight_Library

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

struct IvyStruct_Light
{
    half3 Direction;
    half3 Rgb;
    float DistAtten;
    half ShadowAtten;
    uint LayerMask;
};

float3 _LightDirection;
float3 _LightPosition;

IvyStruct_Light IvyLight_FromUrp(Light urpLight)
{
    IvyStruct_Light light;
    light.Direction = urpLight.direction;
    light.Rgb = urpLight.color;
    light.DistAtten = urpLight.distanceAttenuation;
    light.ShadowAtten = urpLight.shadowAttenuation;
    light.LayerMask = 0;
    return light;
}

float3 IvyLight_Direction(float3 positionWS)
{
    return GetMainLight().direction;
}

IvyStruct_Light IvyLight_MainLight()
{
    return IvyLight_FromUrp(GetMainLight());
}

IvyStruct_Light IvyLight_MainLight(float4 shadowCoord)
{
    return IvyLight_FromUrp(GetMainLight(shadowCoord));
}

float4 IvyLight_ShadowCoord(float4 positionOS, float4 positionCS, float3 positionWS)
{
    return TransformWorldToShadowCoord(positionWS);
}

half3 IvyLight_SH(float3 nrmWs)
{
    return SampleSH(nrmWs);
}

half3 IvyLight_Probe(float3 dirWs, half mip)
{
    half4 encoded = SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, dirWs, mip);
    return DecodeHDREnvironment(encoded, unity_SpecCube0_HDR);
}

float4 IvyShadowCaster_PositionCS(float4 positionOS, float3 normalOS)
{
    float3 positionWS = TransformObjectToWorld(positionOS.xyz);
    float3 normalWS = TransformObjectToWorldNormal(normalOS);
#if defined(_CASTING_PUNCTUAL_LIGHT_SHADOW)
    float3 lightDirectionWS = normalize(_LightPosition - positionWS);
#else
    float3 lightDirectionWS = _LightDirection;
#endif
    float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));
#if UNITY_REVERSED_Z
    positionCS.z = min(positionCS.z, UNITY_NEAR_CLIP_VALUE);
#else
    positionCS.z = max(positionCS.z, UNITY_NEAR_CLIP_VALUE);
#endif
    return positionCS;
}

float3 IvyShadowCaster_Vector(float4 positionOS)
{
    return float3(0, 0, 0);
}

half IvyShadowCaster_Fragment(float3 vec)
{
    return 0;
}

#endif // DefPart(IvyLight, Library)
