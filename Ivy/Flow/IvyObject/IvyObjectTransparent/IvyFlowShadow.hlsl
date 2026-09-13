/****************************************

* 作者： 闪电黑客
* 日期： 2026/9/13

* 描述： IvyObjectTransparent 阴影投射配方

*/

#if Def(IvyFlowShadow)
#define Def_IvyFlowShadow

#define Link_IvyEnvBase
#define Link_IvyEnvLight
#define Link_IvyMatrix
#define Link_IvyVertex
#define Link_IvyGeom
#include "../../../Core/IvyKit.hlsl"
#include "IvyFlowPort.hlsl"

#ifndef Link_IvyFlowShadow
struct IvyFlowShadow_VertIn
{
    float4 PosOs;
    float3 NrmOs;
};

struct IvyFlowShadow_VertOut
{
    float4 PosCs;
    float3 LightVec;
};

struct IvyFlowShadow_FragIn
{
    IvyFlowShadow_VertOut VertOut;
};

struct IvyFlowShadow_FragOut
{
    float4 TargetRgba;
};
#endif

IvyFlowShadow_VertOut IvyFlowShadow_Vert(IvyFlowShadow_VertIn vertIn)
{
    IvyFlowShadow_VertOut vertOut;
    IvyVertex_PressOut press = IvyVertex_Press(vertIn.PosOs.xyz, vertIn.NrmOs, IvyArg_PressDepth, IvyArg_PressPos.xyz, IvyArg_PressRadius);
    float4 posOs = float4(press.PosOs, vertIn.PosOs.w);
    vertOut.PosCs = IvyEnvLight_ShadowCasterPositionCS(posOs, press.NrmOs);
    vertOut.LightVec = IvyEnvLight_ShadowCasterVector(posOs);
    return vertOut;
}

IvyFlowShadow_FragOut IvyFlowShadow_Frag(IvyFlowShadow_FragIn fragIn)
{
    IvyFlowShadow_FragOut fragOut;
    half enc = IvyEnvLight_ShadowCasterFragment(fragIn.VertOut.LightVec);
    fragOut.TargetRgba = half4(enc, 0, 0, 0);
    return fragOut;
}

#endif // Def_IvyFlowShadow
