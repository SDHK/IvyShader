/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/16
*
* 描述： BRP 光照库转接层
* 
* 功能：统一管理 BRP 光照相关库的包含
*       包含 Lighting.cginc 和 AutoLight.cginc
*
*/

#if DefPart(IvyLight, Library)
#define Def_IvyLight_Library

#include "Lighting.cginc"
#include "AutoLight.cginc"


//光照阴影数据
struct IvyStruct_Light
{
    // 光源方向
    half3   Direction;
    // 光源颜色
    half3   Rgb;
    // 光源衰减
    float   DistAtten; 
    // 阴影衰减
    half    ShadowAtten;
    // 阴影层级
    uint    LayerMask;
};


//===[光源获取]===

// 获取光源方向（统一接口，用于 ForwardBase 和 ForwardAdd）
// 参数：positionWS - 世界空间位置（float3）
// 返回值：归一化的光源方向（float3）
// 说明：BRP中 _WorldSpaceLightPos0.w = 0 表示平行光，w = 1 表示点光源/聚光灯
//       平行光：直接使用 _WorldSpaceLightPos0.xyz
//       点光源/聚光灯：从光源位置到顶点位置的方向
float3 IvyLight_Direction(float3 positionWS)
{
    float4 lightPos = _WorldSpaceLightPos0;
    
    // w = 0：平行光，直接返回方向
    // w = 1：点光源/聚光灯，计算从顶点指向光源的方向
    float3 lightDir = lightPos.xyz - positionWS * lightPos.w;
    return normalize(lightDir);
}

// 获取主光源信息（无阴影支持版本）
// 返回值：IvyStruct_Light 结构体，包含光源方向、颜色、衰减等信息
// 说明：BRP中 _WorldSpaceLightPos0.w = 0 表示方向光，w = 1 表示点光源
IvyStruct_Light IvyLight_MainLight()
{
    IvyStruct_Light light;
    
    float4 lightPos = _WorldSpaceLightPos0;

    light.Direction = lightPos.xyz;
    light.DistAtten = 1.0; // 需要根据距离计算
    
    // BRP中 _LightColor0 的 RGB 是颜色，A 无用
    light.Rgb = _LightColor0.rgb;

    // BRP中阴影衰减需要采样阴影贴图，这里默认设为1.0
    // 如果需要阴影，需要使用带参数的版本
    light.ShadowAtten = 1.0;
    
    // BRP中没有LayerMask概念，设为0
    light.LayerMask = 0;
    
    return light;
}

// 获取主光源信息（带阴影支持版本）
// 参数：shadowCoord - 阴影坐标，用于采样阴影贴图
// 返回值：IvyStruct_Light 结构体，包含光源信息和阴影衰减
IvyStruct_Light IvyLight_MainLight(float4 shadowCoord)
{
    IvyStruct_Light light = IvyLight_MainLight();
    #if defined(SHADOWS_SCREEN)
        // 屏幕空间阴影（不透明物体默认路径）
        #if defined(UNITY_NO_SCREENSPACE_SHADOWS)
            #if defined(SHADOWS_NATIVE)
                light.ShadowAtten = UNITY_SAMPLE_SHADOW(_ShadowMapTexture, shadowCoord.xyz);
                light.ShadowAtten = _LightShadowData.r + light.ShadowAtten * (1-_LightShadowData.r);
            #else
                unityShadowCoord dist = SAMPLE_DEPTH_TEXTURE(_ShadowMapTexture, shadowCoord.xy);
                unityShadowCoord threshold = shadowCoord.z;
                light.ShadowAtten = max(dist > threshold, _LightShadowData.x);
            #endif
        #else
            light.ShadowAtten = UNITY_SAMPLE_SCREEN_SHADOW(_ShadowMapTexture, shadowCoord);
        #endif
    #elif defined(SHADOWS_DEPTH) && !defined(SPOT) && !defined(UNITY_PASS_SHADOWCASTER)
        // Light-space 方向光级联阴影（透明物体兼容路径，不依赖屏幕深度缓冲）
        // UNITY_PASS_SHADOWCASTER 排除：ShadowCaster Pass 也带 SHADOWS_DEPTH，但不需要采样
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

// 计算光照衰减（ForwardAdd Pass 专用，在 fragment shader 中调用）
// 参数：lightCoord - 光照坐标（float4），由 IvyLight_LightCoord 计算
// 参数：shadowCoord - 阴影坐标（float4），由 IvyLight_ShadowCoord 计算
// 返回值：衰减值（float），包含距离衰减和阴影衰减的组合
// 说明：此函数用于 ForwardAdd Pass，计算点光源和聚光灯的衰减
//       包含距离衰减、Cookie、阴影衰减等所有因素
float IvyLight_Attenuation(float4 lightCoord, float4 shadowCoord)
{
    // 计算阴影衰减
    float shadowAttenuation = 1.0;
    #if defined(SHADOWS_DEPTH) && defined(SPOT)
        // 聚光灯阴影：使用深度贴图采样
        shadowAttenuation = UnitySampleShadowmap(shadowCoord);
    #elif defined(SHADOWS_CUBE)
        // 点光源立方体阴影：使用立方体贴图采样
        shadowAttenuation = UnitySampleShadowmap(shadowCoord.xyz);
    #endif
    
    // 计算距离衰减
    float distanceAttenuation = 1.0;
    #if defined(POINT)
        // 点光源：使用光照纹理采样距离衰减
        distanceAttenuation = tex2D(_LightTexture0, dot(lightCoord.xyz, lightCoord.xyz).rr).r;
    #elif defined(SPOT)
        // 聚光灯：计算距离衰减、Cookie 和聚光锥衰减
        distanceAttenuation = (lightCoord.z > 0.0) * UnitySpotCookie(lightCoord) * UnitySpotAttenuate(lightCoord.xyz);
    #endif
    
    // 返回组合衰减：距离衰减 * 阴影衰减
    return distanceAttenuation * shadowAttenuation;
}


//===[光照坐标计算] ===
// ForwardAdd Pass 需要计算光照坐标（用于距离衰减）
// 对应 Unity 的 COMPUTE_LIGHT_COORDS 宏

// 计算光照坐标（在 vertex shader 中调用）
// 参数：positionOS - 物体空间位置（float4）
// 返回值：光照坐标（float4），用于后续计算距离衰减
// 说明：点光源返回 float3（xyz），聚光灯返回 float4（xyzw），平行光返回 (0,0,0,0)
float4 IvyLight_LightCoord(float4 positionOS)
{
    #if defined(POINT)
        // 点光源：返回世界空间到光源空间的变换（float3）
        float3 lightCoord3 = mul(unity_WorldToLight, mul(unity_ObjectToWorld, positionOS)).xyz;
        return float4(lightCoord3, 0.0);
    #elif defined(SPOT)
        // 聚光灯：返回世界空间到光源空间的变换（float4）
        return mul(unity_WorldToLight, mul(unity_ObjectToWorld, positionOS));
    #elif defined(POINT_COOKIE)
        // 点光源 Cookie：返回世界空间到光源空间的变换（float3）
        float3 lightCoord3 = mul(unity_WorldToLight, mul(unity_ObjectToWorld, positionOS)).xyz;
        return float4(lightCoord3, 0.0);
    #elif defined(DIRECTIONAL_COOKIE)
        // 平行光 Cookie：返回世界空间到光源空间的变换（float2）
        float2 lightCoord2 = mul(unity_WorldToLight, mul(unity_ObjectToWorld, positionOS)).xy;
        return float4(lightCoord2, 0.0, 0.0);
    #else
        // 平行光或无光源：不需要光照坐标
        return float4(0, 0, 0, 0);
    #endif
}

//===[阴影接收相关方法] ===
// 这些方法用于在Forward Pass中接收阴影

// 计算并返回阴影坐标（片元中调用，避免顶点插值）
// 参数：positionOS - 物体空间位置
// 参数：positionCS - 裁剪空间位置（屏幕空间阴影用）
// 参数：positionWS - 世界空间位置
float4 IvyLight_ShadowCoord(float4 positionOS, float4 positionCS, float3 positionWS)
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



//===[阴影投射相关方法] ===
// 这些方法用于 ShadowCaster Pass 中投射阴影

// 计算阴影投射顶点位置（在vertex shader中调用）
float4 IvyShadowCaster_PositionCS(float4 positionOS, float3 normalOS)
{
    #if defined(SHADOWS_CUBE) && !defined(SHADOWS_CUBE_IN_DEPTH_TEX)
        return UnityObjectToClipPos(positionOS);
    #else
        // 不用 UnityClipSpaceShadowCasterPos 的法线挤出：和描边同一套沿法线外扩，
        // 会把网格轮廓打进 shadowmap，球体/低模自阴影交界呈锯齿。
        float4 positionCS = UnityObjectToClipPos(positionOS);
        return UnityApplyLinearShadowBias(positionCS);
    #endif
}

// 计算光源到顶点的向量（在vertex shader中调用）
float3 IvyShadowCaster_Vector(float4 positionOS)
{
    // 点光源阴影
    #if defined(SHADOWS_CUBE) && !defined(SHADOWS_CUBE_IN_DEPTH_TEX)
        return mul(unity_ObjectToWorld, positionOS).xyz - _LightPositionRange.xyz;
    #else // 定向光/聚光灯阴影不需要vec，返回0就行
        return float3(0, 0, 0);
    #endif
}

// 计算阴影投射顶点的颜色（在fragment shader中调用）
half IvyShadowCaster_Fragment(float3 vec)
{
    // 点光源立方体阴影
    #if defined(SHADOWS_CUBE) && !defined(SHADOWS_CUBE_IN_DEPTH_TEX)
    return UnityEncodeCubeShadowDepth((length(vec) + unity_LightShadowBias.x) * _LightPositionRange.w);
    #else // 定向光/聚光灯阴影不需要距离衰减，返回0
    return 0;
    #endif
}





#endif // DefPart(IvyLight, Library)

