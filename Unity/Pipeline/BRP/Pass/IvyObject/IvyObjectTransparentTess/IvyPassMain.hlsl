/****************************************

* 作者： 闪电黑客
* 日期： 2026/9/13

* 描述： IvyObjectTransparentTess BRP 主光 Pass 适配

*/

#if Def(IvyPassMain)
#define Def_IvyPassMain

#define IvyKey_Instancing
#define IvyKey_Fog
#define IvyKey_ForwardBase
#define IvyKey_MainLightShadows
#define IvyKey_MainLightShadowsCascade
#define IvyKey_ShadowsSoft

#include "../../../Core/IvyStruct.hlsl"

struct IvyFlowMain_VertIn
{
    IvyVar_PosOs
    IvyVar_NrmOs
    IvyVar_T0(float2, Uv)
};

struct IvyFlowMain_VertOut
{
    IvyVar_PosCs
    IvyVar_T0(float2, Uv)
    IvyVar_T1(float3, NrmOs)
    IvyVar_T2(float3, PosOs)
    IvyVar_T3(float3, NrmWs)
    IvyVar_T4(float3, PosWs)
};

struct IvyFlowMain_FragIn
{
    IvyFlowMain_VertOut VertOut;
    IvyVar_ViewFace
};

struct IvyFlowMain_FragOut { IvyVar_TargetRgba };

#define Link_IvyEnvBase
#define Link_IvyEnvLight
#define Link_IvyFlowMain
#include "../../../Core/IvyCore.hlsl"
#include "IvyPassPort.hlsl"

IvyFlowMain_VertOut Vert(IvyFlowMain_VertIn vertIn)
{
    return IvyFlowMain_Vert(vertIn);
}

IvyFlowMain_FragOut Frag(IvyFlowMain_FragIn fragIn)
{
    return IvyFlowMain_Frag(fragIn);
}

#ifdef UNITY_CAN_COMPILE_TESSELLATION
IvyTess_GpuPoint TessVert(IvyFlowMain_VertIn vertIn)
{
    return IvyTess_PackGpu(vertIn.PosOs, vertIn.NrmOs, vertIn.Uv);
}
IvyTess_Point Hull(IvyTess_Point pointIn)
{
    return pointIn;
}
float HullConst(float3 pos0, float3 pos1, float3 pos2)
{
    return IvyTess_Factor(pos0, pos1, pos2, IvyArg_PressDepth, IvyArg_PressPos.xyz, IvyArg_PressRadius, IvyArg_TessFactor);
}
IvyFlowMain_VertOut Domain(IvyTess_Point pointIn)
{
    IvyFlowMain_VertIn vertIn;
    vertIn.PosOs = pointIn.PosOs;
    vertIn.NrmOs = pointIn.NrmOs;
    vertIn.Uv = pointIn.Uv;
    return Vert(vertIn);
}
#endif

#ifdef UNITY_CAN_COMPILE_TESSELLATION
#pragma target 4.6
#pragma vertex TessVert

#pragma hull IvyTess_Hull
IvyTess_HullTri(Hull, HullConst)

#pragma domain IvyTess_Domain
IvyTess_DomainTri(Domain, IvyFlowMain_VertOut)
#else
#pragma vertex Vert
#endif
#pragma fragment Frag

#endif
