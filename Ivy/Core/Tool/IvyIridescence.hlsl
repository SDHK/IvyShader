/****************************************
*
* 作者： 闪电黑客
* 日期： 2026/09/09
*
* 描述： 结构性颜色：珠光转色、薄膜干涉
*        只吃标量，不采样
*
*/

#if DefPart(IvyIridescence, Tool)
#define Def_IvyIridescence_Tool

/// <summary>
/// 色相 0~1 转满饱和 RGB
/// </summary>
half3 IvyIridescence_HueRgb(half hue)
{
    hue = frac(hue);
    return saturate(half3(
        abs(hue * 6.0 - 3.0) - 1.0,
        2.0 - abs(hue * 6.0 - 2.0),
        2.0 - abs(hue * 6.0 - 4.0)
    ));
}

/// <summary>
/// 正面用 hue0，掠射沿色环走 spread。
/// 展开小 = 蝴蝶、丝绸；展开大 = 彩虹增色。
/// </summary>
half3 IvyIridescence(half ndotv, half hue0, half spread)
{
    half hue = hue0 + (1.0 - saturate(ndotv)) * spread;
    return IvyIridescence_HueRgb(hue);
}

/// <summary>
/// 单层薄膜干涉。厚度默认 420nm，膜 IOR 1.33。
/// 均值为 1，乘到反射上不会整体变暗。
/// </summary>
half3 IvyIridescence_ThinFilm(half ndotv, half thicknessNm = 420.0)
{
    const half filmIor = 1.33;
    half sinT2 = (1.0 - ndotv * ndotv) / (filmIor * filmIor);
    half cosT = sqrt(saturate(1.0 - sinT2));
    half opd = 2.0 * filmIor * thicknessNm * cosT;
    half3 lambda = half3(650.0, 550.0, 450.0);
    return (0.5 - 0.5 * cos(6.2831853 * opd / lambda)) * 2.0;
}

#endif
