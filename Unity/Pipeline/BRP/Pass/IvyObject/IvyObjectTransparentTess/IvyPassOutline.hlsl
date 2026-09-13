/****************************************

* 作者： 闪电黑客
* 日期： 2026/9/13

* 描述： IvyObjectTransparentTess BRP 描边 Pass 适配

*/

#if Def(IvyPassOutline)
#define Def_IvyPassOutline

#include "../../../Core/IvyStruct.hlsl"

struct IvyFlowOutline_VertIn
{
    IvyVar_PosOs
    IvyVar_NrmOs
};

struct IvyFlowOutline_VertOut
{
    IvyVar_PosCs
};

struct IvyFlowOutline_FragIn
{
    IvyFlowOutline_VertOut VertOut;
};

struct IvyFlowOutline_FragOut { IvyVar_TargetRgba };

#define Link_IvyEnvBase
#define Link_IvyFlowOutline
#include "../../../Core/IvyCore.hlsl"

IvyFlowOutline_VertOut Vert(IvyFlowOutline_VertIn vertIn)
{
    return IvyFlowOutline_Vert(vertIn);
}

IvyFlowOutline_FragOut Frag(IvyFlowOutline_FragIn fragIn)
{
    return IvyFlowOutline_Frag(fragIn);
}

#ifdef UNITY_CAN_COMPILE_TESSELLATION
IvyTess_GpuPoint TessVert(IvyFlowOutline_VertIn vertIn)
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
IvyFlowOutline_VertOut Domain(IvyTess_Point pointIn)
{
    IvyFlowOutline_VertIn vertIn;
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
IvyTess_DomainTri(Domain, IvyFlowOutline_VertOut)
#else
#pragma vertex Vert
#endif
#pragma fragment Frag

#endif
