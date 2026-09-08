/****************************************

* 作者： 闪电黑客
* 日期： 2026/8/4 15:14

* 描述： 各种采样场合集
* Signed Distance Field
* 有些采样场是 有向距离场（SDF）类型的，返回值小于0表示在物体内部，
* 大于0表示在物体外部，等于0表示在物体表面。

*/

#if DefPart(IvyField, Tool)
#define Def_IvyField_Tool


float IvySDField_Sphere( float3 p, float r = 0.5 )
{
    //返回小于0时表示在球体内，大于0表示在球体外
  return 1-clamp(length(p) - r,0,0.1)*10;
}

float IvySDField_Box( float3 p, float2 t = float2(0.5, 0.1) )
{
    float2 q = float2(length(p.xz)-t.x,p.y);
    return length(q)-t.y;
}

/// <summary>
/// 星空采样场
/// </summary>
/// <param name="pos">输入的位置</param>
/// <returns>返回计算后的权重</returns>
float IvyField_Star(float3 pos,float2 sctime = 0)
{
    float step = 0.0;
    float weight = 0.0;

    float3 c = pos;
    c.xy = c.xy * sctime.x + float2(c.y, c.x) * sctime.y;

    for (int i = 0; i < 10; i++)
    {
        pos = abs(pos) / dot(pos, pos) - 0.5315;
        weight +=  abs(length(dot(pos, c)) - step) *.01;
        step = length(pos);
    }
    return weight;
}

/// <summary>
/// 水晶采样场
/// </summary>
/// <param name="pos">输入的位置</param>
/// <returns>返回计算后的权重</returns>
float IvyField_Crystal(float3 pos,float2 sctime = 0)
{
    float weight = 0.;
    float3 c = pos;
    c.xy = c.xy * sctime.x + float2(c.y, c.x) * sctime.y;
    for (int i = 0; i < 10; ++i)
    {
        pos =1.7*abs(pos) / dot(pos, pos) - 0.633;
        pos = pos.zxy;
        //pos.xy= IvyMath_Csqr(pos.xy);
        //pos.yz= IvyMath_Csqr(pos.yz);
        weight += exp(-20. * abs(dot(pos, c))) * .5;
    }
    return weight;
}

#endif