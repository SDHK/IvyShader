/****************************************

* 作者： 闪电黑客
* 日期： 2025/12/2 19:50

* 描述： 各种数学函数合集

*/

#if DefPart(IonMath, Tool)
#define Def_IonMath_Tool

/// <summary>
/// 计算颜色的亮度
/// </summary>
float IonMath_Luma(float3 color)
{
    return dot(color, float3(0.299, 0.587, 0.114));
}

/// <summary>
/// 将 RGB 颜色转换为 HSV 颜色空间
/// </summary>
float3 IonMath_RgbToHsv(float3 c)
{
    float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    float4 p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
    float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));
    float d = q.x - min(q.w, q.y);
    float e = 1e-10;
    return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}
/// <summary>
/// 将 HSV 颜色转换为 RGB 颜色空间
/// </summary>
float3 IonMath_HsvToRgb(float3 c)
{
    float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * lerp(K.xxx, saturate(p - K.xxx), c.y);
}

/// <summary>
/// 计算 HSV 颜色的差值
/// </summary>
/// <param name="stopHsv">目标 HSV 颜色</param>
/// <param name="refMidHsv">参考中间 HSV 颜色</param>
/// <returns> 返回 (dH色相差, sMul饱和度倍率, vMul明度倍率)</returns>
float3 IonMath_HsvDelta(float3 stopHsv, float3 refMidHsv)
{
    float dH = stopHsv.x - refMidHsv.x;
    if (dH > 0.5) dH -= 1.0;
    if (dH < -0.5) dH += 1.0;
    float sMul = stopHsv.y / max(refMidHsv.y, 1e-5);
    float vMul = stopHsv.z / max(refMidHsv.z, 1e-5);
    return float3(dH, sMul, vMul);
}

/// <summary>
/// 根据 HSV 差值应用到当前 HSV 颜色上
/// </summary>
/// <param name="curMidHsv">当前中间 HSV 颜色</param>
/// <param name="delta">HSV 差值</param>
/// <returns>返回应用差值后的 HSV 颜色</returns>
float3 IonMath_ApplyHsvDelta(float3 curMidHsv, float3 delta)
{
    float3 o;
    o.x = frac(curMidHsv.x + delta.x);
    float s = curMidHsv.y;
    if (s < 0.01) s = 0.01;   // 或改用 sAdd 分支
    o.y = saturate(s * delta.y);
    o.z = saturate(curMidHsv.z * delta.z);
    return o; // 仍是 HSV，外面再 HsvToRgb
}

/// <summary>
/// 计算复数的平方
/// </summary>
/// <param name="z">输入的复数，表示为二维向量 (x, y)</param>
/// <returns>返回复数的平方，表示为二维向量 (x, y)</returns>
float2 IonMath_Csqr(float2 z)
{
    // (x + yi)² = (x² - y²) + 2xy i
    return float2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y);
}

/// <summary>
/// 计算复数的模
/// </summary>
/// <param name="z">输入的复数</param>
/// <returns>返回复数的模</returns>
float IonMath_Fract(float z)
{
    return z - floor(z);
}

// 2D坐标缩放偏移
// float2 uv : 输入的二维坐标
// float2 scale : 缩放值
// float2 offset : 偏移值
// float2 return : 变换后的二维坐标
float2 IonMath_Transform2D(float2 uv, float2 scale, float2 offset)
{
    return uv * scale + offset;
}


// 沿法线方向缩放位置
// float3 position : 输入的位置
// float3 normal : 法线方向
// float scale : 缩放值
// float3 return : 缩放后的位移位置
float3 IonMath_Scale(float3 position, float3 normal, float scale)
{
    return position + normal * scale;
}


//根据角度计算半径为的圆上的点 0~1
// float angle - 角度值
// float2 return - 对应的二维坐标
float2 IonMath_AngleToUV(float angle)
{
    angle %= 360;
    return frac(float2(cos(angle) + 1, sin(angle) + 1) * 0.5);
}

// 钳制映射 将value从min-max映射到targetMin-targetMax之间，并进行钳制
// float value : 输入值
// float min : 输入值的最小值
// float max : 输入值的最大值
// float targetMin = 0 : 目标最小值
// float targetMax = 1 : 目标最大值
// float return : 映射后的值
float IonMath_ClampMap(float value, float min, float max, float targetMin = 0, float targetMax = 1)
{
    //假设要0.5到0.8之间的值，那么就用value-0.5，然后再减去0.8-0.5=0.3
    value -= min;
    max -= min;
    value = clamp(value, 0.0, max);
    value /= max;
    value = value * (targetMax - targetMin) + targetMin;
    return value;
}




#endif