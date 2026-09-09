/****************************************
*
* 作者： 闪电黑客
* 日期： 2026/09/08
*
* 描述： 反射阶段
*
*/

#if DefPart(IvyReflect, Stage)
#define Def_IvyReflect_Stage

#include "../Tool/IvyRamp.hlsl"

struct IvyReflect_SpecularIn
{
    /// <summary>
    /// 皮肤底色
    /// </summary>
    half3 SkinRgb;
    /// <summary>
    /// 朝向相机的世界法线
    /// </summary>
    float3 NrmWs;
    /// <summary>
    /// 点指向相机（已归一化）
    /// </summary>
    float3 ViewDir;
    /// <summary>
    /// 主光方向
    /// </summary>
    float3 LightDir;
    /// <summary>
    /// 主光 Lambert
    /// </summary>
    half Lambert;
    /// <summary>
    /// 环境反射探针色
    /// </summary>
    half3 ProbeRgb;
    /// <summary>
    /// 环境贴图色
    /// </summary>
    half3 EnvMapRgb;
    /// <summary>
    /// MatCap 色
    /// </summary>
    half3 MatCapRgb;
    /// <summary>
    /// 环境贴图相对探针的混合
    /// </summary>
    half EnvMapInfluence;
    /// <summary>
    /// MatCap 相对前一路环境的混合
    /// </summary>
    half MatCapInfluence;

    /// <summary>
    /// 反射光滑度
    /// </summary>
    half ReflectSmoothness;
    /// <summary>
    /// 反射强度（兼作 Gray 阈值，大于 0.5 时均匀化）
    /// </summary>
    half ReflectIntensity;
};

struct IvyReflect_SpecularOut
{
    half3 Rgb;
    half Rough;
    half3 EnvRgb;
    half3 DiffusePart;
    half3 HighLightPart;
    half3 ReflectSpecular;
    half3 ReflectRimLight;
};

/// <summary>
/// NPR 镜面反射：三路环境混合 + 漫射/高光/反射拆分。
/// 只出形（Lambert / ramp），主光颜色在 Pass 出口乘。
/// 探针与贴图须由 Pass 采好再传入。
/// </summary>
IvyReflect_SpecularOut IvyReflect_Specular(IvyReflect_SpecularIn dataIn)
{
    IvyReflect_SpecularOut dataOut;
    dataOut.Rough = 1.0 - dataIn.ReflectSmoothness;
    half3 specColor = max(dataIn.SkinRgb, 0.1);

    float3 dirHighLight = normalize(dataIn.LightDir + dataIn.ViewDir);
    half highLightRamp = IvyRamp_HighLight(dataIn.NrmWs, dirHighLight, dataOut.Rough);

    dataOut.EnvRgb = lerp(dataIn.ProbeRgb, dataIn.EnvMapRgb, dataIn.EnvMapInfluence);
    dataOut.EnvRgb = lerp(dataOut.EnvRgb, dataIn.MatCapRgb, dataIn.MatCapInfluence);

    half fresnel = IvyRamp_Fresnel(dataIn.NrmWs, dataIn.ViewDir, 0.5);
    half phaseUniform = saturate(dataIn.ReflectIntensity * 2.0 - 1.0);
    half reflectRim = IvyRamp_Lambert(dataIn.NrmWs, dataIn.ViewDir, 0.5);
    reflectRim = 1.0 - IvyRamp_Gray(reflectRim, dataIn.ReflectIntensity, 0.5);
    reflectRim = lerp(reflectRim, 1.0, phaseUniform);

    half3 metalLight = dataIn.SkinRgb * dataIn.Lambert;
    half roughDiffuseWeight = dataOut.Rough * dataOut.Rough;
    half smoothCenterFillWeight = (1.0 - reflectRim) * dataIn.ReflectSmoothness;
    dataOut.DiffusePart = metalLight * (roughDiffuseWeight + smoothCenterFillWeight);
    dataOut.HighLightPart = specColor * highLightRamp * dataIn.Lambert;
    dataOut.ReflectSpecular = dataOut.EnvRgb * lerp(dataIn.SkinRgb, 1.0, fresnel) * reflectRim;
    dataOut.ReflectRimLight = specColor * (fresnel * dataIn.ReflectSmoothness);
    dataOut.Rgb = dataOut.DiffusePart + dataOut.ReflectSpecular + dataOut.HighLightPart + dataOut.ReflectRimLight;
    return dataOut;
}

#endif // DefPart(IvyReflect,Stage)
