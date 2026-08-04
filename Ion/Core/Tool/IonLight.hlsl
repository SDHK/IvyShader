/****************************************

* 作者： 闪电黑客
* 日期： 2026/1/6 20:21

* 描述： 各种光照计算工具函数合集

*/

#if DefPart(IonLight, Tool)
#define Def_IonLight_Tool


//===[Lambert 光照计算]===

// 计算通用 Lambert / 半兰伯特光照贡献
// float3 normalWS            - 世界空间法线（已归一化，调用方负责）
// float3 lightDirection      - 光源方向（已归一化）
// half3  lightColor          - 光源颜色
// half   shadowAttenuation   - 阴影衰减
// float  distanceAttenuation - 距离衰减
// float  scale               - NdotL 缩放系数（默认 1.0）
//                              标准 Lambert: scale=1.0, offset=0.0
//                              半兰伯特:     scale=0.5, offset=0.5
// float  offset              - NdotL 偏移量（默认 0.0）
// float3 return              - 光照贡献
float3 IonLight_Lambert(float3 normalWS, float3 lightDirection, half3 lightColor, half shadowAttenuation, float distanceAttenuation, float scale = 1.0, float offset = 0.0)
{
    // NdotL 映射：scale=1,offset=0 → 标准Lambert；scale=0.5,offset=0.5 → 半兰伯特
    float NdotL = saturate(dot(normalWS, lightDirection) * scale + offset);
    return lightColor * NdotL * distanceAttenuation * shadowAttenuation;
}

//===[Ramp 多域光照着色]===

// 根据 Lambert 权重在 2~4 个颜色域之间平滑过渡（程序化 Ramp，等同于 PS 渐变编辑器）
// float  weight       - Lambert 灰度权重（0=背光 1=全亮，来自 IonLight_Lambert 的 NdotL）
// float3 color1~4     - 各域颜色（1=阴影域 → 4=高光域）
// float  threshold1~3 - 域边界位置（NdotL 轴上 0~1，需满足 t1 < t2 < t3）
// float  softness1~3  - 边界过渡宽度（0=硬切卡通，>0=柔和渐变，建议 0~0.1）
// float3 return       - 混合后的光照颜色（直接乘以 albedo 使用）
//
// 用法示例（三域皮肤）：
//   float NdotL = saturate(dot(N, L) * scale + offset);
//   float3 ramp = IonLight_Ramp(NdotL,
//       _ShadowColor,    0.3, 0.02,
//       _SkinColor,      0.7, 0.02,
//       _HighlightColor, 1.0, 0.05,
//       _HighlightColor);    // color4 与 color3 相同则退化为三域
float3 IonLight_Ramp(float weight, float3 color1, float threshold1, float softness1, float3 color2, float threshold2, float softness2, float3 color3, float threshold3, float softness3, float3 color4, float threshold4, float softness4, float3 color5)
{
    float t1 = smoothstep(threshold1 - softness1, threshold1 + softness1, weight);
    float t2 = smoothstep(threshold2 - softness2, threshold2 + softness2, weight);
    float t3 = smoothstep(threshold3 - softness3, threshold3 + softness3, weight);
    float t4 = smoothstep(threshold4 - softness4, threshold4 + softness4, weight);
    float3 c = lerp(color1, color2, t1);
    c = lerp(c, color3, t2);
    c = lerp(c, color4, t3);
    c = lerp(c, color5, t4);
    return c;
}

//===[菲涅耳边缘光]===

// 计算菲涅耳边缘光强度（正对摄像机的面=0，侧边缘=1）
// float3 normalWS  - 世界空间法线（已归一化）
// float3 viewDir   - 视线方向（normalize(cameraPos - positionWS)）
// float  power     - 边缘集中度（高=细窄边，低=宽泛晕染，建议 2~8）
// float  return    - 菲涅耳强度（0~1）
float IonLight_Fresnel(float3 normalWS, float3 viewDir, float power)
{
    float NdotV = saturate(dot(normalWS, viewDir));
    return pow(1.0 - NdotV, 10 - power * 10);
}

//===[背光边缘光]===

// 计算背光（逆光轮廓光）强度
// 条件：法线背对光源（逆光）且处于视角边缘，才产生亮边
// float3 normalWS  - 世界空间法线（已归一化）
// float3 viewDir   - 视线方向（normalize(cameraPos - positionWS)）
// float3 lightDir  - 光源方向（已归一化，由框架提供）
// float  power     - 边缘集中度（高=细窄，低=宽泛，建议 2~8）
// float  return    - 背光强度（0~1，仅逆光时非零）
float IonLight_BackRim(float3 normalWS, float3 viewDir, float3 lightDir, float power)
{
    float backFacing = saturate(-dot(normalWS, lightDir));
    // 法线背对光源程度
    float rimMask = pow(1.0 - saturate(dot(normalWS, viewDir)), 10 - power * 10);
    // 视角边缘遮罩
    return backFacing * rimMask;
}

//===[Ramp 灰度光照（动态光专用）]===

// 根据 Lambert 权重输出 0~1 灰度光照强度（不带颜色，颜色由光源和 BaseRamp 提供）
// float  weight    - NdotL（0=背光 1=全亮）
// float  threshold - 阴影边界位置（0~1）
// float  softness  - 边界过渡宽度（0=硬切卡通，>0=柔和渐变）
// float  return    - 光照强度（0=完全阴影，1=完全受光）
float IonLight_RampGray(float weight, float threshold, float softness)
{
    return smoothstep(threshold - softness, threshold + softness, weight);
}


#endif// DefPart(IonLight, Tool)