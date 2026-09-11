/****************************************
*
* 描述： URP 三角细分 GPU 入口壳
*        控制点语义、Hull / Domain 入口
*
****************************************/

#if DefPart(IvyTess, Library)
#define Def_IvyTess_Library

#ifdef UNITY_CAN_COMPILE_TESSELLATION

struct IvyTess_GpuPoint
{
    float4 PosOs : INTERNALTESSPOS;
    float3 NrmOs : NORMAL;
    float2 Uv : TEXCOORD0;
};

struct IvyTess_GpuFactors
{
    float edge[3] : SV_TessFactor;
    float inside : SV_InsideTessFactor;
};

IvyTess_GpuPoint IvyTess_PackGpu(float4 posOs, float3 nrmOs, float2 uv)
{
    IvyTess_GpuPoint pointOut;
    pointOut.PosOs = posOs;
    pointOut.NrmOs = nrmOs;
    pointOut.Uv = uv;
    return pointOut;
}

#define IvyTess_HullTri(hullName, constFn) \
    [domain("tri")] \
    [partitioning("fractional_odd")] \
    [outputtopology("triangle_cw")] \
    [patchconstantfunc("IvyTess_HullConst")] \
    [outputcontrolpoints(3)] \
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

#define IvyTess_DomainTri(domainName, outType) \
    [domain("tri")] \
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
