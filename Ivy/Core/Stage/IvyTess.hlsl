/****************************************
*
* 描述： 三角面曲面细分转接
*        装箱、重心插值。无 GPU 语义。
*        先加密再按压，小半径才能在稀网格上出圆坑
*
*/

#if DefPart(IvyTess, Stage)
#define Def_IvyTess_Stage

/// <summary>
/// 细分控制点载荷。无 GPU 语义，Hull / Domain 壳再绑到 GpuPoint。
/// </summary>
struct IvyTess_Point
{
    float4 PosOs;
    float3 NrmOs;
    float2 Uv;
};

/// <summary>
/// 把位置、法线、UV 装进控制点。
/// </summary>
IvyTess_Point IvyTess_Pack(float4 posOs, float3 nrmOs, float2 uv)
{
    IvyTess_Point pointOut;
    pointOut.PosOs = posOs;
    pointOut.NrmOs = nrmOs;
    pointOut.Uv = uv;
    return pointOut;
}

/// <summary>
/// 三角面重心插值。法线插值后归一化。
/// </summary>
/// <param name="bary">SV_DomainLocation，三顶点权重</param>
IvyTess_Point IvyTess_Lerp(IvyTess_Point a, IvyTess_Point b, IvyTess_Point c, float3 bary)
{
    IvyTess_Point pointOut;
    pointOut.PosOs = a.PosOs * bary.x + b.PosOs * bary.y + c.PosOs * bary.z;
    pointOut.NrmOs = a.NrmOs * bary.x + b.NrmOs * bary.y + c.NrmOs * bary.z;
    float nrmLen = length(pointOut.NrmOs);
    pointOut.NrmOs = (nrmLen > 1e-8) ? pointOut.NrmOs / nrmLen : float3(0, 0, 1);
    pointOut.Uv = a.Uv * bary.x + b.Uv * bary.y + c.Uv * bary.z;
    return pointOut;
}

#endif
