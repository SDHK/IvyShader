/****************************************
*
* 作者： 闪电黑客
* 日期： 2026/09/08
*
* 描述： 3D 体积特效阶段
*        沿视线积体积场，再按遮罩叠回皮肤底色
*        不采样：向量、时间、遮罩由 Pass 填入
*/

#if DefPart(IvyEffect3D, Stage)
#define Def_IvyEffect3D_Stage

#include "../Tool/IvyEffect3D.hlsl"

struct IvyEffect3D_VolumeIn
{
    /// <summary>
    /// 皮肤底色
    /// </summary>
    half3 SkinRgb;
    /// <summary>
    /// 体内着色色（正面仍乘 SkinRgb）
    /// </summary>
    half3 InsideRgb;
    /// <summary>
    /// 体积射线方向（通常为 VecCamToPosOs）
    /// </summary>
    float3 VecMap;
    /// <summary>
    /// 物体空间相机位置
    /// </summary>
    float3 CamOs;
    /// <summary>
    /// 是否正面
    /// </summary>
    bool IsFront;
    /// <summary>
    /// 体外假厚度
    /// </summary>
    half Depth;
    /// <summary>
    /// 特效种类：0 关闭，1 星云，2 晶体，3 星巢
    /// </summary>
    int EffectId;
    /// <summary>
    /// 叠回皮肤的权重（0~1，由 Pass 按花纹暗/亮强度填入）
    /// </summary>
    half Mask;
    /// <summary>
    /// 时间（用于场扰动）
    /// </summary>
    float Time;
    /// <summary>
    /// 体积平移
    /// </summary>
    float2 PosOffset;
};

struct IvyEffect3D_VolumeOut
{
    half3 Rgb;
    half3 EffectRgb;
    half Mask;
    /// <summary>
    /// 体积场灰度，灯带权重用 Mask * Field
    /// </summary>
    half Field;
};

/// <summary>
/// 3D 体积特效：按 EffectId 选一场，沿 VecMap 积分后叠回 SkinRgb。
/// </summary>
IvyEffect3D_VolumeOut IvyEffect3D_Volume(IvyEffect3D_VolumeIn dataIn)
{
    IvyEffect3D_VolumeOut dataOut;
    dataOut.Rgb = dataIn.SkinRgb;
    dataOut.EffectRgb = 0;
    dataOut.Mask = dataIn.Mask;
    dataOut.Field = 0;

    // 关闭特效或遮罩为 0 时直接返回
    if (dataIn.EffectId == 0 || dataIn.Mask == 0) return dataOut;

    float tHit = length(dataIn.VecMap);
    float tNear;
    float tFar;
    if (dataIn.IsFront)
    {
        tNear = tHit;
        tFar = tHit + dataIn.Depth;
    }
    else
    {
        tNear = 0.0;
        tFar = tHit + 0.1;
    }
    float2 timeCs = float2(cos(dataIn.Time), sin(dataIn.Time));

    half3 volumeRgb = 0;
    if (dataIn.EffectId == 1)
    {
        volumeRgb = IvyEffect3D_VolumeStar(dataIn.VecMap, dataIn.CamOs, tNear, tFar, dataIn.PosOffset, timeCs);
    }
    else if (dataIn.EffectId == 2)
    {
        volumeRgb = IvyEffect3D_VolumeCrystal(dataIn.VecMap, dataIn.CamOs, tNear, tFar, dataIn.PosOffset, timeCs);
    }
    else if (dataIn.EffectId == 3)
    {
        volumeRgb = IvyEffect3D_StarNest(dataIn.VecMap, dataIn.CamOs, tNear, tFar, dataIn.PosOffset, timeCs);
    }

    half3 tintRgb = dataIn.IsFront ? dataIn.SkinRgb : dataIn.InsideRgb;
    dataOut.Field = saturate(dot(volumeRgb, half3(0.299, 0.587, 0.114)));
    dataOut.EffectRgb = volumeRgb * tintRgb;
    dataOut.Rgb = lerp(dataIn.SkinRgb, dataOut.EffectRgb, dataOut.Mask);
    return dataOut;
}

#endif // DefPart(IvyEffect3D,Stage)
