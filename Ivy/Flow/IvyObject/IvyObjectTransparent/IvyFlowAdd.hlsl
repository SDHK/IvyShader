/****************************************

* 作者： 闪电黑客
* 日期： 2026/9/13

* 描述： IvyObjectTransparent 附加光配方

*/

#if Def(IvyFlowAdd)
#define Def_IvyFlowAdd

#define Link_IvyEnvBase
#define Link_IvyEnvLight
#define Link_IvyNoise
#define Link_IvyLight
#define Link_IvyMatrix
#define Link_IvyMath
#define Link_IvyColor
#define Link_IvyVertex
#define Link_IvyVecMap
#define Link_IvyRamp
#define Link_IvyUv
#define Link_IvyGeom
#define Link_IvySkin
#define Link_IvyReflect
#include "../../../Core/IvyKit.hlsl"
#include "IvyFlowPort.hlsl"
#include "IvyFlowVar.hlsl"

struct IvyFlow_VertIn
{
    float4 PosOs IvyVarIn_PosOs;
    float3 NrmOs IvyVarIn_NrmOs;
    float2 Uv IvyVarIn_Uv;
};

struct IvyFlow_VertOut
{
    float4 PosCs IvyVarOut_PosCs;
    float2 Uv IvyVarOut_Uv;
    float3 NrmOs IvyVarOut_NrmOs;
    float3 PosOs IvyVarOut_PosOs;
    float3 NrmWs IvyVarOut_NrmWs;
    float3 PosWs IvyVarOut_PosWs;
};

struct IvyFlow_FragIn
{
    IvyFlow_VertOut VertOut;
    float ViewFace IvyVarIn_ViewFace;
};

struct IvyFlow_FragOut
{
    float4 TargetRgba IvyVarOut_Target;
};

IvyFlow_VertOut IvyFlow_Vert(IvyFlow_VertIn vertIn)
{
    IvyFlow_VertOut vertOut;
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

half4 IvyFlow_SkinMask(int uvId, float2 uv)
{
    switch (uvId)
    {
        case 0: return IvyFunc_SkinMask0(uv);
        case 1: return IvyFunc_SkinMask1(uv);
        case 2: return IvyFunc_SkinMask2(uv);
        case 3: return IvyFunc_SkinMask3(uv);
        default: return 1;
    }
}

IvyFlow_FragOut IvyFlow_Frag(IvyFlow_FragIn fragIn)
{
    IvyGeom_BuildIn geomIn;
    geomIn.Uv = fragIn.VertOut.Uv;
    geomIn.PosOs = fragIn.VertOut.PosOs;
    geomIn.NrmOs = fragIn.VertOut.NrmOs;
    geomIn.IsFront = fragIn.ViewFace > 0.0;
    geomIn.CamWs = IvyEnvBase_GetCamWs();
    geomIn.IsOrtho = IvyEnvBase_IsCamOrtho();
    IvyGeom_BuildOut geomOut = IvyGeom_Build(geomIn);
    IvyGeom_VecMapOut vecMaps = IvyGeom_VecMap(geomOut);
    float3 dirPosToCamWs = normalize(vecMaps.VecPosToCamWs);

    int uvId = IvyUv_GridId(geomOut.Uv, 2, 2);
    float2 localUv = IvyUv_GridLocal(geomOut.Uv, 2, 2);

    float4 skinMaskST = IvySwitch_Float4(uvId, IvyArg_SkinMask0_ST, IvyArg_SkinMask1_ST, IvyArg_SkinMask2_ST, IvyArg_SkinMask3_ST);
    float2 skinUv = IvyUv_Transform2D(localUv, skinMaskST.xy, skinMaskST.zw);
    float3 viewTs = IvyUv_ViewToTangent(geomOut.PosWs, skinUv, dirPosToCamWs, geomOut.NrmWsFront);
    half4 heightMask = IvyFlow_SkinMask(uvId, skinUv);
    half heightLuma = IvyColor_Luma(heightMask.rgb);
    skinUv = IvyUv_Parallax(skinUv, heightLuma, viewTs, 0.1);
    half4 skinMask = IvyFlow_SkinMask(uvId, skinUv);
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

    float4 shadowCoord = IvyFunc_ShadowCoord(geomOut);
    IvyStruct_LightData light = IvyEnvLight_GetMainLight(shadowCoord, geomOut.PosWs);
    half3 lightRgb = min(light.Rgb * light.DistAtten * light.ShadowAtten, IvyArg_LightMax);
    lightRgb = lerp(IvyColor_Luma(lightRgb), lightRgb, IvyArg_LightInfluence);

    half lambert = IvyRamp_Lambert(geomOut.NrmWsFront, light.Dir, 0.5);
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
    reflectIn.LightDir = light.Dir;
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

    half backRimRamp = IvyRamp_BackRim(geomOut.NrmWsFront, dirPosToCamWs, light.Dir, IvyArg_BackLightRimSoftness) * IvyArg_BackRimIntensity;

    half transmit0 = IvySwitch_Float3(uvId, IvyArg_Transmit00, IvyArg_Transmit10, IvyArg_Transmit20, IvyArg_Transmit30).x;
    half transmit1 = IvySwitch_Float3(uvId, IvyArg_Transmit01, IvyArg_Transmit11, IvyArg_Transmit21, IvyArg_Transmit31).x;
    half transmit = lerp(transmit0, transmit1, skinMaskLuma);

    half3 specRgb = reflectOut.HighLightPart;
    half3 opaqueRgb = reflectOut.DiffusePart + specRgb + backRimRamp;
    half3 shaded = lerp(opaqueRgb, specRgb + backRimRamp, transmit);

    IvyFlow_FragOut fragOut;
    fragOut.TargetRgba = half4(shaded * lightRgb * (1.0 - effectCover), 0);
    return fragOut;
}

#endif // Def_IvyFlowAdd
