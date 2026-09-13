/****************************************

* 作者： 闪电黑客
* 日期： 2026/9/13

* 描述： IvyObjectTransparent BRP 描边 Pass 适配

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

#pragma vertex Vert
#pragma fragment Frag

#endif
