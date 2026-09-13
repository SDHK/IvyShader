/****************************************

* 作者： 闪电黑客
* 日期： 2026/9/13

* 描述： IvyObjectTransparent 描边配方

*/

#if Def(IvyFlowOutline)
#define Def_IvyFlowOutline

#define Link_IvyEnvBase
#define Link_IvyMatrix
#define Link_IvyVertex
#define Link_IvyGeom
#include "../../../Core/IvyKit.hlsl"
#include "IvyFlowPort.hlsl"

struct IvyFlowOutline_VertIn
{
    float4 PosOs;
    float3 NrmOs;
};

struct IvyFlowOutline_VertOut
{
    float4 PosCs;
};

IvyFlowOutline_VertOut IvyFlowOutline_Vert(IvyFlowOutline_VertIn vertIn)
{
    IvyFlowOutline_VertOut vertOut;
    IvyVertex_PressOut press = IvyVertex_Press(vertIn.PosOs.xyz, vertIn.NrmOs, IvyArg_PressDepth, IvyArg_PressPos.xyz, IvyArg_PressRadius);
    float3 posOs = IvyVertex_Scale(float4(press.PosOs, 1.0), press.NrmOs, IvyArg_Scale);
    vertOut.PosCs = IvyMatrix_PosOsToCs(float4(posOs, 1.0));
    return vertOut;
}

struct IvyFlowOutline_FragIn
{
    IvyFlowOutline_VertOut VertOut;
};

struct IvyFlowOutline_FragOut
{
    float4 TargetRgba;
};

IvyFlowOutline_FragOut IvyFlowOutline_Frag(IvyFlowOutline_FragIn fragIn)
{
    IvyFlowOutline_FragOut fragOut;
    fragOut.TargetRgba = IvyArg_Color;
    return fragOut;
}

#endif // Def_IvyFlowOutline
