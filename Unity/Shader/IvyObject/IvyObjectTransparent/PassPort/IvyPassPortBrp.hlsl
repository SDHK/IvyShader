
/****************************************

* 作者： 闪电黑客
* 日期： 2026/9/24

* 描述： IvyObjectTransparent BRP Pass 端口
*        语义尾巴、贴图履约、入口挂号
*        Shader 在本文件之前写 IvyKey_ / Link_

*/



#ifndef Def_IvyPassPortBrp
#define Def_IvyPassPortBrp

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

// 链接到 IvyPipeCore
#include "../../../../IvyCoreUnity.hlsl"

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

#pragma vertex IvyFlow_Vert
#pragma fragment IvyFlow_Frag

#endif

