/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/19 17:45
*
* 描述： Ion Outline 阴影投射 Pass
*
*/

#if Def(IonPassShadowCaster)
#define Def_IonPassShadowCaster

// 默认参数定义
float IonArg_Scale;

#pragma vertex vert
#pragma fragment frag

#define IonKey_ShadowCaster

#define Link_IonBase
#define Link_IonLight
#define Link_IonMatrix
#include "../../Core/IonCore.hlsl"

struct VertData
{
    IonVar_PositionOs
    IonVar_Normal
};

struct FragData
{
    IonVar_PositionCs
    IonVar_T0(float3,LightVector3)
};

FragData vert(VertData vertData)
{
    FragData fragData;
    
    float3 position3 = vertData.PositionOs.xyz + vertData.Normal * IonArg_Scale;
    float4 positionOs = float4(position3, vertData.PositionOs.w);
    fragData.PositionCs = IonShadowCaster_PositionCS(positionOs, vertData.Normal); 
    fragData.LightVector3 = IonShadowCaster_Vector(positionOs);
    return fragData;
}

half4 frag(FragData fragData) : SV_Target
{
    return IonShadowCaster_Fragment(fragData.LightVector3);
}

#endif // Def(IonPassShadowCaster)

