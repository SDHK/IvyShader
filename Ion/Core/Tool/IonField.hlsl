/****************************************

* 作者： 闪电黑客
* 日期： 2026/8/4 15:14

* 描述： 各种采样场合集

*/

#if DefPart(IonField, Tool)
#define Def_IonField_Tool

#define Link_IonHash
#define Link_IonMath
#include "../IonEdit.hlsl"

/// <summary>
/// 星空采样场
/// </summary>
/// <param name="pos">输入的位置</param>
/// <returns>返回计算后的权重</returns>
float IonField_Star(float3 pos)
{
    float step = 0.0;
    float weight = 0.0;
    for (int i = 0; i < 10; i++)
    {
        pos = abs(pos) / dot(pos, pos) - 0.532;
        weight +=  abs(length(pos) - step) *.01;
        step = length(pos);
    }
    return weight;
}

/// <summary>
/// 水晶采样场
/// </summary>
/// <param name="pos">输入的位置</param>
/// <returns>返回计算后的权重</returns>
float IonField_Crystal(float3 pos)
{
    float weight = 0.;
    float3 c = pos;
    for (int i = 0; i < 10; ++i)
    {
        pos = 1.7 * abs(pos) / dot(pos, pos) - 0.6;
        //pos.xy= IonMath_Csqr(pos.xy);
        //p.yz= csqr(p.yz);
        pos = pos.zxy;
        weight += exp(-20. * abs(dot(pos, c))) * .5;
    }
    return weight;
}

#endif