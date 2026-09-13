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

#include "../../../Core/IvyStruct.hlsl"

struct IvyFlow_VertIn
{
    IvyVar_PosOs
    IvyVar_NrmOs
    IvyVar_T0(float2, Uv)
};

struct IvyFlow_VertOut
{
    IvyVar_PosCs
    IvyVar_T0(float2, Uv)
    IvyVar_T1(float3, NrmOs)
    IvyVar_T2(float3, PosOs)
    IvyVar_T3(float3, NrmWs)
    IvyVar_T4(float3, PosWs)
};

struct IvyFlow_FragIn
{
    IvyFlow_VertOut VertOut;
    IvyVar_ViewFace
};

struct IvyFlow_FragOut { IvyVar_TargetRgba };

#define Link_IvyEnvBase
#define Link_IvyEnvLight
#define Link_IvyFlowMain
#include "../../../Core/IvyCore.hlsl"
#include "IvyPassPort.hlsl"

#endif
