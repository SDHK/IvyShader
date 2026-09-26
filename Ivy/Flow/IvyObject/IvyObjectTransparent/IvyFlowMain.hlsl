/****************************************

* 作者： 闪电黑客
* 日期： 2026/9/13

* 描述： IvyObjectTransparent 主光配方

*/

#if Def(IvyFlowMain)
#define Def_IvyFlowMain

#define Link_IvyEnvBase
#define Link_IvyEnvLight
#define Link_IvyNoise
#define Link_IvyLight
#define Link_IvyMatrix
#define Link_IvyMath
#define Link_IvyColor
#define Link_IvyVertex
#define Link_IvyField
#define Link_IvyVecMap
#define Link_IvyRamp
#define Link_IvyEffect2D
#define Link_IvyEffect3D
#define Link_IvyUv
#define Link_IvyGeom
#define Link_IvySkin
#define Link_IvyReflect
#define Link_IvyTransmit
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
    //===[几何基础阶段]===================================================
    IvyGeom_BuildIn geomIn;
    geomIn.Uv = fragIn.VertOut.Uv;
    geomIn.PosOs = fragIn.VertOut.PosOs;
    geomIn.NrmOs = fragIn.VertOut.NrmOs;
    geomIn.IsFront = fragIn.ViewFace > 0.0;
    geomIn.CamWs = IvyEnvBase_GetCamWs();
    geomIn.IsOrtho = IvyEnvBase_IsCamOrtho();
    IvyGeom_BuildOut geomOut = IvyGeom_Build(geomIn);
    IvyGeom_VecMapOut vecMaps = IvyGeom_VecMap(geomOut);
    // 方向世界坐标到世界相机
    float3 dirPosToCamWs = normalize(vecMaps.VecPosToCamWs);
    //===[光照漫反射阶段]==================================================
    float4 shadowCoord = IvyFunc_ShadowCoord(geomOut);
    IvyStruct_LightData light = IvyEnvLight_GetMainLight(shadowCoord);
    IvyLight_DiffuseIn lightIn;
    lightIn.NrmWs = geomOut.NrmWsFront;
    lightIn.Rgb = light.Rgb;
    lightIn.Dir = light.Dir;
    lightIn.DistAtten = light.DistAtten;
    lightIn.ShadowAtten = light.ShadowAtten;
    lightIn.Influence = IvyArg_LightInfluence;
    lightIn.LightMin = IvyArg_LightMin;
    lightIn.LightMax = IvyArg_LightMax;
    lightIn.ShadowMin = IvyArg_LightShadowMin;
    lightIn.ShadowThreshold = IvyArg_LightRampThreshold;
    lightIn.ShadowSoftness = IvyArg_LightRampSoftness;
    IvyLight_DiffuseOut lightOut = IvyLight_Diffuse(lightIn);
    //===[附加点光阶段]==================================================
    uint pixelLightCount = IvyEnvLight_GetAddLightCount();
    for (uint lightIndex = 0u; lightIndex < pixelLightCount; ++lightIndex)
    {
        IvyStruct_LightData addLightData = IvyEnvLight_GetAddLight(lightIndex, geomOut.PosWs);
        IvyLight_DiffuseIn addIn = lightIn;
        addIn.Rgb = addLightData.Rgb;
        addIn.Dir = addLightData.Dir;
        addIn.DistAtten = addLightData.DistAtten;
        addIn.ShadowAtten = addLightData.ShadowAtten;
        IvyLight_DiffuseOut addOut = IvyLight_Diffuse(addIn);
        lightOut.Rgb += addOut.Rgb;
    }
    //===[环境光照]================================================
    half3 envLight = IvyEnvLight_LightSH(geomOut.NrmWsFront);
    envLight = lerp(IvyColor_Luma(envLight), envLight, IvyArg_EnvLightInfluence);
  

    //===[Uv分区]===================================================
    int uvId = IvyUv_GridId(geomOut.Uv, 2, 2);
    float2 localUv = IvyUv_GridLocal(geomOut.Uv, 2, 2);
    //===[皮肤着色]=================================================
    // 格内 UV 先乘各花纹 Tiling，再浅视差。平铺 UV 不 saturate，织布才能 repeat。
    float4 skinMaskST = IvySwitch_Float4(uvId, IvyArg_SkinMask0_ST, IvyArg_SkinMask1_ST, IvyArg_SkinMask2_ST, IvyArg_SkinMask3_ST);
    float2 skinUv = IvyUv_Transform2D(localUv, skinMaskST.xy, skinMaskST.zw);
    float3 viewTs = IvyUv_ViewToTangent(geomOut.PosWs, skinUv, dirPosToCamWs, geomOut.NrmWsFront);
    half4 heightMask = IvyFlow_SkinMask(uvId, skinUv);
    half heightLuma = IvyColor_Luma(heightMask.rgb);
    skinUv = IvyUv_Parallax(skinUv, heightLuma, viewTs, 0.1);
    half4 skinMask = IvyFlow_SkinMask(uvId, skinUv);
    //皮肤灰度
    half skinMaskLuma = IvyColor_Luma(skinMask.rgb);// * skinMask.a
   //===[皮肤渐变喷涂]========================
    half4 skinRgb0 = IvySwitch_Float4(uvId,IvyArg_SkinRgb00,IvyArg_SkinRgb10,IvyArg_SkinRgb20,IvyArg_SkinRgb30);
    half4 skinRgb1 = IvySwitch_Float4(uvId,IvyArg_SkinRgb01,IvyArg_SkinRgb11,IvyArg_SkinRgb21,IvyArg_SkinRgb31);
    half3 skinRgb = lerp(skinRgb0.rgb, skinRgb1.rgb,  skinMaskLuma);
    //假sss次表面散射思路，如果摄像逐渐看向主光照，则增加边缘光强度，取暗色为次表面边光颜色。

    if(IvyArg_SkinRampToggle != 0)
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

     //===[特效]=====================================================
    half effectIntensity0 = IvySwitch_Float3(uvId, IvyArg_EffectIntensity00, IvyArg_EffectIntensity10, IvyArg_EffectIntensity20, IvyArg_EffectIntensity30).x;
    half effectIntensity1 = IvySwitch_Float3(uvId, IvyArg_EffectIntensity01, IvyArg_EffectIntensity11, IvyArg_EffectIntensity21, IvyArg_EffectIntensity31).x;
    half effectMask = geomOut.IsFront
        ? lerp(effectIntensity0, effectIntensity1, skinMaskLuma)
        : IvyArg_EffectInside;
    IvyEffect3D_VolumeIn effectIn;
    effectIn.SkinRgb = skinRgb;
    effectIn.InsideRgb = IvyArg_SkinRgb30;
    effectIn.VecMap = vecMaps.VecCamToPosOs;
    effectIn.CamOs = geomOut.CamOs;
    effectIn.IsFront = geomOut.IsFront;
    effectIn.Depth = 1.0;
    effectIn.EffectId = IvyArg_EffectMap;
    effectIn.Mask = effectMask;
    effectIn.Time = IvyEnvBase_GetTime();
    effectIn.PosOffset = float2(0, 0);
    IvyEffect3D_VolumeOut effectOut = IvyEffect3D_Volume(effectIn);
    skinRgb = effectOut.Rgb;

    IvyEffect2D_MapIn effect2dIn;
    effect2dIn.SkinRgb = skinRgb;
    effect2dIn.InsideRgb = IvyArg_SkinRgb30;
    effect2dIn.PosOs = geomOut.PosOs;
    effect2dIn.NrmOs = geomOut.NrmOsFront;
    effect2dIn.IsFront = geomOut.IsFront;
    effect2dIn.EffectId = IvyArg_Effect2DMap;
    effect2dIn.Mask = effectMask;
    effect2dIn.Time = IvyEnvBase_GetTime();
    effect2dIn.PosOffset = float2(1, 1);
    IvyEffect2D_MapOut effect2dOut = IvyEffect2D_Map(effect2dIn);
    skinRgb = effect2dOut.Rgb;
    half stripW = max(
        saturate(effectOut.Mask * effectOut.Field),
        saturate(effect2dOut.Mask * effect2dOut.Field));
    //===[金属反射]=====================================================
    half reflectIntensity0 = IvySwitch_Float3(uvId, IvyArg_ReflectIntensity00, IvyArg_ReflectIntensity10, IvyArg_ReflectIntensity20, IvyArg_ReflectIntensity30).x;
    half reflectSmoothness0 = IvySwitch_Float3(uvId, IvyArg_ReflectSmoothness00, IvyArg_ReflectSmoothness10, IvyArg_ReflectSmoothness20, IvyArg_ReflectSmoothness30).x;
    half reflectIntensity1 = IvySwitch_Float3(uvId, IvyArg_ReflectIntensity01, IvyArg_ReflectIntensity11, IvyArg_ReflectIntensity21, IvyArg_ReflectIntensity31).x;
    half reflectSmoothness1 = IvySwitch_Float3(uvId, IvyArg_ReflectSmoothness01, IvyArg_ReflectSmoothness11, IvyArg_ReflectSmoothness21, IvyArg_ReflectSmoothness31).x;
    half reflectIntensity = lerp(reflectIntensity0, reflectIntensity1, skinMaskLuma);
    half reflectSmoothness = lerp(reflectSmoothness0, reflectSmoothness1, skinMaskLuma);
    half glitter0 = IvySwitch_Float3(uvId, IvyArg_Glitter00, IvyArg_Glitter10, IvyArg_Glitter20, IvyArg_Glitter30).x;
    half glitter1 = IvySwitch_Float3(uvId, IvyArg_Glitter01, IvyArg_Glitter11, IvyArg_Glitter21, IvyArg_Glitter31).x;
    half glitterAmount = lerp(glitter0, glitter1, skinMaskLuma);
    // 反射模糊度
    half mipMap = (1.0 - reflectSmoothness) * 8.0; 
    float3 probeReflect = IvyEnvLight_ProbeReflect(vecMaps.VecMapReflect, mipMap);
    // 环境贴图反射
    float2 envUv = IvyUv_DirToSphere(vecMaps.VecMapReflect);
     float3 metalEnvReflect = IvyFunc_EnvMapTex(envUv, mipMap).rgb;
    // MatCap贴图反射
    float2 matCupUv = IvyUv_DirToMatCap(vecMaps.VecMapRotateFrame);
    float3 matCapReflect = IvyFunc_MatCapTex(matCupUv, mipMap).rgb;
    IvyReflect_SpecularIn reflectIn;
    reflectIn.SkinRgb = skinRgb;
    reflectIn.NrmWs = geomOut.NrmWsFront;
    reflectIn.ViewDir = dirPosToCamWs;
    reflectIn.LightDir = lightOut.Dir;
    reflectIn.Lambert = lightOut.Lambert;
    reflectIn.ProbeRgb = probeReflect;
    reflectIn.EnvMapRgb = metalEnvReflect;
    reflectIn.MatCapRgb = matCapReflect;
    reflectIn.EnvMapInfluence = IvyArg_EnvMapInfluence;
    reflectIn.MatCapInfluence = IvyArg_MatCapInfluence;
    reflectIn.ReflectSmoothness = reflectSmoothness;
    reflectIn.ReflectIntensity = reflectIntensity;
    reflectIn.PosOs = geomOut.PosOs;
    reflectIn.PosOsPixel = fwidth(geomOut.PosOs);
    reflectIn.GlitterAmount = glitterAmount;
    IvyReflect_SpecularOut reflectOut = IvyReflect_Specular(reflectIn);
    //===[附加光效阶段]====================================
    //边缘光
    half rimRamp = IvyRamp_Fresnel(geomOut.NrmWsFront,dirPosToCamWs, IvyArg_LightRimSoftness) * IvyArg_RimIntensity;
    half3 rimLight = rimRamp;
    //背光
    half backRimRamp = IvyRamp_BackRim(geomOut.NrmWsFront, dirPosToCamWs, lightOut.Dir, IvyArg_BackLightRimSoftness) * IvyArg_BackRimIntensity ;
    half3 backRimLight = backRimRamp;
    // 镭射：色轴跟半程 N·H，圆环仍跟视线 N·V
    half film0 = IvySwitch_Float3(uvId, IvyArg_Film00, IvyArg_Film10, IvyArg_Film20, IvyArg_Film30).x;
    half film1 = IvySwitch_Float3(uvId, IvyArg_Film01, IvyArg_Film11, IvyArg_Film21, IvyArg_Film31).x;
    half filmAmt = lerp(film0, film1, skinMaskLuma);
    float2 filmEnvUv = IvyUv_DirToSphere(vecMaps.VecMapReflectOs);
    half filmMask = IvyColor_Luma(IvyFunc_FilmMaskTex(filmEnvUv).rgb);
    float3 halfDir = normalize(lightOut.Dir + dirPosToCamWs);
    half ndoth = saturate(dot(geomOut.NrmWsFront, halfDir));
    half ndotv = saturate(dot(geomOut.NrmWsFront, dirPosToCamWs));
    IvyColor_StainIn filmIn;
    filmIn.T = frac(ndoth + IvyArg_IridescenceHue);
    filmIn.Amount = filmAmt;
    filmIn.Mask = filmMask;
    filmIn.Rings = IvyEffect2D_Rings(ndotv, IvyArg_IridescenceRings, IvyArg_IridescenceRingWidth);
    IvyColor_StainOut filmOut = IvyColor_Stain(filmIn);
    half3 addLight = rimLight + backRimLight + filmOut.Rgb;
    //===[透射折射]====================================
    half transmit0 = IvySwitch_Float3(uvId, IvyArg_Transmit00, IvyArg_Transmit10, IvyArg_Transmit20, IvyArg_Transmit30).x;
    half transmit1 = IvySwitch_Float3(uvId, IvyArg_Transmit01, IvyArg_Transmit11, IvyArg_Transmit21, IvyArg_Transmit31).x;
    half transmit = lerp(transmit0, transmit1, skinMaskLuma) ;

    half3 specRgb = (reflectOut.HighLightPart + reflectOut.ReflectSpecular + reflectOut.ReflectRimLight);
    half3 opaqueRgb = reflectOut.DiffusePart + specRgb + addLight;
    half3 reflectRgb = lerp(opaqueRgb, specRgb + addLight, transmit);
     half3 refractRgb = 0;
    if (geomOut.IsFront && transmit > 1e-4)
    {
        half ior = lerp(1.0, 2.42, transmit);
        float3 refrWs = refract(-dirPosToCamWs, geomOut.NrmWsFront, 1.0 / ior);
        half3 refrProbe = IvyEnvLight_ProbeReflect(refrWs, mipMap);
        float2 refrUv = IvyUv_DirToSphere(refrWs);
        half3 refrEnv = IvyFunc_EnvMapTex(refrUv, mipMap).rgb;
        refractRgb = lerp(refrProbe, refrEnv, IvyArg_EnvMapInfluence);
    }
    half fresnel = IvyRamp_Fresnel(geomOut.NrmWsFront, dirPosToCamWs, 0.5);
    IvyTransmit_BlendIn transmitIn;
    transmitIn.Rgb = skinRgb;
    // 不透：Alpha=1；玻璃：基底半透，边缘菲涅尔只略加不透明度，避免实边
    transmitIn.Alpha = lerp(0.0, 0.15, transmit);
    transmitIn.Refract = transmit;
    transmitIn.IsFront = geomOut.IsFront;
    transmitIn.ReflectRgb = reflectRgb;
    transmitIn.RefractRgb = refractRgb;
    transmitIn.Fresnel = lerp(1.0, fresnel * 0.7, transmit);
    IvyTransmit_BlendOut transmitOut = IvyTransmit_Blend(transmitIn);

    IvyFlow_FragOut fragOut;
    fragOut.TargetRgba = half4(transmitOut.Rgb, transmitOut.Alpha);
#if Link(IvyAudioLink)
    half pulse = IvyFunc_AudioLinkBand((uint)IvyArg_AudioBand);
#else
    half pulse = 0;
#endif
    half3 lit = lightOut.Rgb + envLight;
    half stripMin = min(IvyArg_EmissiveIntensity + pulse * IvyArg_AudioPulse, IvyArg_LightMax);
    half3 litStrip = max(lit, stripMin);
    fragOut.TargetRgba.rgb *= lerp(lit, litStrip, stripW);
    return fragOut;
}

#endif // Def(IvyFlowMain)

/*
//光照根据音效振幅
half pulse = IvyFunc_AudioLinkBand((uint)IvyArg_AudioBand);
half3 lit = lightOut.Rgb + envLight;
half3 litFloor = max(lit, IvyArg_EmissiveIntensity);           // 暗处仍保底
half3 litStrip = litFloor + litFloor * (pulse * IvyArg_AudioPulse); // 相对当前亮度抖
// 或固定加法：litFloor + pulse * IvyArg_AudioPulse;
litStrip = min(litStrip, IvyArg_LightMax);                     // 要封顶再裁
fragOut.TargetRgba.rgb *= lerp(lit, litStrip, stripW);
*/