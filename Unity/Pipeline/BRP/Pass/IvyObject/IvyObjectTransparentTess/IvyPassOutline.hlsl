/****************************************

* 作者： 闪电黑客
* 日期： 2026/9/13

* 描述： IvyObjectTransparentTess BRP 描边 Pass 适配

*/

#if Def(IvyPassOutline)
#define Def_IvyPassOutline

#define Link_IvyEnvBase
#define Link_IvyFlowOutline
#include "../../../Core/IvyCore.hlsl"

struct VertIn
{
    IvyVar_PosOs
    IvyVar_NrmOs
};

struct VertOut
{
    IvyVar_PosCs
};

struct FragIn
{
    VertOut VertOut;
};

struct FragOut { IvyVar_TargetRgba };

VertOut Vert(VertIn vertIn)
{
    IvyFlowOutline_VertIn flowIn;
    flowIn.PosOs = vertIn.PosOs;
    flowIn.NrmOs = vertIn.NrmOs;
    IvyFlowOutline_VertOut flowOut = IvyFlowOutline_Vert(flowIn);

    VertOut vertOut;
    vertOut.PosCs = flowOut.PosCs;
    return vertOut;
}

FragOut Frag(FragIn fragIn)
{
    IvyFlowOutline_FragIn flowIn;
    flowIn.VertOut.PosCs = fragIn.VertOut.PosCs;
    IvyFlowOutline_FragOut flowOut = IvyFlowOutline_Frag(flowIn);

    FragOut fragOut;
    fragOut.TargetRgba = flowOut.TargetRgba;
    return fragOut;
}

#ifdef UNITY_CAN_COMPILE_TESSELLATION
IvyTess_GpuPoint TessVert(VertIn vertIn)
{
    return IvyTess_PackGpu(vertIn.PosOs, vertIn.NrmOs, float2(0, 0));
}
IvyTess_Point Hull(IvyTess_Point pointIn)
{
    return pointIn;
}
float HullConst(float3 pos0, float3 pos1, float3 pos2)
{
    return IvyTess_Factor(pos0, pos1, pos2, IvyArg_PressDepth, IvyArg_PressPos.xyz, IvyArg_PressRadius, IvyArg_TessFactor);
}
VertOut Domain(IvyTess_Point pointIn)
{
    VertIn vertIn;
    vertIn.PosOs = pointIn.PosOs;
    vertIn.NrmOs = pointIn.NrmOs;
    return Vert(vertIn);
}
#endif

#ifdef UNITY_CAN_COMPILE_TESSELLATION
#pragma target 4.6
#pragma vertex TessVert

#pragma hull IvyTess_Hull
IvyTess_HullTri(Hull, HullConst)

#pragma domain IvyTess_Domain
IvyTess_DomainTri(Domain, VertOut)
#else
#pragma vertex Vert
#endif
#pragma fragment Frag

#endif
