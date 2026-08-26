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

float4 IonArg_Color = float4(0,0,0,1); 
float IonArg_Scale = 1.0;


#pragma vertex vert
#pragma fragment frag

#define Link_IonBase
#define Link_IonMatrix
#include "../../Core/IonCore.hlsl"

struct VertData
{
    IonVar_PosOs
    IonVar_NrmOs
};

struct FragData
{
    IonVar_PosCs
};
            

FragData vert(VertData vertData)
{
    FragData fragData;

    float3 position3 = vertData.PosOs.xyz + vertData.NrmOs * IonArg_Scale;
    fragData.PosCs = IonMatrix_PosOsToCs(float4(position3, 1.0));
    return fragData;
}
            
half4 frag(FragData fragData) : SV_Target
{
    return IonArg_Color;
}

#endif // Def(IonPassOutline)

