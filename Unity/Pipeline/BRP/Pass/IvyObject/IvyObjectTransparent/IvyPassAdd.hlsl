/****************************************
*
* 作者： 闪电黑客
* 日期： 2026/1/19
*
* 描述： IvyObjectTransparent - BRP 附加光源 Pass
*        ForwardAdd：每个点光 / 聚光执行一次
*
* 与 Main 对齐的部分：
* - 2×2 花纹格、Tiling、浅视差、亮暗 lerp、SkinRamp
* - 本灯高光 / 闪粉 / 透射削漫反射、本灯背光
*
* 刻意不加（已在 ForwardBase 里）：
* - 球谐、探针、环境图、MatCap、油膜、视角 Fresnel 边光
* - 3D 体积特效、AudioLink 灯带地板、LightMin、太阳高度 sunUp、光线 Y 翻转
* - 特效区按面板强度把本灯贡献乘成 0，避免布料点光叠在主 Pass 的特效上
*
* Pass：Blend One One, ZWrite Off, Cull Back
*
****************************************/

#if Def(IvyPassAdd)
#define Def_IvyPassAdd

#define IvyKey_Instancing
#define IvyKey_Fog
#define IvyKey_ForwardAdd

#define Link_IvyBase
#define Link_IvyNoise
#define Link_IvyLight
#define Link_IvyMatrix
#define Link_IvyMath
#define Link_IvyColor
#define Link_IvyVertex
#define Link_IvyVecMap
#define Link_IvyRamp
#define Link_IvyEffect2D
#define Link_IvyUv
#define Link_IvyGeom
#define Link_IvySkin
#define Link_IvyReflect
#include "../../../Core/IvyCore.hlsl"

float2 IvyPass_SkinUv(int uvId, float2 localUv)
{
    switch (uvId)
    {
        case 0: return IvyUv_Transform2D(localUv, IvyArg_SkinMask0_ST.xy, IvyArg_SkinMask0_ST.zw);
        case 1: return IvyUv_Transform2D(localUv, IvyArg_SkinMask1_ST.xy, IvyArg_SkinMask1_ST.zw);
        case 2: return IvyUv_Transform2D(localUv, IvyArg_SkinMask2_ST.xy, IvyArg_SkinMask2_ST.zw);
        case 3: return IvyUv_Transform2D(localUv, IvyArg_SkinMask3_ST.xy, IvyArg_SkinMask3_ST.zw);
        default: return localUv;
    }
}

half4 IvyPass_SkinMask(int uvId, float2 uv)
{
    switch (uvId)
    {
        case 0: return tex2D(IvyArg_SkinMask0, uv);
        case 1: return tex2D(IvyArg_SkinMask1, uv);
        case 2: return tex2D(IvyArg_SkinMask2, uv);
        case 3: return tex2D(IvyArg_SkinMask3, uv);
        default: return 1;
    }
}

struct VertIn
{
    IvyVar_PosOs
    IvyVar_NrmOs
    IvyVar_T0(float2, Uv)
};

struct VertOut
{
    IvyVar_PosCs
    IvyVar_T0(float2, Uv)
    IvyVar_T1(float3, NrmOs)
    IvyVar_T2(float3, PosOs)
    IvyVar_T3(float3, NrmWs)
    IvyVar_T4(float3, PosWs)
};

struct FragIn
{
    VertOut VertOut;
    IvyVar_ViewFace
};

struct FragOut{ IvyVar_TargetRgba };

VertOut Vert(VertIn vertIn)
{
    VertOut vertOut;
    vertOut.Uv = vertIn.Uv;
    float4 posOs = vertIn.PosOs;
    IvyVertex_PressOut press = IvyVertex_Press(posOs.xyz, vertIn.NrmOs, IvyArg_PressDepth, IvyArg_PressPos.xyz, IvyArg_PressRadius);
    posOs.xyz = press.PosOs;
    vertOut.PosCs = IvyMatrix_PosOsToCs(posOs);
    vertOut.NrmOs = press.NrmOs;
    vertOut.PosOs = posOs;
    vertOut.NrmWs = IvyMatrix_NrmOsToWs(press.NrmOs);
    vertOut.PosWs = IvyMatrix_PosOsToWs(posOs);
    return vertOut;
}

FragOut Frag(FragIn fragIn)
{
    IvyGeom_BuildIn geomIn;
    geomIn.Uv = fragIn.VertOut.Uv;
    geomIn.PosOs = fragIn.VertOut.PosOs;
    geomIn.NrmOs = fragIn.VertOut.NrmOs;
    geomIn.IsFront = fragIn.ViewFace > 0.0;
    geomIn.CamWs = _WorldSpaceCameraPos;
    geomIn.OrthoParams = unity_OrthoParams;
    IvyGeom_BuildOut geomOut = IvyGeom_Build(geomIn);
    IvyGeom_VecMapOut vecMaps = IvyGeom_VecMap(geomOut);
    float3 dirPosToCamWs = normalize(vecMaps.VecPosToCamWs);

    int uvId = IvyUv_GridId(geomOut.Uv, 2, 2);
    float2 localUv = IvyUv_GridLocal(geomOut.Uv, 2, 2);

    float2 skinUv = IvyPass_SkinUv(uvId, localUv);
    float3 viewTs = IvyUv_ViewToTangent(geomOut.PosWs, skinUv, dirPosToCamWs, geomOut.NrmWsFront);
    half4 heightMask = IvyPass_SkinMask(uvId, skinUv);
    half heightLuma = IvyColor_Luma(heightMask.rgb);
    skinUv = IvyUv_Parallax(skinUv, heightLuma, viewTs, 0.1);
    half4 skinMask = IvyPass_SkinMask(uvId, skinUv);
    half skinMaskLuma = IvyColor_Luma(skinMask.rgb);

    half4 skinRgb0 = IvySwitch_Float4(uvId, IvyArg_SkinRgb00, IvyArg_SkinRgb10, IvyArg_SkinRgb20, IvyArg_SkinRgb30);
    half4 skinRgb1 = IvySwitch_Float4(uvId, IvyArg_SkinRgb01, IvyArg_SkinRgb11, IvyArg_SkinRgb21, IvyArg_SkinRgb31);
    half3 skinRgb = lerp(skinRgb0.rgb, skinRgb1.rgb, skinMaskLuma);

    if (IvyArg_SkinRampToggle != 0)
    {
        IvySkin_RampIn skinRampIn;
        skinRampIn.SkinRgb = skinRgb;
        skinRampIn.RampBaseRgb = IvyArg_RampRgbBase.rgb;
        skinRampIn.Nrm = geomOut.NrmOsFront;
        skinRampIn.RampDir = IvyArg_SkinObjRampPos;
        skinRampIn.LambertScale = 0.5;
        skinRampIn.Rgb0 = IvyArg_SkinObjRampRgb0.rgb;
        skinRampIn.Rgb1 = IvyArg_SkinObjRampRgb1.rgb;
        skinRampIn.Threshold0 = IvyArg_SkinObjRampThreshold0;
        skinRampIn.Threshold1 = IvyArg_SkinObjRampThreshold1;
        skinRampIn.Softness = IvyArg_SkinObjRampSoftness;
        skinRgb = IvySkin_Ramp(skinRampIn).Rgb;

        skinRampIn.SkinRgb = skinRgb;
        skinRampIn.Nrm = geomOut.NrmWsFront;
        skinRampIn.RampDir = dirPosToCamWs;
        skinRampIn.LambertScale = 1.0;
        skinRampIn.Rgb0 = IvyArg_SkinViewRampRgb0.rgb;
        skinRampIn.Rgb1 = IvyArg_SkinViewRampRgb1.rgb;
        skinRampIn.Threshold0 = IvyArg_SkinViewRampThreshold0;
        skinRampIn.Threshold1 = IvyArg_SkinViewRampThreshold1;
        skinRampIn.Softness = IvyArg_SkinViewRampSoftness;
        skinRgb = IvySkin_Ramp(skinRampIn).Rgb;
    }

    half effectIntensity0 = IvySwitch_Float3(uvId, IvyArg_EffectIntensity00, IvyArg_EffectIntensity10, IvyArg_EffectIntensity20, IvyArg_EffectIntensity30).x;
    half effectIntensity1 = IvySwitch_Float3(uvId, IvyArg_EffectIntensity01, IvyArg_EffectIntensity11, IvyArg_EffectIntensity21, IvyArg_EffectIntensity31).x;
    half effectMask = geomOut.IsFront
        ? lerp(effectIntensity0, effectIntensity1, skinMaskLuma)
        : IvyArg_EffectInside;
    half effectCover = (IvyArg_EffectMap != 0) ? saturate(effectMask) : 0;

    float3 lightDir = IvyLight_Direction(geomOut.PosWs);
    float4 shadowCoord = IvyLight_ShadowCoord(float4(geomOut.PosOs, 1.0), geomOut.PosCs, geomOut.PosWs);
    float4 lightCoord = IvyLight_LightCoord(float4(geomOut.PosOs, 1.0));
    float atten = IvyLight_Attenuation(lightCoord, shadowCoord);
    half3 lightRgb = min(_LightColor0.rgb * atten, IvyArg_LightMax);
    lightRgb = lerp(IvyColor_Luma(lightRgb), lightRgb, IvyArg_LightInfluence);

    half lambert = IvyRamp_Lambert(geomOut.NrmWsFront, lightDir, 0.5);
    lambert = IvyRamp_Gray(lambert, IvyArg_LightRampThreshold, IvyArg_LightRampSoftness);
    lambert = lerp(IvyArg_LightShadowMin, 1.0, lambert);

    half reflectIntensity0 = IvySwitch_Float3(uvId, IvyArg_ReflectIntensity00, IvyArg_ReflectIntensity10, IvyArg_ReflectIntensity20, IvyArg_ReflectIntensity30).x;
    half reflectSmoothness0 = IvySwitch_Float3(uvId, IvyArg_ReflectSmoothness00, IvyArg_ReflectSmoothness10, IvyArg_ReflectSmoothness20, IvyArg_ReflectSmoothness30).x;
    half reflectIntensity1 = IvySwitch_Float3(uvId, IvyArg_ReflectIntensity01, IvyArg_ReflectIntensity11, IvyArg_ReflectIntensity21, IvyArg_ReflectIntensity31).x;
    half reflectSmoothness1 = IvySwitch_Float3(uvId, IvyArg_ReflectSmoothness01, IvyArg_ReflectSmoothness11, IvyArg_ReflectSmoothness21, IvyArg_ReflectSmoothness31).x;
    half reflectIntensity = lerp(reflectIntensity0, reflectIntensity1, skinMaskLuma);
    half reflectSmoothness = lerp(reflectSmoothness0, reflectSmoothness1, skinMaskLuma);
    half glitter0 = IvySwitch_Float3(uvId, IvyArg_Glitter00, IvyArg_Glitter10, IvyArg_Glitter20, IvyArg_Glitter30).x;
    half glitter1 = IvySwitch_Float3(uvId, IvyArg_Glitter01, IvyArg_Glitter11, IvyArg_Glitter21, IvyArg_Glitter31).x;
    half glitterAmount = lerp(glitter0, glitter1, skinMaskLuma);

    IvyReflect_SpecularIn reflectIn;
    reflectIn.SkinRgb = skinRgb;
    reflectIn.NrmWs = geomOut.NrmWsFront;
    reflectIn.ViewDir = dirPosToCamWs;
    reflectIn.LightDir = lightDir;
    reflectIn.Lambert = lambert;
    reflectIn.ProbeRgb = 0;
    reflectIn.EnvMapRgb = 0;
    reflectIn.MatCapRgb = 0;
    reflectIn.EnvMapInfluence = 0;
    reflectIn.MatCapInfluence = 0;
    reflectIn.ReflectSmoothness = reflectSmoothness;
    reflectIn.ReflectIntensity = reflectIntensity;
    reflectIn.PosOs = geomOut.PosOs;
    reflectIn.PosOsPixel = fwidth(geomOut.PosOs);
    reflectIn.GlitterAmount = glitterAmount;
    IvyReflect_SpecularOut reflectOut = IvyReflect_Specular(reflectIn);

    half backRimRamp = IvyRamp_BackRim(geomOut.NrmWsFront, dirPosToCamWs, lightDir, IvyArg_BackLightRimSoftness) * IvyArg_BackRimIntensity;

    half transmit0 = IvySwitch_Float3(uvId, IvyArg_Transmit00, IvyArg_Transmit10, IvyArg_Transmit20, IvyArg_Transmit30).x;
    half transmit1 = IvySwitch_Float3(uvId, IvyArg_Transmit01, IvyArg_Transmit11, IvyArg_Transmit21, IvyArg_Transmit31).x;
    half transmit = lerp(transmit0, transmit1, skinMaskLuma);

    half3 specRgb = reflectOut.HighLightPart;
    half3 opaqueRgb = reflectOut.DiffusePart + specRgb + backRimRamp;
    half3 shaded = lerp(opaqueRgb, specRgb + backRimRamp, transmit);

    FragOut fragOut;
    fragOut.TargetRgba = half4(shaded * lightRgb * (1.0 - effectCover), 0);
    return fragOut;
}

#pragma vertex Vert
#pragma fragment Frag

#endif // Def(IvyObjectTransparent_Add)
