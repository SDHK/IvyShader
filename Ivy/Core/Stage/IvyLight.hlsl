/****************************************
*
* 作者： 闪电黑客
* 日期： 2026/09/04 19:28
*
* 描述： 光照阶段集合
*
*/

#if DefPart(IvyLight, Stage)
#define Def_IvyLight_Stage

#include "../Tool/IvyColor.hlsl"
#include "../Tool/IvyRamp.hlsl"

struct IvyLight_DiffuseIn
{
    /// <summary>
    /// 光照颜色
    /// </summary>
    half3 Rgb;
    /// <summary>
    /// 光照方向
    /// </summary>
    half3 Dir;
    /// <summary>
    /// 世界空间法线 
    /// </summary>
    float3 NrmWs;
    /// <summary>
    /// 光照色彩的影响力，范围0~1，0表示不受光照影响，1表示完全受光照影响 
    /// </summary>
    half Influence;
    /// <summary>
    /// 光照强度最小值
    /// </summary>
    half LightMin;
    /// <summary>
    /// 光照强度最大值
    /// </summary>
    half LightMax;
    /// <summary>
    /// 阴影强度最小值 
    /// </summary>
    half ShadowMin;
    /// <summary>
    /// 阴影阈值
    /// </summary>
    half ShadowThreshold;
    /// <summary>
    /// 阴影柔化程度，范围0~1，0表示硬阴影，1表示软阴影 
    /// </summary>
    half ShadowSoftness;

    half DistAtten;
    half ShadowAtten;
};

struct IvyLight_DiffuseOut
{
    half3 Dir;
    half3 Rgb;
    half Luma;
    half Lambert;
    half3 LambertRgb;
    half3 LambertLuma;

};

IvyLight_DiffuseOut IvyLight_Diffuse(IvyLight_DiffuseIn dataIn)
{
    IvyLight_DiffuseOut dataOut;
    dataOut.Rgb =  dataIn.Rgb;
    dataOut.Dir =  dataIn.Dir;

    //太阳光照的方向影响力，y越大，光照越强
    float sunUp = clamp(dataOut.Dir.y, 0 , 1) * 2;
    //光照强度的大小限制
    dataOut.Rgb = clamp(dataOut.Rgb * sunUp, dataIn.LightMin, dataIn.LightMax);
    // 擦光处不用 shadowmap：球体自阴影 terminator 会把纹素拉成锯齿。
    // 背光变暗交给后面的 Lambert，别人投来的影子仍在亮部生效。
    half ndotl = saturate(dot(dataIn.NrmWs, dataIn.Dir));
    half terminator = smoothstep(0.0, 0.2, ndotl);
    half shadowAtten = lerp(1.0, dataIn.ShadowAtten, terminator);
    dataOut.Rgb = dataOut.Rgb * dataIn.DistAtten * shadowAtten;
    //光照色彩的影响力
    dataOut.Rgb = lerp(IvyColor_Luma(dataOut.Rgb) , dataOut.Rgb, dataIn.Influence);
    //如果光线向下，则反转光线方向，让光线始终在上方，保证阴影效果
    if(dataOut.Dir.y<=0) dataOut.Dir.y= -dataOut.Dir.y;
    //当光线消失时，保持固定头顶方向以维持阴影效果
    if(length(dataOut.Dir)==0) dataOut.Dir = float3(0,1,0);

    //计算光照的Lambert值
    half lightLambert = IvyRamp_Lambert(dataIn.NrmWs, dataOut.Dir, 0.5);
    lightLambert = IvyRamp_Gray(lightLambert, dataIn.ShadowThreshold, dataIn.ShadowSoftness);
    //将光照Lambert值限制在阴影最小值和1之间
    lightLambert  =lerp(dataIn.ShadowMin, 1, lightLambert);

    dataOut.Rgb *= lightLambert;
    dataOut.Luma = IvyColor_Luma(dataOut.Rgb);
    dataOut.LambertRgb = dataOut.Rgb;
    dataOut.LambertLuma = dataOut.Luma;
    dataOut.Lambert = lightLambert;
    return dataOut;
}


#endif // DefPart(IvyLight,Stage)
