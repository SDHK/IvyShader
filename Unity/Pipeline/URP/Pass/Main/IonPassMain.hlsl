/****************************************
*
* 作者： 闪电黑客
* 日期： 2026/1/19
*
* 描述： IonPassMain - 完整光照 Pass
*        支持主光源（平行光）+ 附加光源（点光、聚光）
*
****************************************/

#if Def(IonPassMain)
#define Def_IonPassMain

#if PassVar(MainTex)
#error "IonPassMain 缺少必要的参数定义：MainTex"
#endif

#if PassVar(MainTex_ST)
#error "IonPassMain 缺少必要的参数定义：MainTex_ST"
#endif

sampler2D PassVar_MainTex;
float4 PassVar_MainTex_ST;

// 实例化支持
#define IonKey_Instancing

// 雾效支持
#define IonKey_Fog

// 主光源阴影支持
#define IonKey_MainLightShadows
#define IonKey_MainLightShadowsCascade
#define IonKey_ShadowsSoft

// 附加光源支持（点光源、聚光灯）
#define IonKey_AdditionalLights
#define IonKey_AdditionalLightShadows

// 阴影设置
#define IonSet_ShadowScreen

#define Link_IonBase
#define Link_IonLight
#define Link_IonMatrix
#define Link_IonMath
#define Link_IonVertex
#include "../../Core/IonCore.hlsl"


#pragma vertex vert
#pragma fragment frag

struct VertData
{
    IonVar_PositionOs
    IonVar_Normal
    IonVar_T0(float2, UV)
};

struct FragData
{
    IonVar_PositionCs
    IonVar_T0(float2, UV)
    IonVar_T1(float3, NormalWs)
    IonVar_T2(float3, PositionWs)
};

FragData vert(VertData vertData)
{
    FragData fragData;
    
    // 计算UV坐标
    fragData.UV = IonMath_Transform2D(vertData.UV.xy, PassVar_MainTex_ST.xy, PassVar_MainTex_ST.zw);
    
    // 计算裁剪空间位置
    fragData.PositionCs = IonMatrix_PosOsToCs(vertData.PositionOs);
    
    // 将法线转换到世界空间
    fragData.NormalWs = IonMatrix_NrmOsToWs(vertData.Normal);
    
    // 计算世界空间位置
    fragData.PositionWs = IonMatrix_ObjectToWorld(vertData.PositionOs);
    
    return fragData;
}

half4 frag(FragData fragData) : SV_Target
{
    // 采样主贴图颜色
    half4 mainTex = tex2D(_MainTex, fragData.UV);
    
    // 归一化法线
    float3 normalWs = normalize(fragData.NormalWs);
    
    // === 主光源（平行光）===
    // 注意：主光源使用 IonLight_LambertSimple（不包含距离衰减）
    // 原因：
    // 1. 平行光在物理上没有距离衰减（无限远光源），distanceAttenuation 理论上总是 1.0
    // 2. URP 的 Forward+ 渲染路径存在已知 Bug：GetMainLight().distanceAttenuation 可能错误返回 0，导致场景全黑
    // 3. 使用 Simple 版本既避免了 Bug，又在语义上更清晰地表达"无距离衰减"
    float4 shadowCoord = TransformWorldToShadowCoord(fragData.PositionWs);
    Light mainLight = GetMainLight(shadowCoord);
    half3 lighting = IonLight_LambertSimple(normalWs, mainLight.direction, mainLight.color, mainLight.shadowAttenuation);
    
    // === 附加光源（点光源和聚光灯）===
    // 注意：附加光源使用 IonLight_Lambert（包含距离衰减）
    // 原因：点光源和聚光灯都有距离衰减，光照强度随距离递减
    #ifdef _ADDITIONAL_LIGHTS
        half4 shadowMask = half4(1.0h, 1.0h, 1.0h, 1.0h);

        uint pixelLightCount = GetAdditionalLightsCount();
        for (uint lightIndex = 0u; lightIndex < pixelLightCount; ++lightIndex)
        {
            // 获取附加光源信息
            Light light = GetAdditionalLight(lightIndex, fragData.PositionWs,shadowMask);
            
            // 计算光照贡献（包含距离衰减）
            half3 additionalLighting = IonLight_Lambert(
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
    float3 ambient = IonParam_AmbientSky.rgb;
    
    // === 最终光照 ===
    float3 finalColor = mainTex.rgb * lighting + mainTex.rgb * ambient;
    
    return half4(finalColor, mainTex.a);
}

#endif // Def(IonPassMain)
