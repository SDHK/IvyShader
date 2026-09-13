/****************************************

* 作者： 闪电黑客
* 日期： 2026/9/13

* 描述： IvyObjectTransparent BRP 阴影投射 Pass 适配

*/

#if Def(IvyPassShadowCaster)
#define Def_IvyPassShadowCaster

#define IvyKey_ShadowCaster

#define Link_IvyEnvBase
#define Link_IvyEnvLight
#define Link_IvyFlowShadow
#include "../../../Core/IvyCore.hlsl"

struct VertIn
{
    IvyVar_PosOs
    IvyVar_NrmOs
};

struct VertOut
{
    IvyVar_PosCs
    IvyVar_T0(float3, LightVec)
};

struct FragIn
{
    VertOut VertOut;
};

struct FragOut { IvyVar_TargetRgba };

VertOut Vert(VertIn vertIn)
{
    IvyFlowShadow_VertIn flowIn;
    flowIn.PosOs = vertIn.PosOs;
    flowIn.NrmOs = vertIn.NrmOs;
    IvyFlowShadow_VertOut flowOut = IvyFlowShadow_Vert(flowIn);

    VertOut vertOut;
    vertOut.PosCs = flowOut.PosCs;
    vertOut.LightVec = flowOut.LightVec;
    return vertOut;
}

FragOut Frag(FragIn fragIn)
{
    IvyFlowShadow_FragIn flowIn;
    flowIn.VertOut.PosCs = fragIn.VertOut.PosCs;
    flowIn.VertOut.LightVec = fragIn.VertOut.LightVec;
    IvyFlowShadow_FragOut flowOut = IvyFlowShadow_Frag(flowIn);

    FragOut fragOut;
    fragOut.TargetRgba = flowOut.TargetRgba;
    return fragOut;
}

#pragma vertex Vert
#pragma fragment Frag

#endif
