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
#if PassVar(Scale)
#warning "IvyPassShadowCaster没有定义 PassVar_Scale，使用默认值 1.0"
#endif
float PassVar_Scale = 1.0;

#pragma vertex vert
#pragma fragment frag

#define IvyKey_ShadowCaster

#define Link_IvyBase
#define Link_IvyMatrix
#include "../../Core/IvyCore.hlsl"

struct VertData
{
    IvyVar_PosOs
};

struct FragData
{
    IvyVar_PosCs
};

FragData vert(VertData vertData)
{
    FragData fragData;
    fragData.PosCs = IvyMatrix_PosOsToCs(vertData.PosOs);
    return fragData;
}

half4 frag(FragData fragData) : SV_Target
{
    return 0;
}

#endif // Def(IvyPassShadowCaster)

