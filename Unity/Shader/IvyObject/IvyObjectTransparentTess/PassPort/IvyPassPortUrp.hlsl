/****************************************

* 作者： 闪电黑客
* 日期： 2026/9/24

* 描述： IvyObjectTransparentTess URP Pass 端口
*        语义尾巴、贴图履约、细分入口挂号
*        Shader 在本文件之前写 IvyKey_ / Link_
*        管线由 IvyConfig 选定，与本文件所在的 SubShader 无关

*/


#ifndef Def_IvyPassPortUrp
#define Def_IvyPassPortUrp

#define IvyVarIn_PosOs : POSITION
#define IvyVarIn_NrmOs : NORMAL
#define IvyVarIn_Uv : TEXCOORD0
#define IvyVarIn_ViewFace : VFACE

#define IvyVarOut_PosCs : SV_POSITION
#define IvyVarOut_Uv : TEXCOORD0
#define IvyVarOut_NrmOs : TEXCOORD1
#define IvyVarOut_PosOs : TEXCOORD2
#define IvyVarOut_NrmWs : TEXCOORD3
#define IvyVarOut_PosWs : TEXCOORD4
#define IvyVarOut_LightVec : TEXCOORD0
#define IvyVarOut_Target : SV_Target

//===[进入管线核心]===
#include "../../../../IvyCoreUnity.hlsl"

//===[贴图资源与 IvyFunc_ 履约]===



sampler2D IvyArg_GrabTexture;
sampler2D IvyArg_SkinMask0;
sampler2D IvyArg_SkinMask1;
sampler2D IvyArg_SkinMask2;
sampler2D IvyArg_SkinMask3;
sampler2D IvyArg_FilmMaskTex;
sampler2D IvyArg_EnvMapTex;
sampler2D IvyArg_MatCapTex;

#if Link(IvyEnvLight)
float4 IvyFunc_ShadowCoord(IvyGeom_BuildOut geomOut)
{
    return IvyEnvLight_ShadowCoord(float4(geomOut.PosOs, 1.0), geomOut.PosCs, geomOut.PosWs);
}
#endif

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

#if Link(IvyAudioLink)
half IvyFunc_AudioLinkBand(uint band) { return 0; }
#endif

#ifdef UNITY_CAN_COMPILE_TESSELLATION
IvyTess_GpuPoint TessVert(IvyFlow_VertIn vertIn)
{
    return IvyTess_PackGpu(vertIn.PosOs, vertIn.NrmOs, vertIn.Uv);
}
#endif

#ifdef UNITY_CAN_COMPILE_TESSELLATION
#pragma target 4.6
#pragma vertex TessVert

#pragma hull IvyTess_Hull
IvyTess_HullTri(IvyFlowTess_Hull, IvyFlowTess_HullConst)

#pragma domain IvyTess_Domain
IvyTess_DomainTri(IvyFlow_Domain, IvyFlow_VertOut)
#else
#pragma vertex IvyFlow_Vert
#endif
#pragma fragment IvyFlow_Frag

#endif

