/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/10 20:38
*
* 描述： IvyObjectTransparent 描边 Pass
*
*/

#if Def(IvyPassOutline)
#define Def_IvyPassOutline

#define Link_IvyBase
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
};
            

FragData vert(VertData vertData)
{
    FragData fragData;

    IvyVertex_PressOut press = IvyVertex_Press(vertData.PosOs.xyz, vertData.NrmOs, IvyArg_PressDepth, IvyArg_PressPos.xyz, IvyArg_PressRadius);
    float3 position3 = press.PosOs + press.NrmOs * IvyArg_Scale;
    fragData.PosCs = IvyMatrix_PosOsToCs(float4(position3, 1.0));
    return fragData;
}

half4 frag(FragData fragData) : SV_Target
{
    return IvyArg_Color;
}

#pragma vertex vert
#pragma fragment frag

#endif // Def(IvyObjectTransparent_Outline)

