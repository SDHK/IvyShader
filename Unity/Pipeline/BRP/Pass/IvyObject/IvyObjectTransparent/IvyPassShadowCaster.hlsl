/****************************************

* 作者： 闪电黑客
* 日期： 2026/9/13

* 描述： IvyObjectTransparent BRP 阴影投射 Pass 适配

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

#pragma vertex IvyFlowShadow_Vert
#pragma fragment IvyFlowShadow_Frag

#endif
