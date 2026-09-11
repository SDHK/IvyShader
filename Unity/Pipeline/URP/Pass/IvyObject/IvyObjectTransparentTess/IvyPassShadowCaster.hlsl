/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/19 17:45
*
* 描述： IvyObjectTransparentTess 阴影投射 Pass
*
*/

#if Def(IvyPassShadowCaster)
#define Def_IvyPassShadowCaster

#define IvyKey_ShadowCaster

#define Link_IvyBase
#define Link_IvyLight
#define Link_IvyMatrix
#define Link_IvyVertex
#include "../../../Core/IvyCore.hlsl"

struct VertData
{
    IvyVar_PosOs
    IvyVar_NrmOs
};

struct FragData
{
    IvyVar_PosCs
    IvyVar_T0(float3,LightVector3)
};

FragData vert(VertData vertData)
{
    FragData fragData;
    
    IvyVertex_PressOut press = IvyVertex_Press(vertData.PosOs.xyz, vertData.NrmOs, IvyArg_PressDepth, IvyArg_PressPos.xyz, IvyArg_PressRadius);
    float4 positionOs = float4(press.PosOs, vertData.PosOs.w);
    fragData.PosCs = IvyShadowCaster_PositionCS(positionOs, press.NrmOs); 
    fragData.LightVector3 = IvyShadowCaster_Vector(positionOs);
    return fragData;
}

#ifdef UNITY_CAN_COMPILE_TESSELLATION
IvyTess_GpuPoint TessVert(VertData vertIn)
{
    return IvyTess_PackGpu(vertIn.PosOs, vertIn.NrmOs, float2(0, 0));
}
IvyTess_Point Hull(IvyTess_Point pointIn)
{
    return pointIn;
}
float HullConst(float3 pos0, float3 pos1, float3 pos2)
{
    return IvyTess_Factor(pos0, pos1, pos2, IvyArg_PressDepth, IvyArg_PressPos.xyz, IvyArg_PressRadius, IvyArg_TessFactor);
}
FragData Domain(IvyTess_Point pointIn)
{
    VertData vertIn;
    vertIn.PosOs = pointIn.PosOs;
    vertIn.NrmOs = pointIn.NrmOs;
    return vert(vertIn);
}
#endif

half4 frag(FragData fragData) : SV_Target
{
    return IvyShadowCaster_Fragment(fragData.LightVector3);
}

#ifdef UNITY_CAN_COMPILE_TESSELLATION
#pragma target 4.6
#pragma vertex TessVert

#pragma hull IvyTess_Hull
IvyTess_HullTri(Hull, HullConst)

#pragma domain IvyTess_Domain
IvyTess_DomainTri(Domain, FragData)
#else
#pragma vertex vert
#endif
#pragma fragment frag

#endif // Def(IvyObjectTransparentTess_Shadow)

