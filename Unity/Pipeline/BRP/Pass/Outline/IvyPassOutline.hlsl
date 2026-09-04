/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/10 20:38
*
* 描述： Ivy Outline 默认 Pass
*
*/

#if Def(IvyPassOutline)
#define Def_IvyPassOutline

float4 IvyArg_Color = float4(0,0,0,1); 
float IvyArg_Scale = 1.0;


#pragma vertex vert
#pragma fragment frag

#define Link_IvyBase
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
};
            

FragData vert(VertData vertData)
{
    FragData fragData;

    float3 position3 = vertData.PosOs.xyz + vertData.NrmOs * IvyArg_Scale;
    fragData.PosCs = IvyMatrix_PosOsToCs(float4(position3, 1.0));
    return fragData;
}
            
half4 frag(FragData fragData) : SV_Target
{
    return IvyArg_Color;
}

#endif // Def(IvyPassOutline)

