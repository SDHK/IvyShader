/****************************************
*
* 作者： 闪电黑客
* 日期： 2026/09/09
*
* 描述： 虹彩阶段
*        色相由 Tool 算出，按反射/折射明暗染色
*        不采样、不打光
*
*/

#if DefPart(IvyIridescence, Stage)
#define Def_IvyIridescence_Stage

#include "../Tool/IvyIridescence.hlsl"

struct IvyIridescence_LitIn
{
    /// <summary>
    /// 法线点视线 0~1
    /// </summary>
    half NdotV;
    /// <summary>
    /// 色相起点
    /// </summary>
    half Hue0;
    /// <summary>
    /// 色相展开
    /// </summary>
    half Spread;
    /// <summary>
    /// 虹彩强度
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

struct IvyIridescence_LitOut
{
    /// <summary>
    /// 色相乘数（均值约 1）
    /// </summary>
    half3 HueRgb;
    half3 ReflectRgb;
    half3 RefractRgb;
};

/// <summary>
/// 虹彩：按反射/折射明暗染色。灯在 IvyTransmit_Blend。
/// </summary>
IvyIridescence_LitOut IvyIridescence_Lit(IvyIridescence_LitIn dataIn)
{
    IvyIridescence_LitOut dataOut;
    half3 hueRgb = IvyIridescence(dataIn.NdotV, dataIn.Hue0, dataIn.Spread);
    dataOut.HueRgb = lerp(1.0, hueRgb, saturate(dataIn.Amount));
    dataOut.ReflectRgb = dataIn.ReflectRgb * dataOut.HueRgb;
    dataOut.RefractRgb = dataIn.RefractRgb * dataOut.HueRgb;
    return dataOut;
}

#endif
