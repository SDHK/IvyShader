/****************************************
*
* 作者： 闪电黑客
* 日期： 2026/09/09
*
* 描述： 颜色阶段
*        半程（视线+光照）连续彩虹，作为附加光输出
*        不采样、不打光
*
*/

#if DefPart(IvyColor, Stage)
#define Def_IvyColor_Stage

#include "../Tool/IvyColor.hlsl"

struct IvyColor_StainIn
{
    /// <summary>
    /// 色轴 0~1。半程兰伯特 N·H，再加色相旋转
    /// </summary>
    half T;
    /// <summary>
    /// 染色强度（面料）
    /// </summary>
    half Amount;
    /// <summary>
    /// 空间遮罩（花纹，不跟视角）
    /// </summary>
    half Mask;
    /// <summary>
    /// 视线圆环遮罩。0 环时为 1，有环时为 0~1 波纹
    /// </summary>
    half Rings;
};

struct IvyColor_StainOut
{
    /// <summary>
    /// 附加彩虹光
    /// </summary>
    half3 Rgb;
};

/// <summary>
/// 半程连续彩虹，按遮罩输出附加光。
/// </summary>
IvyColor_StainOut IvyColor_Stain(IvyColor_StainIn dataIn)
{
    IvyColor_StainOut dataOut;
    half cover = saturate(dataIn.Amount * dataIn.Mask * dataIn.Rings);
    dataOut.Rgb = IvyColor_HueRgb(dataIn.T) * cover;
    return dataOut;
}

#endif
