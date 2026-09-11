/****************************************
*
* 描述： BRP 三角细分 GPU 入口壳
*        控制点语义、Hull / Domain 入口
*
*/

#if DefPart(IvyTess, Library)
#define Def_IvyTess_Library

#ifdef UNITY_CAN_COMPILE_TESSELLATION

/// <summary>
/// Unity 细分控制点。INTERNALTESSPOS 为 Unity 专用位置语义。
/// </summary>
struct IvyTess_GpuPoint
{
    float4 PosOs : INTERNALTESSPOS;
    float3 NrmOs : NORMAL;
    float2 Uv : TEXCOORD0;
};

/// <summary>
/// Hull 常量输出。edge / inside 为 DX 细分因子语义。
/// </summary>
struct IvyTess_GpuFactors
{
    float edge[3] : SV_TessFactor;
    float inside : SV_InsideTessFactor;
};

/// <summary>
/// 装箱为 GPU 控制点，供 TessVert 返回。
/// </summary>
IvyTess_GpuPoint IvyTess_PackGpu(float4 posOs, float3 nrmOs, float2 uv)
{
    IvyTess_GpuPoint pointOut;
    pointOut.PosOs = posOs;
    pointOut.NrmOs = nrmOs;
    pointOut.Uv = uv;
    return pointOut;
}

/// <summary>
/// 生成三角 Hull 入口壳 IvyTess_Hull / IvyTess_HullConst。
/// hullName(IvyTess_Point) 直通或改控制点；constFn(pos0,pos1,pos2) 返回细分因子。
/// #pragma hull IvyTess_Hull
/// </summary>
#define IvyTess_HullTri(hullName, constFn) \
    [UNITY_domain("tri")] \
    [UNITY_partitioning("fractional_odd")] \
    [UNITY_outputtopology("triangle_cw")] \
    [UNITY_patchconstantfunc("IvyTess_HullConst")] \
    [UNITY_outputcontrolpoints(3)] \
    IvyTess_GpuPoint IvyTess_Hull(InputPatch<IvyTess_GpuPoint, 3> patch, uint id : SV_OutputControlPointID) \
    { \
        IvyTess_Point pointIn; \
        pointIn.PosOs = patch[id].PosOs; \
        pointIn.NrmOs = patch[id].NrmOs; \
        pointIn.Uv = patch[id].Uv; \
        IvyTess_Point pointOut = hullName(pointIn); \
        IvyTess_GpuPoint gpuOut; \
        gpuOut.PosOs = pointOut.PosOs; \
        gpuOut.NrmOs = pointOut.NrmOs; \
        gpuOut.Uv = pointOut.Uv; \
        return gpuOut; \
    } \
    IvyTess_GpuFactors IvyTess_HullConst(InputPatch<IvyTess_GpuPoint, 3> patch) \
    { \
        float factor = constFn(patch[0].PosOs.xyz, patch[1].PosOs.xyz, patch[2].PosOs.xyz); \
        IvyTess_GpuFactors factorsOut; \
        factorsOut.edge[0] = factor; \
        factorsOut.edge[1] = factor; \
        factorsOut.edge[2] = factor; \
        factorsOut.inside = factor; \
        return factorsOut; \
    }

/// <summary>
/// 生成三角 Domain 入口壳 IvyTess_Domain：重心插值后调用 domainName(IvyTess_Point)。
/// #pragma domain IvyTess_Domain
/// </summary>
#define IvyTess_DomainTri(domainName, outType) \
    [UNITY_domain("tri")] \
    outType IvyTess_Domain(IvyTess_GpuFactors factors, const OutputPatch<IvyTess_GpuPoint, 3> patch, float3 bary : SV_DomainLocation) \
    { \
        IvyTess_Point a; \
        a.PosOs = patch[0].PosOs; \
        a.NrmOs = patch[0].NrmOs; \
        a.Uv = patch[0].Uv; \
        IvyTess_Point b; \
        b.PosOs = patch[1].PosOs; \
        b.NrmOs = patch[1].NrmOs; \
        b.Uv = patch[1].Uv; \
        IvyTess_Point c; \
        c.PosOs = patch[2].PosOs; \
        c.NrmOs = patch[2].NrmOs; \
        c.Uv = patch[2].Uv; \
        return domainName(IvyTess_Lerp(a, b, c, bary)); \
    }

#endif

#endif
