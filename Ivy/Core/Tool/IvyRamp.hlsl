/****************************************

* 作者： 闪电黑客
* 日期： 2026/1/6 20:21

* 描述： 各种渐变色计算工具函数合集

*/

#if DefPart(IvyRamp, Tool)
#define Def_IvyRamp_Tool


/// <summary>
/// 计算 Lambert 光照权重
/// </summary>
/// <param name="nrmWs">世界空间法线</param>
/// <param name="lightDirWs">光源方向</param>
/// <param name="scale"> 缩放系数（默认 1.0）</param>
/// <returns>光照权重（0~1）</returns>
float3 IvyRamp_Lambert(float3 nrmWs, float3 lightDirWs, float scale = 1.0)
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
float IvyRamp_Fresnel(float3 nrmWs, float3 viewDirWs, float softness)
{
    float fresnel = 1.0 - saturate(dot(nrmWs, viewDirWs));
    float power = lerp(12.0, 2.0, saturate(softness)); // 细边 → 宽边，但不均匀铺满
    return pow(max(fresnel, 1e-5), power);
}

/// <summary>
/// 计算主光高光强度（Unity Standard 风格 GGX 分布项 D）
/// 用法与原先 Blinn-Phong 版相同：传入法线、半程向量、softness，只换了曲线。
/// 峰值可大于 1，亮度由调用方强度参数（如 MetalHighLightIntensity）控制，勿在此 saturate。
/// </summary>
/// <param name="nrmWs">世界空间法线（已归一化）</param>
/// <param name="lightDir">半程向量 halfDir = normalize(lightDir + viewDir)（命名保留兼容，实际不是纯光源方向）</param>
/// <param name="softness">感知粗糙度：0=镜面细窄，1=粗糙宽泛；对应 1 - MetallicSmoothness</param>
/// <returns>GGX 分布强度（光滑时峰值可很大）</returns>
float IvyRamp_HighLight(float3 nrmWs, float3 lightDir, float softness)
{
    nrmWs = normalize(nrmWs);
    float normalDotHalf = saturate(dot(nrmWs, lightDir));

    // softness → 感知粗糙度；下限 0.05 接近旧 Blinn 最光宽度，避免低模露网格棱角
    // （Unity 防除零用 0.002，会比旧版尖很多）
    float perceptualRoughness = max(saturate(softness), 0.05);

    // alpha = roughness^2（Unity perceptualRoughness → alpha 映射）
    float roughnessAlpha = perceptualRoughness * perceptualRoughness;
    float roughnessAlphaSquared = roughnessAlpha * roughnessAlpha;

    // GGXTerm：D(N·H) = a^2 / (π * ((N·H)^2*(a^2-1)+1)^2)
    float denominator = (normalDotHalf * roughnessAlphaSquared - normalDotHalf) * normalDotHalf + 1.0;
    float ggxDistribution = roughnessAlphaSquared / (UNITY_PI * denominator * denominator + 1e-7);

    return ggxDistribution;
}

//===[背光边缘光]===

// 计算背光（逆光轮廓光）强度
// 条件：法线背对光源（逆光）且处于视角边缘，才产生亮边
// float3 nrmWs  - 世界空间法线（已归一化）
// float3 viewDirWs   - 视线方向（normalize(cameraPos - positionWS)）
// float3 lightDir  - 光源方向（已归一化，由框架提供）
// float  softness  - 边缘集中度（低=细窄，高=宽泛）
// float  return    - 背光强度（0~1，仅逆光时非零）
float IvyRamp_BackRim(float3 nrmWs, float3 viewDirWs, float3 lightDir, float softness)
{
    // 法线背对光源程度（0=正对光源 1=完全背光)
    float backDotNl = saturate(-dot(nrmWs, lightDir));
    // 视角边缘遮罩
    float rimMask = IvyRamp_Fresnel(nrmWs, viewDirWs, softness);
    return backDotNl * rimMask;
}


/// <summary>
/// 根据 Lambert 权重输出 0~1 灰度光照强度（不带颜色，颜色由光源和 BaseRamp 提供）
/// </summary>
/// <param name="weight">Lambert 灰度权重（0=背光 1=全亮）</param>
/// <param name="threshold">阴影边界位置（0~1）</param>
/// <param name="softness">边界过渡宽度（0=硬切卡通，>0=柔和渐变）</param>
/// <returns>光照强度（0=完全阴影，1=完全受光）</returns>
float IvyRamp_Gray(float weight, float threshold, float softness)
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
float3 IvyRamp_Rgb2(float weight, float3 rgb1, float threshold1, float softness1, float3 rgb2)
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
float3 IvyRamp_Rgb3(float weight, float3 rgb1, float threshold1, float softness1, float3 rgb2, float threshold2, float softness2, float3 rgb3)
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
float3 IvyRamp_Rgb4(float weight, float3 rgb1, float threshold1, float softness1, float3 rgb2, float threshold2, float softness2, float3 rgb3, float threshold3, float softness3, float3 rgb4)
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
float3 IvyRamp_Rgb5(float weight, float3 rgb1, float threshold1, float softness1, float3 rgb2, float threshold2, float softness2, float3 rgb3, float threshold3, float softness3, float3 rgb4, float threshold4, float softness4, float3 rgb5)
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

#endif// DefPart(IvyRamp, Tool)