/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/19 17:45
*
* 描述： IvyObjectTransparent 阴影投射 Pass
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
    float3 position3 = press.PosOs + press.NrmOs * IvyArg_Scale;
    float4 positionOs = float4(position3, vertData.PosOs.w);
    fragData.PosCs = IvyShadowCaster_PositionCS(positionOs, press.NrmOs); 
    fragData.LightVector3 = IvyShadowCaster_Vector(positionOs);
    return fragData;
}

half4 frag(FragData fragData) : SV_Target
{
    return IvyShadowCaster_Fragment(fragData.LightVector3);
}

#pragma vertex vert
#pragma fragment frag

#endif // Def(IvyObjectTransparent_Shadow)

