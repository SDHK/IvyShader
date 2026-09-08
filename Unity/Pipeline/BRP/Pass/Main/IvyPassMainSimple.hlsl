#if Def(IvyPassMainSimple)
#define Def_IvyPassMainSimple

//===[必要参数声明]====================================================
// 主贴图：启用颜色系统时作灰度细节图（.r 通道），否则全彩贴图
//float4 IvyArg_MainTex_ST;

// 抓取贴图：用于屏幕空间特效（如模糊、折射、后期等）
sampler2D IvyArg_GrabTexture;

// ColorMask：RGBA 四通道权重分别对应 Color1 ~ Color4 区域
sampler2D IvyArg_SkinMask0;
sampler2D IvyArg_SkinMask1;
sampler2D IvyArg_SkinMask2;
sampler2D IvyArg_SkinMask3;

float4 IvyArg_SkinRgb00;
float4 IvyArg_SkinRgb01;
float4 IvyArg_SkinRgb10;
float4 IvyArg_SkinRgb11;
float4 IvyArg_SkinRgb20;
float4 IvyArg_SkinRgb21;
float4 IvyArg_SkinRgb30;
float4 IvyArg_SkinRgb31;

float IvyArg_LightInfluence;
float IvyArg_EnvLightInfluence;
float IvyArg_LightMin;
float IvyArg_LightMax;
float IvyArg_LightShadowMin;

// EmissiveTex：自发光遮罩灰度图（.r 通道，黑=不发光 白=全发光，默认 black=无自发光）
sampler2D IvyArg_EmissiveTex;
float IvyArg_EmissiveIntensity;// 自发光强度倍率（与灰度图相乘，0=关闭）

// SkinRamp 光照（固定参考方向，提供不随光源变化的结构性阴影）
float IvyArg_SkinRampToggle;// SkinRamp 混合权重（0=不启用，1=完全启用）
float4 IvyArg_SkinObjRampPos;// 固定参考方向（世界空间，默认 (0,1,0) 向上）

// SkinRamp 渐变色（分别对基准色、亮色、暗色）
float4 IvyArg_RampRgbBase;
float4 IvyArg_SkinObjRampRgb0;
float4 IvyArg_SkinObjRampRgb1;

float IvyArg_SkinObjRampThreshold0;
float IvyArg_SkinObjRampThreshold1;
float IvyArg_SkinObjRampSoftness;

//皮肤视角渐变色
float IvyArg_SkinViewRampThreshold0;
float IvyArg_SkinViewRampThreshold1;
float IvyArg_SkinViewRampSoftness;


// Ramp 动态光照（灰度，只控制阴影边界，颜色由光源颜色和 SkinRamp 提供）
float IvyArg_LightRampThreshold;// 阴影边界位置（lightLambert 轴 0~1）
float IvyArg_LightRampSoftness;// 边界过渡宽度（0=硬切卡通）


// 边缘色
float4 IvyArg_SkinViewRampRgb0;// 边缘暗颜色
float4 IvyArg_SkinViewRampRgb1;// 边缘亮颜色

float IvyArg_RimIntensity;// 边缘光强度（0=关闭）
float IvyArg_LightRimSoftness;// 边缘集中度（高=细窄，低=宽泛，建议 2~8）

// 背光边缘光（逆光轮廓光，跟随光源方向）
float IvyArg_BackRimIntensity;// 背光强度（0=关闭）
float IvyArg_BackLightRimSoftness;// 边缘集中度（建议 2~8）


float IvyArg_ReflectSmoothness0;
float IvyArg_ReflectIntensity0;

// 金属环境贴图（CubeMap 和 2D equirectangular）
sampler2D IvyArg_EnvMapTex;
float IvyArg_EnvMapInfluence;

sampler2D IvyArg_MatCapTex;
float IvyArg_MatCapInfluence;

// 特效图
int IvyArg_EffectMode0;
int IvyArg_EffectMode1;
int IvyArg_EffectMode2;
int IvyArg_EffectMode3;
int IvyArg_EffectMap;
int IvyArg_EffectModeInside;
// 映射图
int IvyArg_VecMap0;



//色板暂定为：10*5 : 白 → 粉 → 红 → 橘 → 橙 → 黄 → 绿 → 青 → 蓝 → 紫
//4*2=8色，4个细节贴图，法线贴图。8个材质枚举。
//通道融合度滑动条

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

#define Link_IvyMatrix
#define Link_IvyMath
#define Link_IvyVertex
#define Link_IvyField
#define Link_IvyVecMap
#define Link_IvyRamp
#define Link_IvyEffect3D
#define Link_IvyUv
#define Link_IvyGeom
#define Link_IvySkin
#define Link_IvyReflect
#include "../../Core/IvyCore.hlsl"


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
    IvyVar_T6(float4, GrabPos)
};

struct FragIn
{
    VertOut VertOut;
    IvyVar_ViewFace
};

struct FragOut{ IvyVar_TargetRgba };


#pragma vertex Vert
#pragma fragment Frag

VertOut Vert(VertIn vertIn)
{
    VertOut vertOut;
    //vertOut.Uv = IvyUv_Transform2D(vertIn.Uv.xy, IvyArg_MainTex_ST.xy, IvyArg_MainTex_ST.zw);

    vertOut.Uv = vertIn.Uv;
    vertOut.PosCs = IvyMatrix_PosOsToCs(vertIn.PosOs);
    vertOut.NrmOs = vertIn.NrmOs;
    vertOut.PosOs = vertIn.PosOs;
    vertOut.NrmWs = IvyMatrix_NrmOsToWs(vertIn.NrmOs);
    vertOut.PosWs = IvyMatrix_PosOsToWs(vertIn.PosOs);
    // light-space shadow coord：基于顶点世界坐标变换，不依赖屏幕深度缓冲
    vertOut.ShadowCoord = IvyLight_ShadowCoord(vertIn.PosOs, vertOut.PosCs, vertOut.PosWs);
    vertOut.GrabPos = ComputeGrabScreenPos(vertOut.PosCs);
    return vertOut;
}

FragOut Frag(FragIn fragIn)
{
    //===[透镜折射效果]===================================================
    float4 grabPos = fragIn.VertOut.GrabPos;
    float2 grabUv = grabPos.xy / grabPos.w;
    // 简单整屏相对中心放大（先用片元 Uv 中心试；更好是物体中心投到屏幕）
    float2 center = float2(0.5, 0.5);
    float zoom = 1;
    // >1 放大
    float2 zoomedUv = center + (grabUv - center) / zoom;
    float3 bg = tex2D(IvyArg_GrabTexture, zoomedUv).rgb;

    //===[自发光]===================================================
    //float emissiveMask = tex2D(IvyArg_EmissiveTex, geomOut.Uv).r;
    //float emissiveWeight = saturate(emissiveMask * IvyArg_EmissiveIntensity);
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
    // 格子数改这里即可（2×2 / 2×3 / 3×3…）；tex2D switch 与颜色槽仍按实际贴图数手写
    int uvId = IvyUv_GridId(geomOut.Uv, 2, 2);
    float2 localUv = IvyUv_GridLocal(geomOut.Uv, 2, 2);
    //===[光照漫反射阶段]===================================================
    IvyStruct_Light light = IvyLight_MainLight(fragIn.VertOut.ShadowCoord);
    IvyLight_DiffuseIn lightIn;
    lightIn.NrmWs = geomOut.NrmWsFront;
    lightIn.Rgb =light.Rgb;
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
    // 环境光球谐光照，晚上没有球谐光照。
    half3 envLight = ShadeSH9(float4(geomOut.NrmWsFront, 1));
    // 环境光影响度
    envLight = lerp(IvyMath_Luma(envLight), envLight, IvyArg_EnvLightInfluence);
    // 环境光钳制，避免发光过亮导致溢出
    //envLight = clamp(envLight , IvyArg_LightMin, IvyArg_LightMax);

    //===[皮肤着色]=================================================
    // 根据 uvId 选择对应的纹理和颜色

    //临时颜色！！！！
    //IvyArg_SkinRgb10 =IvyArg_SkinRgb00;
    //IvyArg_SkinRgb20 =IvyArg_SkinRgb00;
    //IvyArg_SkinRgb30 =IvyArg_SkinRgb00;
    //IvyArg_SkinRgb11 = IvyArg_SkinRgb01;
    //IvyArg_SkinRgb21 = IvyArg_SkinRgb01;
    //IvyArg_SkinRgb31 = IvyArg_SkinRgb01;
    //皮肤细节遮罩
    half4 skinMask = 0;
    switch (uvId)
    {
        case 0:skinMask = tex2D(IvyArg_SkinMask0, localUv); break;
        case 1:skinMask = tex2D(IvyArg_SkinMask1, localUv); break;
        case 2:skinMask = tex2D(IvyArg_SkinMask2, localUv); break;
        case 3:skinMask = tex2D(IvyArg_SkinMask3, localUv); break;
        default:skinMask = 1; break;
    }
    //皮肤灰度
    half skinMaskLuma = IvyMath_Luma(skinMask.rgb);// * skinMask.a
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

    half3 skinRgbPreEffect = skinRgb;

    //===[特效向量映射]=====================================================
    float3  vecMapSwitch;
    float effectMask = 1;
    vecMapSwitch = IvySwitch_Float3(IvyArg_VecMap0, vecMaps.VecCamToPosOs, vecMaps.VecCamToPosWs, vecMaps.VecMapCamVs, vecMaps.VecMapReflect, vecMaps.VecMapNrmPosOs,  vecMaps.VecMapNrmPosWs, vecMaps.VecMapNrmPosVs);
    //===[对特效图的映射]==
    IvyEffect3D_VolumeIn effectIn;
    effectIn.SkinRgb = skinRgbPreEffect;
    effectIn.InsideRgb = IvyArg_SkinRgb31;
    effectIn.VecMap = vecMaps.VecCamToPosOs;
    effectIn.CamOs = geomOut.CamOs;
    effectIn.IsFront = geomOut.IsFront;
    effectIn.Depth = 1.0;
    effectIn.EffectId = IvyArg_EffectMap;
    effectIn.RegionMode = IvySwitch_Float3(uvId, IvyArg_EffectMode0, IvyArg_EffectMode1, IvyArg_EffectMode2, IvyArg_EffectMode3);
    effectIn.InsideEnable = IvyArg_EffectModeInside;
    effectIn.SkinMaskLuma = skinMaskLuma;
    effectIn.Time = IvyParam_Time.x;
    effectIn.PosOffset = float2(0, 0);
    IvyEffect3D_VolumeOut effectOut = IvyEffect3D_Volume(effectIn);
    skinRgb = effectOut.Rgb;

    //金属为粗糙时需要阴影，边缘反射为瓷器和塑料
    //===[金属反射]=====================================================
    // 反射模糊度
    half mipMap = (1.0 - IvyArg_ReflectSmoothness0) * 8.0; 
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
    reflectIn.EnvLight = envLight;
    reflectIn.LightRgb = lightOut.Rgb;
    reflectIn.ProbeRgb = probeReflect;
    reflectIn.EnvMapRgb = metalEnvReflect;
    reflectIn.MatCapRgb = matCapReflect;
    reflectIn.EnvMapInfluence = IvyArg_EnvMapInfluence;
    reflectIn.MatCapInfluence = IvyArg_MatCapInfluence;
    reflectIn.ReflectSmoothness = IvyArg_ReflectSmoothness0;
    reflectIn.ReflectIntensity = IvyArg_ReflectIntensity0;
    IvyReflect_SpecularOut reflectOut = IvyReflect_Specular(reflectIn);
    //===[附加光照]====================================
    //边缘光
    half rimRamp = IvyRamp_Fresnel(geomOut.NrmWsFront,dirPosToCamWs, IvyArg_LightRimSoftness) * IvyArg_RimIntensity;
    half3 rimLight = rimRamp * (lightOut.Rgb + envLight) ;
    //背光
    half backRimRamp = IvyRamp_BackRim(geomOut.NrmWsFront, dirPosToCamWs, lightOut.Dir, IvyArg_BackLightRimSoftness) * IvyArg_BackRimIntensity ;
    half3 backRimLight = backRimRamp * (lightOut.Rgb + envLight) ;

    half3 addLight = rimLight + backRimLight;

    float3 finalColor = reflectOut.Rgb + addLight;

    FragOut fragOut;
    fragOut.TargetRgba = half4(finalColor, 1);
    return fragOut;
}

#endif// Def(IvyPassMainSimple)



//透镜，水波

// ===星旋效果

//       float iTime = IvyParam_Time.y;
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