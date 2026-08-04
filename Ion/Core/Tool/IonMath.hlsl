/****************************************

* 作者： 闪电黑客
* 日期： 2025/12/2 19:50

* 描述： 各种数学函数合集 

*/

#if DefPart(IonMath, Tool) 
#define Def_IonMath_Tool

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
float2 IonMath_Transform2D(float2 uv, float2 scale,float2 offset)  
{
   return uv * scale + offset;
}


// 沿法线方向缩放位置
// float3 position : 输入的位置
// float3 normal : 法线方向
// float scale : 缩放值
// float3 return : 缩放后的位移位置
float3 IonMath_Scale(float3 position,float3 normal,float scale)
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

// 颜色映射
// float colorWeight : 颜色权重值，范围0-1
// float4 colors[8] : 颜色数组，最多支持8种颜色
// int colorCount = 8 : 颜色数量
// float4 return : 映射后的颜色值
float4 IonMath_MapColor(float colorWeight, float4 colors[8], int colorCount = 8)
{
    float step = 1.0 / (colorCount - 1); // 每段的权重范围
    for (int i = 0; i < colorCount - 1; i++)
    {
        float minWeight = i * step;
        float maxWeight = (i + 1) * step;
        if (colorWeight >= minWeight && colorWeight < maxWeight)
        {
            return lerp(colors[i], colors[i + 1], IonMath_ClampMap(colorWeight, minWeight, maxWeight));
        }
    }
    return colors[colorCount - 1]; // 超出范围返回最后一个颜色
}



#endif