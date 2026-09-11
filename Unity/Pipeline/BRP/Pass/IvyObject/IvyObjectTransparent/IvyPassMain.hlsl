#if Def(IvyPassMain)
#define Def_IvyPassMain

//===[定义宏]====================================================
#define IvyKey_Instancing
#define IvyKey_Fog
#define IvyKey_ForwardBase // 生成 multi_compile_fwdbase，驱动 SHADOWS_DEPTH 等阴影变体编译
#define IvyKey_MainLightShadows
#define IvyKey_MainLightShadowsCascade
#define IvyKey_ShadowsSoft
// #define IvySet_ShadowScreen
// IvySet_ShadowScreen 不启用：
// 屏幕空间阴影依赖不透明物体的深度缓冲，透明物体（ZWrite Off）不写深度，
// 导致采样到身后物体的阴影数据，在透明表面产生矩形投影。
// 改用 light-space 深度图采样，基于顶点世界坐标，不依赖屏幕深度，透明兼容。

//===[引入核心库]====================================================
#define Link_IvyBase
//#define Link_IvyHash
#define Link_IvyNoise
#define Link_IvyLight
#define Link_IvyAudioLink

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
    IvyVar_T5(float4, ShadowCoord)
    //IvyVar_T6(float4, GrabPos)
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
    //vertOut.Uv = IvyUv_Transform2D(vertIn.Uv.xy, IvyArg_MainTex_ST.xy, IvyArg_MainTex_ST.zw);
    vertOut.Uv = vertIn.Uv;
    float4 posOs = vertIn.PosOs;
    IvyVertex_PressOut press = IvyVertex_Press(posOs.xyz, vertIn.NrmOs, IvyArg_PressDepth, IvyArg_PressPos.xyz, IvyArg_PressRadius);
    posOs.xyz = press.PosOs;
    vertOut.PosCs = IvyMatrix_PosOsToCs(posOs);
    vertOut.NrmOs = press.NrmOs;
    vertOut.PosOs = posOs;
    vertOut.NrmWs = IvyMatrix_NrmOsToWs(press.NrmOs);
    vertOut.PosWs = IvyMatrix_PosOsToWs(posOs);
    // light-space shadow coord：基于顶点世界坐标变换，不依赖屏幕深度缓冲
    vertOut.ShadowCoord = IvyLight_ShadowCoord(posOs, vertOut.PosCs, vertOut.PosWs);
    //vertOut.GrabPos = ComputeGrabScreenPos(vertOut.PosCs);
    return vertOut;
}

FragOut Frag(FragIn fragIn)
{
    ////===[透镜折射效果]===================================================
    //float4 grabPos = fragIn.VertOut.GrabPos;
    //float2 grabUv = grabPos.xy / grabPos.w;
    //// 简单整屏相对中心放大（先用片元 Uv 中心试；更好是物体中心投到屏幕）
    //float2 center = float2(0.5, 0.5);
    //float zoom = 1;
    //// >1 放大
    //float2 zoomedUv = center + (grabUv - center) / zoom;
    //float3 bg = tex2D(IvyArg_GrabTexture, zoomedUv).rgb;
    //===[几何基础阶段]===================================================
    IvyGeom_BuildIn geomIn;
    geomIn.Uv = fragIn.VertOut.Uv;
    geomIn.PosOs = fragIn.VertOut.PosOs;
    geomIn.NrmOs = fragIn.VertOut.NrmOs;
    geomIn.IsFront = fragIn.ViewFace > 0.0;
    geomIn.CamWs = _WorldSpaceCameraPos;
    geomIn.OrthoParams = unity_OrthoParams;
    IvyGeom_BuildOut geomOut = IvyGeom_Build(geomIn);
    IvyGeom_VecMapOut vecMaps = IvyGeom_VecMap(geomOut);
    // 方向世界坐标到世界相机
    float3 dirPosToCamWs = normalize(vecMaps.VecPosToCamWs);
    //===[Uv分区]===================================================
    int uvId = IvyUv_GridId(geomOut.Uv, 2, 2);
    float2 localUv = IvyUv_GridLocal(geomOut.Uv, 2, 2);
    IvyStruct_Light light = IvyLight_MainLight(fragIn.VertOut.ShadowCoord);
    //===[皮肤着色]=================================================
    // 格内 UV 先乘各花纹 Tiling，再浅视差。平铺 UV 不 saturate，织布才能 repeat。
    float2 skinUv = IvyPass_SkinUv(uvId, localUv);
    float3 viewTs = IvyUv_ViewToTangent(geomOut.PosWs, skinUv, dirPosToCamWs, geomOut.NrmWsFront);
    half4 heightMask = IvyPass_SkinMask(uvId, skinUv);
    half heightLuma = IvyColor_Luma(heightMask.rgb);
    skinUv = IvyUv_Parallax(skinUv, heightLuma, viewTs, 0.1);
    half4 skinMask = IvyPass_SkinMask(uvId, skinUv);
    //皮肤灰度
    half skinMaskLuma = IvyColor_Luma(skinMask.rgb);// * skinMask.a
    //===[光照漫反射阶段]===================================================
    IvyLight_DiffuseIn lightIn;
    lightIn.NrmWs = geomOut.NrmWsFront;
    lightIn.Rgb = light.Rgb;
    lightIn.Dir = light.Direction;
    lightIn.DistAtten = light.DistAtten;
    lightIn.ShadowAtten = light.ShadowAtten;
    lightIn.Influence = IvyArg_LightInfluence;
    lightIn.LightMin = IvyArg_LightMin;
    lightIn.LightMax = IvyArg_LightMax;
    lightIn.ShadowMin = IvyArg_LightShadowMin;
    lightIn.ShadowThreshold = IvyArg_LightRampThreshold;
    lightIn.ShadowSoftness = IvyArg_LightRampSoftness;
    IvyLight_DiffuseOut lightOut = IvyLight_Diffuse(lightIn);

    //===[环境光照]================================================
    half3 envLight = ShadeSH9(float4(geomOut.NrmWsFront, 1));
    envLight = lerp(IvyColor_Luma(envLight), envLight, IvyArg_EnvLightInfluence);
    //渐变着色
    half4 skinRgb0 = IvySwitch_Float4(uvId,IvyArg_SkinRgb00,IvyArg_SkinRgb10,IvyArg_SkinRgb20,IvyArg_SkinRgb30);
    half4 skinRgb1 = IvySwitch_Float4(uvId,IvyArg_SkinRgb01,IvyArg_SkinRgb11,IvyArg_SkinRgb21,IvyArg_SkinRgb31);
    half3 skinRgb = lerp(skinRgb0.rgb, skinRgb1.rgb,  skinMaskLuma);
    //最终透明度
    half  finalAlpha = skinMask.a;

    //===[皮肤渐变喷涂]========================
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
    effectIn.Time = _Time.x;
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
    effect2dIn.Time = _Time.x;
    effect2dIn.PosOffset = float2(1, 1);
    IvyEffect2D_MapOut effect2dOut = IvyEffect2D_Map(effect2dIn);
    skinRgb = effect2dOut.Rgb;
    half stripW = max(
        saturate(effectOut.Mask * effectOut.Field),
        saturate(effect2dOut.Mask * effect2dOut.Field));

    //金属为粗糙时需要阴影，边缘反射为瓷器和塑料
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
    // BRP 环境反射探针
    float4 envRaw = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, vecMaps.VecMapReflect, mipMap);
    float3 probeReflect = DecodeHDR(envRaw, unity_SpecCube0_HDR);
    // 环境贴图反射
    float2 envUv = IvyUv_DirToSphere(vecMaps.VecMapReflect);
    float3 metalEnvReflect = tex2Dlod(IvyArg_EnvMapTex, float4(envUv, 0, mipMap)).rgb;
    // MatCap贴图反射
    float2 matCupUv = IvyUv_DirToMatCap(vecMaps.VecMapRotateFrame);
    float3 matCapReflect = tex2Dlod(IvyArg_MatCapTex, float4(matCupUv, 0, mipMap)).rgb;
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
    //===[附加光照]====================================
    //边缘光
    half rimRamp = IvyRamp_Fresnel(geomOut.NrmWsFront,dirPosToCamWs, IvyArg_LightRimSoftness) * IvyArg_RimIntensity;
    half3 rimLight = rimRamp;
    //背光
    half backRimRamp = IvyRamp_BackRim(geomOut.NrmWsFront, dirPosToCamWs, lightOut.Dir, IvyArg_BackLightRimSoftness) * IvyArg_BackRimIntensity ;
    half3 backRimLight = backRimRamp;

    half3 addLight = rimLight + backRimLight;
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
        float4 refrRaw = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, refrWs, mipMap);
        half3 refrProbe = DecodeHDR(refrRaw, unity_SpecCube0_HDR);
        float2 refrUv = IvyUv_DirToSphere(refrWs);
        half3 refrEnv = tex2Dlod(IvyArg_EnvMapTex, float4(refrUv, 0, mipMap)).rgb;
        refractRgb = lerp(refrProbe, refrEnv, IvyArg_EnvMapInfluence);
    }
    half fresnel = IvyRamp_Fresnel(geomOut.NrmWsFront, dirPosToCamWs, 0.5);
    IvyTransmit_BlendIn transmitIn;
    transmitIn.Rgb = skinRgb;
    transmitIn.Alpha = lerp(0.0, 0.15, transmit);
    transmitIn.Refract = transmit;
    transmitIn.IsFront = geomOut.IsFront;
    transmitIn.ReflectRgb = reflectRgb;
    transmitIn.RefractRgb = refractRgb;
    transmitIn.Fresnel = lerp(1.0, fresnel * 0.9, transmit);
    IvyTransmit_BlendOut transmitOut = IvyTransmit_Blend(transmitIn);

    //===[薄膜干涉]====================================
    half film0 = IvySwitch_Float3(uvId, IvyArg_Film00, IvyArg_Film10, IvyArg_Film20, IvyArg_Film30).x;
    half film1 = IvySwitch_Float3(uvId, IvyArg_Film01, IvyArg_Film11, IvyArg_Film21, IvyArg_Film31).x;
    half filmAmt = lerp(film0, film1, skinMaskLuma);

    // 环境贴图反射
    envUv = IvyUv_DirToSphere((vecMaps.VecMapReflectOs));
    half filmMask = IvyColor_Luma(tex2D(IvyArg_FilmMaskTex, envUv).rgb);//envUv vecMaps.VecCamToPosOs
    // 油膜钉在网格法线上，不用凹凸法线，避免色带被花纹噪声打碎
    half ndotv = saturate(dot(geomOut.NrmWsFront, dirPosToCamWs));
    half heightFactor = geomOut.PosOs.y / max(length(geomOut.PosOs.xyz), 1e-4);
    half t = IvyEffect2D_Axis(ndotv, IvyArg_IridescenceHue - heightFactor * 0.5, IvyArg_IridescenceSpread);
    half filmCover = IvyArg_IridescenceBands >= 2.0
        ? IvyEffect2D_Cover(t, 1.0, IvyArg_IridescenceBands)
        : 1.0;
    IvyColor_StainIn colorIn;
    colorIn.T = t;
    colorIn.Bands = IvyArg_IridescenceBands;
    colorIn.Amount = filmAmt;
    colorIn.Mask = filmMask;
    colorIn.Cover = filmCover;
    colorIn.Rgb = transmitOut.Rgb;
    IvyColor_StainOut colorOut = IvyColor_Stain(colorIn);

    FragOut fragOut;
    fragOut.TargetRgba = half4(colorOut.Rgb, transmitOut.Alpha);
    half pulse = IvyAudioLink_Band((uint)IvyArg_AudioBand);
    half3 lit = lightOut.Rgb + envLight;
    half stripMin = min(IvyArg_EmissiveIntensity + pulse * IvyArg_AudioPulse, IvyArg_LightMax+pulse*IvyArg_AudioPulse);
    half3 litStrip = max(lit, stripMin);
    fragOut.TargetRgba.rgb *= lerp(lit, litStrip, stripW);
    return fragOut;
}


#pragma vertex Vert
#pragma fragment Frag

#endif// Def(IvyObjectTransparent_Main)











//透镜，水波

// ===星旋效果

//       float iTime = _Time.y;
//   //float2 uv = (fragData.Uv / iResolution.xy) - .5;
//   float2 uv = fragData.Uv*0.5;
//float t = iTime * .1 + ((.25 + .05 * sin(iTime * .1))/(length(uv.xy) + .07)) * 2.2;
//float si = sin(t);
//float co = cos(t);
//float2x2 ma = float2x2(co, -si, si, co);

//float v1, v2, v3;
//v1 = v2 = v3 = 0.0;

//float s = 0.0;
//for (int i = 0; i < 100; i++)
//{
//	float3 p = s * float3(uv, 0.0);
//	p.xy = mul(p.xy, ma);
//	p += float3(.22, .3, s - 1.5 - sin(iTime * .13) * .1);
//	for (int i = 0; i < 10; i++)	p = abs(p) / dot(p,p) - 0.659;
//	v1 += dot(p,p) * .0015 * (1.8 + sin(length(uv.xy * 13.0) + .5  - iTime * .2));
//	v2 += dot(p,p) * .0013 * (1.5 + sin(length(uv.xy * 14.5) + 1.2 - iTime * .3));
//	v3 += length(p.xy*10.) * .0003;
//	s  += .035;
//}

//float len = length(uv);
//v1 *= smoothstep(.7, .0, len);
//v2 *= smoothstep(.5, .0, len);
//v3 *= smoothstep(.9, .0, len);

//float3 col = float3( v3 * (1.5 + sin(iTime * .2) * .4),(v1 + v3) * .3,v2) + smoothstep(0.2, .0, len) * .85 + smoothstep(.0, .6, v3) * .3;
//   float4 col001 = float4(min(pow(abs(col), float3(1.2, 1.2, 1.2)), 1.0), 1.0); // ✅ HLSL
//===