#if Def(IvyPassMainSimple)
#define Def_IvyPassMainSimple

#if PassVar(MainTex)
#error "IvyPassMainSimple 缺少必要的参数定义：MainTex"
#endif

#if PassVar(MainTex_ST)
#error "IvyPassMainSimple 缺少必要的参数定义：MainTex_ST"
#endif

sampler2D PassVar_MainTex;
float4 PassVar_MainTex_ST;

#define IvyKey_Instancing

#define IvyKey_Fog
#define IvyKey_MainLightShadows
#define IvyKey_MainLightShadowsCascade
#define IvyKey_ShadowsSoft

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
    fragData.UV = IvyUv_Transform2D(vertData.UV.xy, PassVar_MainTex_ST.xy,PassVar_MainTex_ST.zw);
    // 计算世界空间位置
    fragData.PosCs = IvyMatrix_PosOsToCs(vertData.PosOs);
    // 将法线转换到世界空间（使用法线专用函数）
    fragData.NormalWs = IvyMatrix_NrmOsToWs(vertData.NrmOs);
    // 计算世界空间位置
    fragData.PositionWs = IvyMatrix_ObjectToWorld(vertData.PosOs);
    return fragData;
}

half4 frag(FragData fragData) : SV_Target
{
    // 采样主贴图颜色
    half4 mainTex = tex2D(_MainTex, fragData.UV);
    // 获取主光源信息并计算阴影（统一接口，自动适配URP/BRP）
    Light mainLight = GetMainLight();
    // 计算 Lambert 光照（使用工具函数）
    half3 directLighting = IvyLight_LambertSimple(fragData.NormalWs, mainLight.direction, mainLight.color, mainLight.shadowAttenuation);
    // 最终光照 = 直接光照 + 环境光
    float3 lighting = directLighting + unity_AmbientSky.rgb;
    // 应用光照
    mainTex.rgb *= lighting;
    return mainTex;
}

#endif// Def(IvyPassMainSimple)