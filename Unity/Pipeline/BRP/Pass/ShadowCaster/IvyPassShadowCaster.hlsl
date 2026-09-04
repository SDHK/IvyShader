/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/19 17:45
*
* 描述： Ivy Outline 阴影投射 Pass
*
*/

#if Def(IvyPassShadowCaster)
#define Def_IvyPassShadowCaster

// 默认参数定义
float IvyArg_Scale;

#pragma vertex vert
#pragma fragment frag

#define IvyKey_ShadowCaster

#define Link_IvyBase
#define Link_IvyLight
#define Link_IvyMatrix
#include "../../Core/IvyCore.hlsl"

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
    
    float3 position3 = vertData.PosOs.xyz + vertData.NrmOs * IvyArg_Scale;
    //float3 position3 = vertData.PosOs.xyz  * IvyArg_Scale;
    float4 positionOs = float4(position3, vertData.PosOs.w);
    fragData.PosCs = IvyShadowCaster_PositionCS(positionOs, vertData.NrmOs); 
    fragData.LightVector3 = IvyShadowCaster_Vector(positionOs);
    return fragData;
}

half4 frag(FragData fragData) : SV_Target
{
    return IvyShadowCaster_Fragment(fragData.LightVector3);
}

#endif // Def(IvyPassShadowCaster)

