/****************************************
*
* 作者： 闪电黑客
* 日期： 2026/09/09
*
* 描述： 颜色阶段
*        珠光/镭射盖在已合成的表面上
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
    /// 染色强度（面料 8 条）
    /// </summary>
    half Amount;
    /// <summary>
    /// 空间遮罩（花纹，不跟视角）
    /// </summary>
    half Mask;
    /// <summary>
    /// 视角盖度（掠射更实）
    /// </summary>
    half Cover;
    /// <summary>
    /// 透射合成后的表面色
    /// </summary>
    half3 Rgb;
};

struct IvyColor_StainOut
{
    /// <summary>
    /// 色相乘数
    /// </summary>
    half3 HueRgb;
    half3 Rgb;
};

/// <summary>
/// 按珠光/镭射盖在合成表面上。
/// </summary>
IvyColor_StainOut IvyColor_Stain(IvyColor_StainIn dataIn)
{
    IvyColor_StainOut dataOut;
    half3 hueRgb = IvyColor_Holo(dataIn.T, dataIn.Bands);
    half cover = saturate(dataIn.Amount * dataIn.Mask * dataIn.Cover);
    dataOut.HueRgb = lerp(1.0, hueRgb, cover);
    dataOut.Rgb = dataIn.Rgb * dataOut.HueRgb;
    return dataOut;
}

#endif
