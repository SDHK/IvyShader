/****************************************
*
* 作者： 闪电黑客
* 日期： 2026/9/13
*
* 描述： IvyObjectTransparentTess Pass 端口履约
*        对应 Flow 的 IvyFlowPort：贴图资源 + IvyFunc_ 实现
*        Main / Add / Shadow 入口挂号（TessVert 需要 Uv）
*
*/

#ifndef Def_IvyPassPort
#define Def_IvyPassPort

sampler2D IvyArg_GrabTexture;
sampler2D IvyArg_SkinMask0;
sampler2D IvyArg_SkinMask1;
sampler2D IvyArg_SkinMask2;
sampler2D IvyArg_SkinMask3;
sampler2D IvyArg_FilmMaskTex;
sampler2D IvyArg_EnvMapTex;
sampler2D IvyArg_MatCapTex;

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

half IvyFunc_AudioLinkBand(uint band) { return 0; }

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
