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
#include "IvyFlowVar.hlsl"

struct IvyFlow_VertIn
{
    float4 PosOs IvyVarIn_PosOs;
    float3 NrmOs IvyVarIn_NrmOs;
    float2 Uv IvyVarIn_Uv;
};

struct IvyFlow_VertOut
{
    float4 PosCs IvyVarOut_PosCs;
    float3 LightVec IvyVarOut_LightVec;
};

struct IvyFlow_FragIn
{
    IvyFlow_VertOut VertOut;
};

struct IvyFlow_FragOut
{
    float4 TargetRgba IvyVarOut_Target;
};

IvyFlow_VertOut IvyFlow_Vert(IvyFlow_VertIn vertIn)
{
    IvyFlow_VertOut vertOut;
    IvyVertex_PressOut press = IvyVertex_Press(vertIn.PosOs.xyz, vertIn.NrmOs, IvyArg_PressDepth, IvyArg_PressPos.xyz, IvyArg_PressRadius);
    float4 posOs = float4(press.PosOs, vertIn.PosOs.w);
    vertOut.PosCs = IvyEnvLight_ShadowCasterPositionCS(posOs, press.NrmOs);
    vertOut.LightVec = IvyEnvLight_ShadowCasterVector(posOs);
    return vertOut;
}

IvyFlow_FragOut IvyFlow_Frag(IvyFlow_FragIn fragIn)
{
    IvyFlow_FragOut fragOut;
    half enc = IvyEnvLight_ShadowCasterFragment(fragIn.VertOut.LightVec);
    fragOut.TargetRgba = half4(enc, 0, 0, 0);
    return fragOut;
}

#endif // Def_IvyFlowShadow
