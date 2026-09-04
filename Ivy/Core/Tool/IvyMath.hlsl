/****************************************

* 作者： 闪电黑客
* 日期： 2025/12/2 19:50

* 描述： 各种数学函数合集

*/

#if DefPart(IvyMath, Tool)
#define Def_IvyMath_Tool


/// <summary>
/// 数值在指定范围内进行 PingPong 循环
/// </summary>
/// <param name="t">值</param>
/// <param name="min">最小值</param>
/// <param name="max">最大值</param>
/// <returns>返回在指定范围内循环的值</returns>
float IvyMath_PingPong(float t, float min, float max)
{
    float range = max - min;
    float cycle = range * 2.0;                 // 去 + 回
    float x = t - min;
    x = x - cycle * floor(x / cycle);         // 折到 [0, cycle)，含负数
    float p = range - abs(x - range);         // 0 → range → 0
    return min + p;                          // min → max → min
}

/// <summary>
/// 数值在指定范围内进行 PingPong 循环
/// </summary>
/// <param name="t">值</param>
/// <param name="min">最小值</param>
/// <param name="max">最大值</param>
/// <returns>返回在指定范围内循环的值</returns>
float3 IvyMath_PingPong(float3 t, float3 min, float3 max)
{
    float3 range = max - min;
    float3 cycle = range * 2.0;
    float3 x = t - min;
    x = x - cycle * floor(x / cycle);
    return min + (range - abs(x - range));
}



/// <summary>
/// 计算复数的平方
/// </summary>
/// <param name="z">输入的复数，表示为二维向量 (x, y)</param>
/// <returns>返回复数的平方，表示为二维向量 (x, y)</returns>
float2 IvyMath_Csqr(float2 z)
{
    // (x + yi)² = (x² - y²) + 2xy i
    return float2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y);
}

/// <summary>
/// 计算复数的模
/// </summary>
/// <param name="z">输入的复数</param>
/// <returns>小数部分</returns>
float IvyMath_Fract(float z)
{
    return z - floor(z);
}

// 钳制映射 将value从min-max映射到targetMin-targetMax之间，并进行钳制
// float value : 输入值
// float min : 输入值的最小值
// float max : 输入值的最大值
// float targetMin = 0 : 目标最小值
// float targetMax = 1 : 目标最大值
// float return : 映射后的值
float IvyMath_ClampMap(float value, float min, float max, float targetMin = 0, float targetMax = 1)
{
    //假设要0.5到0.8之间的值，那么就用value-0.5，然后再减去0.8-0.5=0.3
    value -= min;
    max -= min;
    value = clamp(value, 0.0, max);
    value /= max;
    value = value * (targetMax - targetMin) + targetMin;
    return value;
}

/// <summary>
/// 计算颜色的亮度
/// </summary>
half IvyMath_Luma(half3 color)
{
    return dot(color, half3(0.299, 0.587, 0.114));
}

/// <summary>
/// 基于余弦的调色板，4个vec3参数
/// </summary>
/// <param name="time">时间</param>
/// <param name="dcOffset">直流偏移量</param>
/// <param name="amp">振幅</param>
/// <param name="freq">频率</param>
/// <param name="phase">相位</param>
/// <returns>返回计算后的颜色值</returns>
half3 IvyMath_Palette( in half time, in half3 dcOffset, in half3 amp, in half3 freq, in half3 phase)
{
    return dcOffset + amp*cos( 6.283185*(freq*time+phase) );
}

/// <summary>
/// 将 RGB 颜色转换为 HSV 颜色空间
/// </summary>
half3 IvyMath_RgbToHsv(half3 c)
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
half3 IvyMath_HsvToRgb(half3 c)
{
    half4 K = half4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    half3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * lerp(K.xxx, saturate(p - K.xxx), c.y);
}

/// <summary>
/// 计算 HSV 颜色的差值
/// </summary>
/// <param name="stopHsv">目标 HSV 颜色</param>
/// <param name="refMidHsv">参考中间 HSV 颜色</param>
/// <returns> 返回 (dH色相差, sMul饱和度倍率, vMul明度倍率)</returns>
half3 IvyMath_HsvDelta(half3 stopHsv, half3 refMidHsv)
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
/// <param name="curMidHsv">当前中间 HSV 颜色</param>
/// <param name="delta">HSV 差值</param>
/// <returns>返回应用差值后的 HSV 颜色</returns>
half3 IvyMath_ApplyHsvDelta(half3 curMidHsv, half3 delta)
{
    half3 o;
    o.x = frac(curMidHsv.x + delta.x);
    half s = curMidHsv.y;
    if (s < 0.01) s = 0.01;   // 或改用 sAdd 分支
    o.y = saturate(s * delta.y);
    o.z = saturate(curMidHsv.z * delta.z);
    return o; // 仍是 HSV，外面再 HsvToRgb
}

#endif