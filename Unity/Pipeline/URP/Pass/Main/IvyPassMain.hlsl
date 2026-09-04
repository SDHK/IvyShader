/****************************************
*
* 作者： 闪电黑客
* 日期： 2026/1/19
*
* 描述： IvyPassMain - 完整光照 Pass
*        支持主光源（平行光）+ 附加光源（点光、聚光）
*
****************************************/

#if Def(IvyPassMain)
#define Def_IvyPassMain

#if PassVar(MainTex)
#error "IvyPassMain 缺少必要的参数定义：MainTex"
#endif

#if PassVar(MainTex_ST)
#error "IvyPassMain 缺少必要的参数定义：MainTex_ST"
#endif

sampler2D PassVar_MainTex;
float4 PassVar_MainTex_ST;

// 实例化支持
#define IvyKey_Instancing

// 雾效支持
#define IvyKey_Fog

// 主光源阴影支持
#define IvyKey_MainLightShadows
#define IvyKey_MainLightShadowsCascade
#define IvyKey_ShadowsSoft

// 附加光源支持（点光源、聚光灯）
#define IvyKey_AdditionalLights
#define IvyKey_AdditionalLightShadows

// 阴影设置
#define IvySet_ShadowScreen

#define Link_IvyBase
#define Link_IvyLight
#define Link_IvyMatrix
#define Link_IvyMath
#define Link_IvyVertex
#define Link_IvyUv
#include "../../Core/IvyCore.hlsl"


#pragma vertex vert
#pragma fragment frag

struct VertData
{
    IvyVar_PosOs
    IvyVar_NrmOs
    IvyVar_T0(float2, UV)
};

struct FragData
{
    IvyVar_PosCs
    IvyVar_T0(float2, UV)
    IvyVar_T1(float3, NormalWs)
    IvyVar_T2(float3, PositionWs)
};

FragData vert(VertData vertData)
{
    FragData fragData;
    
    // 计算UV坐标
    fragData.UV = IvyUv_Transform2D(vertData.UV.xy, PassVar_MainTex_ST.xy, PassVar_MainTex_ST.zw);
    
    // 计算裁剪空间位置
    fragData.PosCs = IvyMatrix_PosOsToCs(vertData.PosOs);
    
    // 将法线转换到世界空间
    fragData.NormalWs = IvyMatrix_NrmOsToWs(vertData.NrmOs);
    
    // 计算世界空间位置
    fragData.PositionWs = IvyMatrix_ObjectToWorld(vertData.PosOs);
    
    return fragData;
}

half4 frag(FragData fragData) : SV_Target
{
    // 采样主贴图颜色
    half4 mainTex = tex2D(_MainTex, fragData.UV);
    
    // 归一化法线
    float3 normalWs = normalize(fragData.NormalWs);
    
    // === 主光源（平行光）===
    // 注意：主光源使用 IvyLight_LambertSimple（不包含距离衰减）
    // 原因：
    // 1. 平行光在物理上没有距离衰减（无限远光源），distanceAttenuation 理论上总是 1.0
    // 2. URP 的 Forward+ 渲染路径存在已知 Bug：GetMainLight().distanceAttenuation 可能错误返回 0，导致场景全黑
    // 3. 使用 Simple 版本既避免了 Bug，又在语义上更清晰地表达"无距离衰减"
    float4 shadowCoord = TransformWorldToShadowCoord(fragData.PositionWs);
    Light mainLight = GetMainLight(shadowCoord);
    half3 lighting = IvyLight_LambertSimple(normalWs, mainLight.direction, mainLight.color, mainLight.shadowAttenuation);
    
    // === 附加光源（点光源和聚光灯）===
    // 注意：附加光源使用 IvyRamp_Lambert（包含距离衰减）
    // 原因：点光源和聚光灯都有距离衰减，光照强度随距离递减
    #ifdef _ADDITIONAL_LIGHTS
        half4 shadowMask = half4(1.0h, 1.0h, 1.0h, 1.0h);

        uint pixelLightCount = GetAdditionalLightsCount();
        for (uint lightIndex = 0u; lightIndex < pixelLightCount; ++lightIndex)
        {
            // 获取附加光源信息
            Light light = GetAdditionalLight(lightIndex, fragData.PositionWs,shadowMask);
            
            // 计算光照贡献（包含距离衰减）
            half3 additionalLighting = IvyRamp_Lambert(
                normalWs, 
                light.direction, 
                light.color, 
                light.shadowAttenuation, 
                light.distanceAttenuation
            );
            
            lighting += additionalLighting;
        }
    #endif
    
    // === 环境光 ===
    float3 ambient = IvyParam_AmbientSky.rgb;
    
    // === 最终光照 ===
    float3 finalColor = mainTex.rgb * lighting + mainTex.rgb * ambient;
    
    return half4(finalColor, mainTex.a);
}

#endif // Def(IvyPassMain)
