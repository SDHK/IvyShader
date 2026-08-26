#if Def(IonPassMainSimple)
#define Def_IonPassMainSimple

#if PassVar(MainTex)
#error "IonPassMainSimple 缺少必要的参数定义：MainTex"
#endif

#if PassVar(MainTex_ST)
#error "IonPassMainSimple 缺少必要的参数定义：MainTex_ST"
#endif

sampler2D PassVar_MainTex;
float4 PassVar_MainTex_ST;

#define IonKey_Instancing

#define IonKey_Fog
#define IonKey_MainLightShadows
#define IonKey_MainLightShadowsCascade
#define IonKey_ShadowsSoft

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
    IonVar_PosOs
    IonVar_NrmOs
    IonVar_T0(float2, UV)
};

struct FragData
{
    IonVar_PosCs
    IonVar_T0(float2, UV)
    IonVar_T1(float3, NormalWs)
    IonVar_T2(float3, PositionWs)
};

FragData vert(VertData vertData)
{
    FragData fragData;
    // 计算UV坐标
    fragData.UV = IonMath_Transform2D(vertData.UV.xy, PassVar_MainTex_ST.xy,PassVar_MainTex_ST.zw);
    // 计算世界空间位置
    fragData.PosCs = IonMatrix_PosOsToCs(vertData.PosOs);
    // 将法线转换到世界空间（使用法线专用函数）
    fragData.NormalWs = IonMatrix_NrmOsToWs(vertData.NrmOs);
    // 计算世界空间位置
    fragData.PositionWs = IonMatrix_ObjectToWorld(vertData.PosOs);
    return fragData;
}

half4 frag(FragData fragData) : SV_Target
{
    // 采样主贴图颜色
    half4 mainTex = tex2D(_MainTex, fragData.UV);
    // 获取主光源信息并计算阴影（统一接口，自动适配URP/BRP）
    Light mainLight = GetMainLight();
    // 计算 Lambert 光照（使用工具函数）
    half3 directLighting = IonLight_LambertSimple(fragData.NormalWs, mainLight.direction, mainLight.color, mainLight.shadowAttenuation);
    // 最终光照 = 直接光照 + 环境光
    float3 lighting = directLighting + IonParam_AmbientSky.rgb;
    // 应用光照
    mainTex.rgb *= lighting;
    return mainTex;
}

#endif// Def(IonPassMainSimple)