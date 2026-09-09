/****************************************
*
* 作者： 闪电黑客
* 日期： 2026/09/09
*
* 描述： 颜色阶段
*        珠光/镭射乘到反射、折射上
*        不采样、不打光
*
*/

#if DefPart(IvyColor, Stage)
#define Def_IvyColor_Stage

#include "../Tool/IvyColor.hlsl"

struct IvyColor_StainIn
{
    /// <summary>
    /// 色轴 0~1（由 Pass 用 Effect2D_Axis 填入）
    /// </summary>
    half T;
    /// <summary>
    /// 量化档数。0~1 连续珠光，2 以上硬边镭射
    /// </summary>
    half Bands;
    /// <summary>
    /// 染色强度
    /// </summary>
    half Amount;
    /// <summary>
    /// 已合成的反射色
    /// </summary>
    half3 ReflectRgb;
    /// <summary>
    /// 已采样的折射环境色
    /// </summary>
    half3 RefractRgb;
};

struct IvyColor_StainOut
{
    /// <summary>
    /// 色相乘数
    /// </summary>
    half3 HueRgb;
    half3 ReflectRgb;
    half3 RefractRgb;
};

/// <summary>
/// 按珠光/镭射给反射、折射染色。
/// </summary>
IvyColor_StainOut IvyColor_Stain(IvyColor_StainIn dataIn)
{
    IvyColor_StainOut dataOut;
    half3 hueRgb = IvyColor_Holo(dataIn.T, dataIn.Bands);
    dataOut.HueRgb = lerp(1.0, hueRgb, saturate(dataIn.Amount));
    dataOut.ReflectRgb = dataIn.ReflectRgb * dataOut.HueRgb;
    dataOut.RefractRgb = dataIn.RefractRgb * dataOut.HueRgb;
    return dataOut;
}

#endif
