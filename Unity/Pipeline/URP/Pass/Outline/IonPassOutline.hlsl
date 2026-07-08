/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/10 20:38
*
* 描述： Ion Outline 默认 Pass
*
*/

#if Def(IonPassOutline)
#define Def_IonPassOutline

#if PassVar(Color)
#warning "IonPassOutline没有定义 PassVar_Color，使用默认值 float4(0,0,0,1)"
#endif
#if PassVar(Scale)
#warning "IonPassOutline没有定义 PassVar_Scale，使用默认值 1.0"
#endif

float4 PassVar_Color = float4(0,0,0,1); 
float PassVar_Scale = 1.0;


#pragma vertex vert
#pragma fragment frag

#define Link_IonBase
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
};
            

FragData vert(VertData vertData)
{
    FragData fragData;

    float3 position3 = vertData.PositionOs.xyz + vertData.Normal * PassVar_Scale;
    fragData.PositionCs = IonMatrix_ObjectToClip(float4(position3, 1.0));
    return fragData;
}
            
half4 frag(FragData fragData) : SV_Target
{
    return PassVar_Color;
}

#endif // Def(IonPassOutline)

