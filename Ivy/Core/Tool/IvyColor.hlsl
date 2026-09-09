/****************************************
*
* 作者： 闪电黑客
* 日期： 2026/09/09
*
* 描述： 颜色：亮度、色空间、调色板、珠光、薄膜
*        只吃标量，不采样
*
*/

#if DefPart(IvyColor, Tool)
#define Def_IvyColor_Tool

#include "IvyMath.hlsl"

/// <summary>
/// 计算颜色的亮度
/// </summary>
half IvyColor_Luma(half3 color)
{
    return dot(color, half3(0.299, 0.587, 0.114));
}

/// <summary>
/// 基于余弦的调色板
/// </summary>
half3 IvyColor_Palette(half time, half3 dcOffset, half3 amp, half3 freq, half3 phase)
{
    return dcOffset + amp * cos(6.283185 * (freq * time + phase));
}

/// <summary>
/// 将 RGB 颜色转换为 HSV 颜色空间
/// </summary>
half3 IvyColor_RgbToHsv(half3 c)
{
    half4 K = half4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    half4 p = lerp(half4(c.bg, K.wz), half4(c.gb, K.xy), step(c.b, c.g));
    half4 q = lerp(half4(p.xyw, c.r), half4(c.r, p.yzx), step(p.x, c.r));
    half d = q.x - min(q.w, q.y);
    half e = 1e-10;
    return half3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

/// <summary>
/// 将 HSV 颜色转换为 RGB 颜色空间
/// </summary>
half3 IvyColor_HsvToRgb(half3 c)
{
    half4 K = half4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    half3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * lerp(K.xxx, saturate(p - K.xxx), c.y);
}

/// <summary>
/// 色相 0~1 转满饱和 RGB
/// </summary>
half3 IvyColor_HueRgb(half hue)
{
    return IvyColor_HsvToRgb(half3(frac(hue), 1.0, 1.0));
}

/// <summary>
/// 计算 HSV 颜色的差值
/// </summary>
/// <returns> (dH色相差, sMul饱和度倍率, vMul明度倍率)</returns>
half3 IvyColor_HsvDelta(half3 stopHsv, half3 refMidHsv)
{
    half dH = stopHsv.x - refMidHsv.x;
    if (dH > 0.5) dH -= 1.0;
    if (dH < -0.5) dH += 1.0;
    half sMul = stopHsv.y / max(refMidHsv.y, 1e-5);
    half vMul = stopHsv.z / max(refMidHsv.z, 1e-5);
    return half3(dH, sMul, vMul);
}

/// <summary>
/// 根据 HSV 差值应用到当前 HSV 颜色上
/// </summary>
half3 IvyColor_ApplyHsvDelta(half3 curMidHsv, half3 delta)
{
    half3 o;
    o.x = frac(curMidHsv.x + delta.x);
    half s = curMidHsv.y;
    if (s < 0.01) s = 0.01;
    o.y = saturate(s * delta.y);
    o.z = saturate(curMidHsv.z * delta.z);
    return o;
}

/// <summary>
/// 镭射色。档数小于 2 时连续珠光。
/// </summary>
half3 IvyColor_Holo(half t, half bands)
{
    if (bands < 2.0)
        return IvyColor_HueRgb(t);

    t = IvyMath_Quantize(t, bands);
    return saturate(IvyColor_Palette(
        t,
        half3(0.50, 0.50, 0.50),
        half3(0.50, 0.50, 0.50),
        half3(1.00, 1.00, 1.00),
        half3(0.00, 0.33, 0.67)
    ));
}

/// <summary>
/// 单层薄膜干涉。厚度默认 420nm，膜 IOR 1.33。
/// 均值为 1，乘到反射上不会整体变暗。
/// </summary>
half3 IvyColor_ThinFilm(half ndotv, half thicknessNm = 420.0)
{
    const half filmIor = 1.33;
    half sinT2 = (1.0 - ndotv * ndotv) / (filmIor * filmIor);
    half cosT = sqrt(saturate(1.0 - sinT2));
    half opd = 2.0 * filmIor * thicknessNm * cosT;
    half3 lambda = half3(650.0, 550.0, 450.0);
    return (0.5 - 0.5 * cos(6.2831853 * opd / lambda)) * 2.0;
}

#endif
