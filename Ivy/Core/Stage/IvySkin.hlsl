/****************************************
*
* 作者： 闪电黑客
* 日期： 2026/09/07
*
* 描述： 皮肤涂色阶段
*        相对基准色的 HSV 偏移 + 三色 Ramp 喷涂（单条）
*
*/

#if DefPart(IvySkin, Stage)
#define Def_IvySkin_Stage

#include "../Tool/IvyColor.hlsl"
#include "../Tool/IvyRamp.hlsl"

struct IvySkin_RampIn
{
    /// <summary>
    /// 当前皮肤底色
    /// </summary>
    half3 SkinRgb;
    /// <summary>
    /// 渐变基准色，用于计算 HSV 差值
    /// </summary>
    half3 RampBaseRgb;
    /// <summary>
    /// 法线（物体空间或世界空间，由 Pass 指定）
    /// </summary>
    float3 Nrm;
    /// <summary>
    /// 喷涂方向；必须与 Nrm 处于同一坐标空间。
    /// 例如物体空间参考方向，或世界空间视线方向。
    /// </summary>
    float3 RampDir;
    /// <summary>
    /// Lambert 缩放，0.5=半兰伯特，1=标准兰伯特
    /// </summary>
    half LambertScale;
    /// <summary>
    /// 暗部喷涂色
    /// </summary>
    half3 Rgb0;
    /// <summary>
    /// 亮部喷涂色
    /// </summary>
    half3 Rgb1;
    /// <summary>
    /// 暗部阈值
    /// </summary>
    half Threshold0;
    /// <summary>
    /// 亮部阈值（内部按 1-Threshold1 作为中间带）
    /// </summary>
    half Threshold1;
    /// <summary>
    /// 过渡宽度
    /// </summary>
    half Softness;
};

struct IvySkin_RampOut
{
    half3 Rgb;
};

/// <summary>
/// 皮肤涂色阶段：相对基准色的 HSV 偏移 + 三色 Ramp 喷涂（单条） 
/// </summary>
IvySkin_RampOut IvySkin_Ramp(IvySkin_RampIn dataIn)
{
    IvySkin_RampOut dataOut;

    half lambert = IvyRamp_Lambert(dataIn.Nrm, dataIn.RampDir, dataIn.LambertScale);
    half3 skinHsv = IvyColor_RgbToHsv(dataIn.SkinRgb);
    half3 rampBaseHsv = IvyColor_RgbToHsv(dataIn.RampBaseRgb);

    half3 deltaHsv0 = IvyColor_HsvDelta(IvyColor_RgbToHsv(dataIn.Rgb0), rampBaseHsv);
    half3 deltaHsv1 = IvyColor_HsvDelta(IvyColor_RgbToHsv(dataIn.Rgb1), rampBaseHsv);
    half3 rampRgb0 = IvyColor_HsvToRgb(IvyColor_ApplyHsvDelta(skinHsv, deltaHsv0));
    half3 rampRgb1 = IvyColor_HsvToRgb(IvyColor_ApplyHsvDelta(skinHsv, deltaHsv1));

    dataOut.Rgb = IvyRamp_Rgb3(
        lambert,
        rampRgb0, dataIn.Threshold0, dataIn.Softness,
        dataIn.SkinRgb, 1.0 - dataIn.Threshold1, dataIn.Softness,
        rampRgb1);

    return dataOut;
}

#endif // DefPart(IvySkin,Stage)
