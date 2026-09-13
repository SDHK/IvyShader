/****************************************
*
* 作者： 闪电黑客
* 日期： 2026/9/13
*
* 说明： Ivy 环境合同 · 光照（灯 / SH / Probe / 阴影）
*
* 设计理念：
* - 本文件是合同：Flow / Stage / Pass 只认这里的 IvyEnvLight_ 名字
* - 管线私货不得使用 IvyEnvLight_ 前缀，应使用 IvyBrpLight_ / IvyUrpLight_
*
*/

#if Def(IvyEnvLight)
#define Def_IvyEnvLight

/// <summary>
/// 获取主光源数据
/// </summary>
/// <param name="shadowCoord">阴影坐标</param>
IvyStruct_LightData IvyEnvLight_GetMainLight(float4 shadowCoord)
{
    return (IvyStruct_LightData)0;
}

IvyStruct_LightData IvyEnvLight_GetMainLight(float4 shadowCoord, float3 posWs)
{
    return (IvyStruct_LightData)0;
}

/// <summary>
/// 获取附加光源数量
/// </summary>
uint IvyEnvLight_GetAddLightCount()
{
    return 0;
}

/// <summary>
/// 获取附加光源数据
/// </summary>
IvyStruct_LightData IvyEnvLight_GetAddLight(uint index, float3 posWs)
{
    return (IvyStruct_LightData)0;
}

/// <summary>
/// 获取环境光（球谐）
/// </summary>
half3 IvyEnvLight_LightSH(float3 nrmWs)
{
    return 0;
}

/// <summary>
/// 获取环境反射
/// </summary>
/// <param name="reflectWs">反射方向</param>
/// <param name="mipMap">MIP 级别</param>
half3 IvyEnvLight_ProbeReflect(float3 reflectWs, half mipMap)
{
    return 0;
}

/// <summary>
/// 计算阴影坐标（片元中调用，避免顶点插值）
/// </summary>
float4 IvyEnvLight_ShadowCoord(float4 positionOS, float4 positionCS, float3 positionWS)
{
    return 0;
}

/// <summary>
/// 阴影投射：裁剪空间位置
/// </summary>
float4 IvyEnvLight_ShadowCasterPositionCS(float4 positionOS, float3 normalOS)
{
    return 0;
}

/// <summary>
/// 阴影投射：光源到顶点的向量
/// </summary>
float3 IvyEnvLight_ShadowCasterVector(float4 positionOS)
{
    return 0;
}

/// <summary>
/// 阴影投射：片元编码
/// </summary>
half IvyEnvLight_ShadowCasterFragment(float3 vec)
{
    return 0;
}

#endif // Def_IvyEnvLight
