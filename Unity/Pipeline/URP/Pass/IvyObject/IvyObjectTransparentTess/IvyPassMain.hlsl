/****************************************

* 作者： 闪电黑客
* 日期： 2026/9/13

* 描述： IvyObjectTransparentTess URP 主光 Pass 适配

*/

#if Def(IvyPassMain)
#define Def_IvyPassMain

#define IvyKey_Instancing
#define IvyKey_Fog
#define IvyKey_MainLightShadows
#define IvyKey_MainLightShadowsCascade
#define IvyKey_ShadowsSoft
#define IvyKey_AdditionalLights
#define IvyKey_AdditionalLightShadows
#define _SURFACE_TYPE_TRANSPARENT

#define Link_IvyEnvBase
#define Link_IvyEnvLight
#define Link_IvyFlowMain
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
    IvyFlowMain_VertIn flowIn;
    flowIn.PosOs = vertIn.PosOs;
    flowIn.NrmOs = vertIn.NrmOs;
    flowIn.Uv = vertIn.Uv;
    IvyFlowMain_VertOut flowOut = IvyFlowMain_Vert(flowIn);

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
    IvyFlowMain_FragIn flowIn;
    flowIn.VertOut.PosCs = fragIn.VertOut.PosCs;
    flowIn.VertOut.Uv = fragIn.VertOut.Uv;
    flowIn.VertOut.NrmOs = fragIn.VertOut.NrmOs;
    flowIn.VertOut.PosOs = fragIn.VertOut.PosOs;
    flowIn.VertOut.NrmWs = fragIn.VertOut.NrmWs;
    flowIn.VertOut.PosWs = fragIn.VertOut.PosWs;
    flowIn.ViewFace = fragIn.ViewFace;
    IvyFlowMain_FragOut flowOut = IvyFlowMain_Frag(flowIn);

    FragOut fragOut;
    fragOut.TargetRgba = flowOut.TargetRgba;
    return fragOut;
}

#ifdef UNITY_CAN_COMPILE_TESSELLATION
IvyTess_GpuPoint TessVert(VertIn vertIn)
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
VertOut Domain(IvyTess_Point pointIn)
{
    VertIn vertIn;
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
IvyTess_DomainTri(Domain, VertOut)
#else
#pragma vertex Vert
#endif
#pragma fragment Frag

#endif
