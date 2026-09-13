/****************************************

* 作者： 闪电黑客
* 日期： 2026/9/13

* 描述： IvyObjectTransparentTess URP 描边 Pass 适配

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

#ifdef UNITY_CAN_COMPILE_TESSELLATION
IvyTess_GpuPoint TessVert(IvyFlowOutline_VertIn vertIn)
{
    return IvyTess_PackGpu(vertIn.PosOs, vertIn.NrmOs, float2(0, 0));
}
#endif

#ifdef UNITY_CAN_COMPILE_TESSELLATION
#pragma target 4.6
#pragma vertex TessVert

#pragma hull IvyTess_Hull
IvyTess_HullTri(IvyFlowTess_Hull, IvyFlowTess_HullConst)

#pragma domain IvyTess_Domain
IvyTess_DomainTri(IvyFlowOutline_Domain, IvyFlowOutline_VertOut)
#else
#pragma vertex IvyFlowOutline_Vert
#endif
#pragma fragment IvyFlowOutline_Frag

#endif
