/****************************************
*
* 作者： 闪电黑客
* 日期： 2026/09/09
*
* 描述： 透明材料阶段
*        本体预乘 + 内壁压暗 + 正面折射叠加
*        不采样：反射色、折射环境色由 Pass 采好再传入
*
*/

#if DefPart(IvyTransmit, Stage)
#define Def_IvyTransmit_Stage

struct IvyTransmit_BlendIn
{
    /// <summary>
    /// 底色
    /// </summary>
    half3 Rgb;
    /// <summary>
    /// 基础透明度
    /// </summary>
    half Alpha;
    /// <summary>
    /// 折射 0~1：0 空气，约 0.35 玻璃，1 宝石。只作叠加强度，IOR 由 Pass 采折射时使用。
    /// </summary>
    half Refract;
    /// <summary>
    /// 是否正面（外壁）
    /// </summary>
    bool IsFront;
    /// <summary>
    /// 边缘 + 环境反射 + 高光（已含强度）
    /// </summary>
    half3 ReflectRgb;
    /// <summary>
    /// 折射方向上的环境色
    /// </summary>
    half3 RefractRgb;
    /// <summary>
    /// 已乘边缘强度的菲涅尔，用于 Alpha
    /// </summary>
    half Fresnel;
};

struct IvyTransmit_BlendOut
{
    half4 Rgba;
    half3 Rgb;
    half Alpha;
};

/// <summary>
/// 透明合成：预乘本体 + 反射项 + 正面折射。通透内壁乘 0.6。
/// </summary>
IvyTransmit_BlendOut IvyTransmit_Blend(IvyTransmit_BlendIn dataIn)
{
    IvyTransmit_BlendOut dataOut;
    half3 rgb = dataIn.Rgb * dataIn.Alpha + dataIn.ReflectRgb;
    half alpha = saturate(dataIn.Alpha + dataIn.Fresnel);

    half innerScale = (dataIn.IsFront || dataIn.Refract < 1e-4) ? 1.0 : 0.6;
    rgb *= innerScale;
    alpha *= innerScale;

    half refractAmt = saturate(dataIn.Refract);
    if (dataIn.IsFront && refractAmt > 1e-4)
    {
        rgb += dataIn.RefractRgb * dataIn.Rgb * refractAmt;
    }

    dataOut.Rgb = rgb;
    dataOut.Alpha = alpha;
    dataOut.Rgba = half4(rgb, alpha);
    return dataOut;
}

#endif // DefPart(IvyTransmit,Stage)
