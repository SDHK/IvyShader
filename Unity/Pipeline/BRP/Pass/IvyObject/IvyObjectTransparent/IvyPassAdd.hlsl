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

#include "../../../Core/IvyStruct.hlsl"

struct IvyFlowAdd_VertIn
{
    IvyVar_PosOs
    IvyVar_NrmOs
    IvyVar_T0(float2, Uv)
};

struct IvyFlowAdd_VertOut
{
    IvyVar_PosCs
    IvyVar_T0(float2, Uv)
    IvyVar_T1(float3, NrmOs)
    IvyVar_T2(float3, PosOs)
    IvyVar_T3(float3, NrmWs)
    IvyVar_T4(float3, PosWs)
};

struct IvyFlowAdd_FragIn
{
    IvyFlowAdd_VertOut VertOut;
    IvyVar_ViewFace
};

struct IvyFlowAdd_FragOut { IvyVar_TargetRgba };

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

IvyFlowAdd_VertOut Vert(IvyFlowAdd_VertIn vertIn)
{
    return IvyFlowAdd_Vert(vertIn);
}

IvyFlowAdd_FragOut Frag(IvyFlowAdd_FragIn fragIn)
{
    return IvyFlowAdd_Frag(fragIn);
}

#pragma vertex Vert
#pragma fragment Frag

#endif
