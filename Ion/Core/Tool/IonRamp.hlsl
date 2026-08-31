/****************************************

* 作者： 闪电黑客
* 日期： 2026/1/6 20:21

* 描述： 各种渐变色计算工具函数合集

*/

#if DefPart(IonRamp, Tool)
#define Def_IonRamp_Tool


/// <summary>
/// 计算 Lambert 光照权重
/// </summary>
/// <param name="nrmWs">世界空间法线</param>
/// <param name="lightDirWs">光源方向</param>
/// <param name="scale"> 缩放系数（默认 1.0）</param>
/// <returns>光照权重（0~1）</returns>
float3 IonRamp_Lambert(float3 nrmWs, float3 lightDirWs, float scale = 1.0)
{
    // 映射：scale=1,offset=1 → 标准Lambert；scale=0.5,offset=0.5 → 半兰伯特
    return saturate(dot(nrmWs, lightDirWs) * scale + 1 - scale);
}

//===[菲涅耳边缘光]===

// 计算菲涅耳边缘光强度（正对摄像机的面=0，侧边缘=1）
// float3 nrmWs  - 世界空间法线（已归一化）
// float3 viewDirWs   - 视线方向（normalize(cameraPos - positionWS)）
// float  softness  - 边缘集中度（低=细窄边，高=宽泛晕染）
// float  return    - 菲涅耳强度（0~1）
float IonRamp_Fresnel(float3 nrmWs, float3 viewDirWs, float softness)
{
    float dotNv = saturate(dot(nrmWs, viewDirWs));
    return pow(1.0 - dotNv,20 - softness * 20);
}

/// <summary>
/// 计算高光强度
/// </summary>
/// <param name="nrmWs">世界空间法线（已归一化）</param>
/// <param name="lightDir">光源方向（已归一化）</param>
/// <param name="softness">边缘集中度（低=细窄，高=宽泛）</param>
/// <returns>高光强度（0~1）</returns>
float IonRamp_HighLight(float3 nrmWs,float3 lightDir, float softness)
{
    nrmWs = normalize(nrmWs);
    float nh = saturate(dot(nrmWs, lightDir));
    // softness 0=镜面, 1=粗糙；指数别落到 0
    float specPower = exp2(lerp(15.0, 1, saturate(softness))); // ≈ 1024 → 2
    // 或: lerp(512, 8, softness) 自己拧
    float spec = pow(nh, specPower*0.5);
    // 关键：越尖越亮（近似能量守恒）
    spec *= (specPower ) * 0.125;  // 系数可调：0.5~0.25 之间试亮度
    return saturate(spec); // 若觉得不够亮，可先不 saturate，后面再 tonemap
}

//===[背光边缘光]===

// 计算背光（逆光轮廓光）强度
// 条件：法线背对光源（逆光）且处于视角边缘，才产生亮边
// float3 nrmWs  - 世界空间法线（已归一化）
// float3 viewDirWs   - 视线方向（normalize(cameraPos - positionWS)）
// float3 lightDir  - 光源方向（已归一化，由框架提供）
// float  softness  - 边缘集中度（低=细窄，高=宽泛）
// float  return    - 背光强度（0~1，仅逆光时非零）
float IonRamp_BackRim(float3 nrmWs, float3 viewDirWs, float3 lightDir, float softness)
{
    // 法线背对光源程度（0=正对光源 1=完全背光)
    float backDotNl = saturate(-dot(nrmWs, lightDir));
    // 视角边缘遮罩
    float rimMask = IonRamp_Fresnel(nrmWs, viewDirWs, softness);
    return backDotNl * rimMask;
}


/// <summary>
/// 根据 Lambert 权重输出 0~1 灰度光照强度（不带颜色，颜色由光源和 BaseRamp 提供）
/// </summary>
/// <param name="weight">Lambert 灰度权重（0=背光 1=全亮）</param>
/// <param name="threshold">阴影边界位置（0~1）</param>
/// <param name="softness">边界过渡宽度（0=硬切卡通，>0=柔和渐变）</param>
/// <returns>光照强度（0=完全阴影，1=完全受光）</returns>
float IonRamp_Gray(float weight, float threshold, float softness)
{
    return smoothstep(threshold - softness, threshold + softness, weight);
}

/// <summary>
/// 根据 Lambert 权重在 2 个颜色域之间平滑过渡（程序化 Ramp，等同于 PS 渐变编辑器） 
/// </summary>
/// <param name="weight">Lambert 灰度权重（0=背光 1=全亮）</param>
/// <param name="rgb1">第一个颜色域</param>
/// <param name="threshold1">第一个颜色域的阈值</param>
/// <param name="softness1">第一个颜色域的过渡宽度</param>
/// <param name="rgb2">第二个颜色域</param>
/// <returns>混合后的光照颜色</returns>
float3 IonRamp_Rgb2(float weight, float3 rgb1, float threshold1, float softness1, float3 rgb2)
{
    float t1 = smoothstep(threshold1 - softness1, threshold1 + softness1, weight);
    return lerp(rgb1, rgb2, t1);
}

/// <summary>
/// 根据 Lambert 权重在 3 个颜色域之间平滑过渡（程序化 Ramp，等同于 PS 渐变编辑器） 
/// </summary>
/// <param name="weight">Lambert 灰度权重（0=背光 1=全亮）</param>
/// <param name="rgb1">颜色域</param>
/// <param name="threshold1">颜色域的阈值</param>
/// <param name="softness1">颜色域的过渡宽度</param>
/// <returns>混合后的光照颜色</returns>
float3 IonRamp_Rgb3(float weight, float3 rgb1, float threshold1, float softness1, float3 rgb2, float threshold2, float softness2, float3 rgb3)
{
    float t1 = smoothstep(threshold1 - softness1, threshold1 + softness1, weight);
    float t2 = smoothstep(threshold2 - softness2, threshold2 + softness2, weight);
    float3 c = lerp(rgb1, rgb2, t1);
    return lerp(c, rgb3, t2);
}

/// <summary>
/// 根据 Lambert 权重在 4 个颜色域之间平滑过渡（程序化 Ramp，等同于 PS 渐变编辑器） 
/// </summary>
/// <param name="weight">Lambert 灰度权重（0=背光 1=全亮）</param>
/// <param name="rgb1">颜色域</param>
/// <param name="threshold1">颜色域的阈值</param>
/// <param name="softness1">颜色域的过渡宽度</param>
/// <returns>混合后的光照颜色</returns>
float3 IonRamp_Rgb4(float weight, float3 rgb1, float threshold1, float softness1, float3 rgb2, float threshold2, float softness2, float3 rgb3, float threshold3, float softness3, float3 rgb4)
{
    float t1 = smoothstep(threshold1 - softness1, threshold1 + softness1, weight);
    float t2 = smoothstep(threshold2 - softness2, threshold2 + softness2, weight);
    float t3 = smoothstep(threshold3 - softness3, threshold3 + softness3, weight);
    float3 c = lerp(rgb1, rgb2, t1);
    c = lerp(c, rgb3, t2);
    return lerp(c, rgb4, t3);
}

/// <summary>
/// 根据 Lambert 权重在 5 个颜色域之间平滑过渡（程序化 Ramp，等同于 PS 渐变编辑器）
/// </summary>
/// <param name="weight">Lambert 灰度权重</param>
/// <param name="rgb1">各域颜色（1=阴影域 → 5=高光域）</param>
/// <param name="threshold1">域边界位置（NdotL 轴上 0~1，需满足 t1 < t2 < t3 < t4）</param>
/// <param name="softness1">边界过渡宽度（0=硬切卡通，>0=柔和渐变，建议 0~0.1）</param>
/// <returns>混合后的光照颜色</returns>
float3 IonRamp_Rgb5(float weight, float3 rgb1, float threshold1, float softness1, float3 rgb2, float threshold2, float softness2, float3 rgb3, float threshold3, float softness3, float3 rgb4, float threshold4, float softness4, float3 rgb5)
{
    float t1 = smoothstep(threshold1 - softness1, threshold1 + softness1, weight);
    float t2 = smoothstep(threshold2 - softness2, threshold2 + softness2, weight);
    float t3 = smoothstep(threshold3 - softness3, threshold3 + softness3, weight);
    float t4 = smoothstep(threshold4 - softness4, threshold4 + softness4, weight);
    float3 c = lerp(rgb1, rgb2, t1);
    c = lerp(c, rgb3, t2);
    c = lerp(c, rgb4, t3);
    return lerp(c, rgb5, t4);
}

#endif// DefPart(IonRamp, Tool)