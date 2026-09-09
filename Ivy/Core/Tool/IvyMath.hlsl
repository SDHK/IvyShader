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
/// 把 0~1 轴切成 bands 档
/// </summary>
half IvyMath_Quantize(half t, half bands)
{
    bands = max(floor(bands + 0.5), 1.0);
    return floor(t * bands) / bands;
}

#endif