/****************************************

* 作者： 闪电黑客
* 日期： 2026/9/13

* 描述： IvyObjectTransparent BRP 描边 Pass 适配

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

#pragma vertex Vert
#pragma fragment Frag

#endif
