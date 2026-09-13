/****************************************

* 作者： 闪电黑客
* 日期： 2026/9/13

* 描述： IvyObjectTransparent BRP 附加光 Pass 适配

*/

#if Def(IvyPassAdd)
#define Def_IvyPassAdd

#define IvyKey_Instancing
#define IvyKey_Fog
#define IvyKey_ForwardAdd

#define Link_IvyEnvBase
#define Link_IvyEnvLight
#define Link_IvyFlowAdd
#include "../../../Core/IvyCore.hlsl"

float4 IvyFunc_ShadowCoord(IvyGeom_BuildOut geomOut)
{
    return IvyEnvLight_ShadowCoord(float4(geomOut.PosOs, 1.0), geomOut.PosCs, geomOut.PosWs);
}

half4 IvyFunc_SkinMask0(half2 uv) { return tex2D(IvyArg_SkinMask0, uv); }
half4 IvyFunc_SkinMask1(half2 uv) { return tex2D(IvyArg_SkinMask1, uv); }
half4 IvyFunc_SkinMask2(half2 uv) { return tex2D(IvyArg_SkinMask2, uv); }
half4 IvyFunc_SkinMask3(half2 uv) { return tex2D(IvyArg_SkinMask3, uv); }
half4 IvyFunc_FilmMaskTex(half2 uv) { return tex2D(IvyArg_FilmMaskTex, uv); }

half4 IvyFunc_EnvMapTex(half2 uv, half mipMap)
{
    return tex2Dlod(IvyArg_EnvMapTex, float4(uv, 0, mipMap));
}

half4 IvyFunc_MatCapTex(half2 uv, half mipMap)
{
    return tex2Dlod(IvyArg_MatCapTex, float4(uv, 0, mipMap));
}

struct VertIn
{
    IvyVar_PosOs
    IvyVar_NrmOs
    IvyVar_T0(float2, Uv)
};

struct VertOut
{
    IvyVar_PosCs
    IvyVar_T0(float2, Uv)
    IvyVar_T1(float3, NrmOs)
    IvyVar_T2(float3, PosOs)
    IvyVar_T3(float3, NrmWs)
    IvyVar_T4(float3, PosWs)
};

struct FragIn
{
    VertOut VertOut;
    IvyVar_ViewFace
};

struct FragOut { IvyVar_TargetRgba };

VertOut Vert(VertIn vertIn)
{
    IvyFlowAdd_VertIn flowIn;
    flowIn.PosOs = vertIn.PosOs;
    flowIn.NrmOs = vertIn.NrmOs;
    flowIn.Uv = vertIn.Uv;
    IvyFlowAdd_VertOut flowOut = IvyFlowAdd_Vert(flowIn);

    VertOut vertOut;
    vertOut.PosCs = flowOut.PosCs;
    vertOut.Uv = flowOut.Uv;
    vertOut.NrmOs = flowOut.NrmOs;
    vertOut.PosOs = flowOut.PosOs;
    vertOut.NrmWs = flowOut.NrmWs;
    vertOut.PosWs = flowOut.PosWs;
    return vertOut;
}

FragOut Frag(FragIn fragIn)
{
    IvyFlowAdd_FragIn flowIn;
    flowIn.VertOut.PosCs = fragIn.VertOut.PosCs;
    flowIn.VertOut.Uv = fragIn.VertOut.Uv;
    flowIn.VertOut.NrmOs = fragIn.VertOut.NrmOs;
    flowIn.VertOut.PosOs = fragIn.VertOut.PosOs;
    flowIn.VertOut.NrmWs = fragIn.VertOut.NrmWs;
    flowIn.VertOut.PosWs = fragIn.VertOut.PosWs;
    flowIn.ViewFace = fragIn.ViewFace;
    IvyFlowAdd_FragOut flowOut = IvyFlowAdd_Frag(flowIn);

    FragOut fragOut;
    fragOut.TargetRgba = flowOut.TargetRgba;
    return fragOut;
}

#pragma vertex Vert
#pragma fragment Frag

#endif
