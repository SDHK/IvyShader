/****************************************
*
* 作者： 闪电黑客
* 日期： 2026/09/09
*
* 描述： 2D 特效阶段
*        按映射取灰度场，再按遮罩叠回皮肤底色
*        不采样：向量、时间、遮罩由 Pass 填入
*
*/

#if DefPart(IvyEffect2D, Stage)
#define Def_IvyEffect2D_Stage

#include "../Tool/IvyEffect2D.hlsl"

struct IvyEffect2D_MapIn
{
    /// <summary>
    /// 皮肤底色
    /// </summary>
    half3 SkinRgb;
    /// <summary>
    /// 体内着色色
    /// </summary>
    half3 InsideRgb;
    /// <summary>
    /// 物体空间位置（采样坐标）
    /// </summary>
    float3 PosOs;
    /// <summary>
    /// 物体空间法线（仅三平面权重）
    /// </summary>
    float3 NrmOs;
    /// <summary>
    /// 是否正面
    /// </summary>
    bool IsFront;
    /// <summary>
    /// 特效种类：0 关闭，1 云雾，2 线条，3 星巢
    /// </summary>
    int EffectId;
    /// <summary>
    /// 叠回皮肤的权重
    /// </summary>
    half Mask;
    /// <summary>
    /// 时间
    /// </summary>
    float Time;
    /// <summary>
    /// 平移 / 星巢方向
    /// </summary>
    float2 PosOffset;
};

struct IvyEffect2D_MapOut
{
    half3 Rgb;
    half3 EffectRgb;
    half Mask;
    half Field;
};

/// <summary>
/// 2D 特效：按 EffectId 选一场，叠回 SkinRgb。
/// </summary>
IvyEffect2D_MapOut IvyEffect2D_Map(IvyEffect2D_MapIn dataIn)
{
    IvyEffect2D_MapOut dataOut;
    dataOut.Rgb = dataIn.SkinRgb;
    dataOut.EffectRgb = 0;
    dataOut.Mask = dataIn.Mask;
    dataOut.Field = 0;

    if (dataIn.EffectId < 1 || dataIn.EffectId > 3 || dataIn.Mask == 0) return dataOut;

    half field = 0;
    if (dataIn.EffectId == 1)
    {
        field = IvyEffect2D_Cloud(dataIn.PosOs, dataIn.NrmOs, dataIn.Time);
    }
    else if (dataIn.EffectId == 2)
    {
        field = IvyEffect2D_Line(dataIn.PosOs, dataIn.NrmOs, dataIn.Time);
    }
    else if (dataIn.EffectId == 3)
    {
        field = IvyEffect2D_StarNest(dataIn.PosOs, dataIn.Time, dataIn.PosOffset);
    }

    dataOut.Field = field;
    half3 tintRgb = dataIn.IsFront ? dataIn.SkinRgb : dataIn.InsideRgb;
    dataOut.EffectRgb = field * tintRgb;
    dataOut.Rgb = lerp(dataIn.SkinRgb, dataOut.EffectRgb, dataOut.Mask);
    return dataOut;
}

#endif
