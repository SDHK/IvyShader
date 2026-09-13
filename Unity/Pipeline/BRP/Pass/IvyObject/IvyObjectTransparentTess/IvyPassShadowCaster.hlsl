/****************************************

* 作者： 闪电黑客
* 日期： 2026/9/13

* 描述： IvyObjectTransparentTess BRP 阴影投射 Pass 适配

*/

#if Def(IvyPassShadowCaster)
#define Def_IvyPassShadowCaster

#define IvyKey_ShadowCaster

#include "../../../Core/IvyStruct.hlsl"

struct IvyFlowShadow_VertIn
{
    IvyVar_PosOs
    IvyVar_NrmOs
};

struct IvyFlowShadow_VertOut
{
    IvyVar_PosCs
    IvyVar_T0(float3, LightVec)
};

struct IvyFlowShadow_FragIn
{
    IvyFlowShadow_VertOut VertOut;
};

struct IvyFlowShadow_FragOut { IvyVar_TargetRgba };

#define Link_IvyEnvBase
#define Link_IvyEnvLight
#define Link_IvyFlowShadow
#include "../../../Core/IvyCore.hlsl"

IvyFlowShadow_VertOut Vert(IvyFlowShadow_VertIn vertIn)
{
    return IvyFlowShadow_Vert(vertIn);
}

IvyFlowShadow_FragOut Frag(IvyFlowShadow_FragIn fragIn)
{
    return IvyFlowShadow_Frag(fragIn);
}

#ifdef UNITY_CAN_COMPILE_TESSELLATION
IvyTess_GpuPoint TessVert(IvyFlowShadow_VertIn vertIn)
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
IvyFlowShadow_VertOut Domain(IvyTess_Point pointIn)
{
    IvyFlowShadow_VertIn vertIn;
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
IvyTess_DomainTri(Domain, IvyFlowShadow_VertOut)
#else
#pragma vertex Vert
#endif
#pragma fragment Frag

#endif
