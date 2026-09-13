/****************************************

* 作者： 闪电黑客
* 日期： 2026/9/13

* 描述： IvyObjectTransparentTess BRP 阴影投射 Pass 适配

*/

#if Def(IvyPassShadowCaster)
#define Def_IvyPassShadowCaster

#define IvyKey_ShadowCaster

#include "../../../Core/IvyStruct.hlsl"

struct IvyFlow_VertIn
{
    IvyVar_PosOs
    IvyVar_NrmOs
};

struct IvyFlow_VertOut
{
    IvyVar_PosCs
    IvyVar_T0(float3, LightVec)
};

struct IvyFlow_FragIn
{
    IvyFlow_VertOut VertOut;
};

struct IvyFlow_FragOut { IvyVar_TargetRgba };

#define Link_IvyEnvBase
#define Link_IvyEnvLight
#define Link_IvyFlowShadow
#include "../../../Core/IvyCore.hlsl"

#ifdef UNITY_CAN_COMPILE_TESSELLATION
IvyTess_GpuPoint TessVert(IvyFlow_VertIn vertIn)
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
IvyTess_DomainTri(IvyFlow_Domain, IvyFlow_VertOut)
#else
#pragma vertex IvyFlow_Vert
#endif
#pragma fragment IvyFlow_Frag

#endif
