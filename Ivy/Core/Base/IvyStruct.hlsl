/****************************************
*
* 作者： 闪电黑客
* 日期： 2026/9/13 14:29
*
* 说明： 基础结构体
*
* 设计理念：
*
*/


#ifndef Def_IvyStruct
#define Def_IvyStruct

/// <summary>
/// 光源数据
/// </summary>
struct IvyStruct_LightData
{
    // 光源方向
    half3   Dir;
    // 光源颜色
    half3   Rgb;
    // 光源衰减
    float   DistAtten; 
    // 阴影衰减
    half    ShadowAtten;
};

#endif // IvyStruct