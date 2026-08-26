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
#if PassVar(Scale)
#warning "IonPassShadowCaster没有定义 PassVar_Scale，使用默认值 1.0"
#endif
float PassVar_Scale = 1.0;

#pragma vertex vert
#pragma fragment frag

#define IonKey_ShadowCaster

#define Link_IonBase
#define Link_IonMatrix
#include "../../Core/IonCore.hlsl"

struct VertData
{
    IonVar_PosOs
};

struct FragData
{
    IonVar_PosCs
};

FragData vert(VertData vertData)
{
    FragData fragData;
    fragData.PosCs = IonMatrix_PosOsToCs(vertData.PosOs);
    return fragData;
}

half4 frag(FragData fragData) : SV_Target
{
    return 0;
}

#endif // Def(IonPassShadowCaster)

