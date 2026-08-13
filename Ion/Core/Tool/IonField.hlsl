/****************************************

* 作者： 闪电黑客
* 日期： 2026/8/4 15:14

* 描述： 各种采样场合集
* Signed Distance Field
* 有些采样场是 有向距离场（SDF）类型的，返回值小于0表示在物体内部，
* 大于0表示在物体外部，等于0表示在物体表面。

*/

#if DefPart(IonField, Tool)
#define Def_IonField_Tool

#define Link_IonHash
#define Link_IonMath
#include "../IonEdit.hlsl"

float IonSDField_Sphere( float3 p, float r = 0.5 )
{
    //返回小于0时表示在球体内，大于0表示在球体外
  return 1-clamp(length(p) - r,0,0.1)*10;
}

float IonSDField_Box( float3 p, float2 t = float2(0.5, 0.1) )
{
    float2 q = float2(length(p.xz)-t.x,p.y);
    return length(q)-t.y;
}

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
        pos = abs(pos) / dot(pos, pos) - 0.5315;
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
        pos =1.7*abs(pos) / dot(pos, pos) - 0.633;
        pos = pos.zxy;
        //pos.xy= IonMath_Csqr(pos.xy);
        //pos.yz= IonMath_Csqr(pos.yz);
        weight += exp(-20. * abs(dot(pos, c))) * .5;
    }
    return weight;
}

#endif