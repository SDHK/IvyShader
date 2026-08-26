#if Def(IonPassMainSimple)
#define Def_IonPassMainSimple

//===[必要参数声明]====================================================
// 主贴图：启用颜色系统时作灰度细节图（.r 通道），否则全彩贴图
sampler2D IonArg_MainTex;
float4 IonArg_MainTex_ST;

// 抓取贴图：用于屏幕空间特效（如模糊、折射、后期等）
sampler2D IonArg_GrabTexture;

// ColorMask：RGBA 四通道权重分别对应 Color1 ~ Color4 区域
sampler2D IonArg_SkinMask0;
sampler2D IonArg_SkinMask1;
sampler2D IonArg_SkinMask2;
sampler2D IonArg_SkinMask3;

float4 IonArg_SkinRgb00;
float4 IonArg_SkinRgb01;
float4 IonArg_SkinRgb10;
float4 IonArg_SkinRgb11;
float4 IonArg_SkinRgb20;
float4 IonArg_SkinRgb21;
float4 IonArg_SkinRgb30;
float4 IonArg_SkinRgb31;

float IonArg_LightInfluence;
float IonArg_LightMax;
float IonArg_LightMin;

// EmissiveTex：自发光遮罩灰度图（.r 通道，黑=不发光 白=全发光，默认 black=无自发光）
sampler2D IonArg_EmissiveTex;
float IonArg_EmissiveIntensity;// 自发光强度倍率（与灰度图相乘，0=关闭）

// SkinRamp 光照（固定参考方向，提供不随光源变化的结构性阴影）
float IonArg_SkinRampToggle;// SkinRamp 混合权重（0=不启用，1=完全启用）
float4 IonArg_SkinObjRampPos;// 固定参考方向（世界空间，默认 (0,1,0) 向上）

// SkinRamp 渐变色（分别对基准色、亮色、暗色）
float4 IonArg_RampRgbBase;
float4 IonArg_SkinObjRampRgb0;
float4 IonArg_SkinObjRampRgb1;

float IonArg_SkinObjRampThreshold0;
float IonArg_SkinObjRampThreshold1;
float IonArg_SkinObjRampSoftness;

//皮肤视角渐变色
float IonArg_SkinViewRampThreshold0;
float IonArg_SkinViewRampThreshold1;
float IonArg_SkinViewRampSoftness;


// Ramp 动态光照（灰度，只控制阴影边界，颜色由光源颜色和 SkinRamp 提供）
float IonArg_LightRampThreshold;// 阴影边界位置（lightLambert 轴 0~1）
float IonArg_LightRampSoftness;// 边界过渡宽度（0=硬切卡通）


// 边缘色
float4 IonArg_SkinViewRampRgb0;// 边缘暗颜色
float4 IonArg_SkinViewRampRgb1;// 边缘亮颜色

float4 IonArg_RampRgb1;// 边缘光颜色

float IonArg_RimIntensity;// 边缘光强度（0=关闭）
float IonArg_LightRimSoftness;// 边缘集中度（高=细窄，低=宽泛，建议 2~8）

// 背光边缘光（逆光轮廓光，跟随光源方向）
float IonArg_BackRimIntensity;// 背光强度（0=关闭）
float IonArg_BackLightRimSoftness;// 边缘集中度（建议 2~8）

float IonArg_HighLightIntensity;// 高光强度（0=关闭）
float IonArg_HighLightRimSoftness;// 高光边缘集中度（建议 2~8）

float IonArg_Metallic;
sampler2D IonArg_MetalMask;
float IonArg_MetalSpecularPower;
float IonArg_MetalSpecularIntensity;
float IonArg_MetalReflectIntensity;
float IonArg_MetalRoughness;
sampler2D IonArg_MetalMatCap;
float IonArg_MetalProbeInfluence;
float IonArg_MetalDiffuseScale;

// 特效图
int IonArg_EffectMap0;
int IonArg_EffectMap1;
int IonArg_EffectMap2;
int IonArg_EffectMap3;
int IonArg_EffectMapInside;

// 映射图
int IonArg_VecMap0;
int IonArg_VecMap1;
int IonArg_VecMap2;
int IonArg_VecMap3;


//色板暂定为：10*5 : 白 → 粉 → 红 → 橘 → 橙 → 黄 → 绿 → 青 → 蓝 → 紫
//4*2=8色，4个细节贴图，法线贴图。8个材质枚举。
//通道融合度滑动条

//===[定义宏]====================================================
#define IonKey_Instancing
#define IonKey_Fog
#define IonKey_ForwardBase // 生成 multi_compile_fwdbase，驱动 SHADOWS_DEPTH 等阴影变体编译
#define IonKey_MainLightShadows
#define IonKey_MainLightShadowsCascade
#define IonKey_ShadowsSoft
// #define IonSet_ShadowScreen
// IonSet_ShadowScreen 不启用：
// 屏幕空间阴影依赖不透明物体的深度缓冲，透明物体（ZWrite Off）不写深度，
// 导致采样到身后物体的阴影数据，在透明表面产生矩形投影。
// 改用 light-space 深度图采样，基于顶点世界坐标，不依赖屏幕深度，透明兼容。

//===[引入核心库]====================================================
#define Link_IonBase
#define Link_IonHash
#define Link_IonNoise
#define Link_IonLight
#define Link_IonMatrix
#define Link_IonMath
#define Link_IonVertex
#define Link_IonField
#define Link_IonVecMap
#define Link_IonRamp
#define Link_IonEffect
#include "../../Core/IonCore.hlsl"


struct VertIn
{
    IonVar_PosOs
    IonVar_NrmOs
    IonVar_T0(float2, UV)
};

struct VertOut
{
    IonVar_PosCs
    IonVar_T0(float2, UV)
    IonVar_T1(float3, NrmOs)
    IonVar_T2(float3, PosOs)
    IonVar_T3(float3, NrmWs)
    IonVar_T4(float3, PosWs)
    IonVar_T5(float4, ShadowCoord)
    IonVar_T6(float4, GrabPos)
};

struct FragIn
{
    VertOut VertOut;
    IonVar_ViewFace
};

struct FragOut{ IonVar_TargetRgba };


#pragma vertex Vert
#pragma fragment Frag

VertOut Vert(VertIn vertIn)
{
    VertOut vertOut;
    vertOut.UV = IonMath_Transform2D(vertIn.UV.xy, IonArg_MainTex_ST.xy, IonArg_MainTex_ST.zw);
    vertOut.PosCs = IonMatrix_PosOsToCs(vertIn.PosOs);
    vertOut.NrmOs = vertIn.NrmOs;
    vertOut.PosOs = vertIn.PosOs;
    vertOut.NrmWs = IonMatrix_NrmOsToWs(vertIn.NrmOs);
    vertOut.PosWs = IonMatrix_PosOsToWs(vertIn.PosOs);
    // light-space shadow coord：基于顶点世界坐标变换，不依赖屏幕深度缓冲
    vertOut.ShadowCoord = IonLight_ShadowCoord(vertIn.PosOs, vertOut.PosCs, vertOut.PosWs);
    vertOut.GrabPos = IonBase_GrabScreenPos(vertOut.PosCs);
    return vertOut;
}

FragOut Frag(FragIn fragIn)
{
    float4 posCs = fragIn.VertOut.PosCs;
    float2 uv = fragIn.VertOut.UV;
    float3 nrmOs = fragIn.VertOut.NrmOs;
    float3 posOs = fragIn.VertOut.PosOs;
    float3 nrmWs = fragIn.VertOut.NrmWs;
    float3 posWs = fragIn.VertOut.PosWs;
    float4 shadowCoord = fragIn.VertOut.ShadowCoord;
    float4 grabPos = fragIn.VertOut.GrabPos;
    float viewFace = fragIn.ViewFace;

    //===[透镜折射效果}]===================================================
    float2 grabUV = grabPos.xy / grabPos.w;
    // 简单整屏相对中心放大（先用片元 UV 中心试；更好是物体中心投到屏幕）
    float2 center = float2(0.5, 0.5);
    float zoom = 1.5;
    // >1 放大
    float2 zoomedUV = center + (grabUV - center) / zoom;
    float3 bg = tex2D(IonArg_GrabTexture, zoomedUV).rgb;
    //======

    //===[UV九宫格分区]===================================================
    // uv: 模型 UV0，假设在 [0,1)
    // 防止 uv==1 时落到第 3 格
    uv = saturate(uv);
    uv = min(uv, 0.9999);// 防止 uv==1 时落到第 3 格
    int col = (int)floor(uv.x * 2.0); // 0,1 → u0,u1
    int row = (int)floor(uv.y * 2.0); // 0,1 → v0,v1（左下为 0）
    int visualRow = 1 - row; // 把数学 row0(下) 翻成「上=0」

    // 格子内局部 UV（采细节用）
    float2 localUV = frac(uv * 2.0);
    // uv的九宫格分区索引，0~3
    int uvId = visualRow * 2 + col; // 0..3
    //==================================================================

    // 判断片元是正面还是背面
    bool isFront = viewFace > 0.0;

    half4 mainTex = tex2D(IonArg_MainTex, uv);

    float3 camWs = IonParam_CameraPosWs;
    float3 camOs = IonMatrix_PosWsToOs(camWs);


    // 世界相机到世界坐标的向量
    float3 vecCamToPosWs = IonVecMap_LookTo(camWs, posWs);
    // 世界坐标到世界相机的向量
    float3 vecPosToCamWs = -vecCamToPosWs;


    float3 objWs = IonMatrix_PosOsToWs(float3(0, 0, 0));
    // 世界物体到世界相机的向量
    float3 vecObjToCamWs = IonVecMap_LookTo(objWs, camWs);
    // 世界相机到世界物体的向量
    float3 vecCamToObjWs = -vecObjToCamWs;

    //===[自发光]===================================================
    float emissiveMask = tex2D(IonArg_EmissiveTex, uv).r;
    float emissiveWeight = saturate(emissiveMask * IonArg_EmissiveIntensity);

    //===[场景光照]================================================
    float3 normalWs = normalize(nrmWs);
    //环境光球谐光照，晚上没有球谐光照。
    float3 ambient = ShadeSH9(float4(normalWs, 1));
    IonStruct_Light light = IonLight_MainLight(shadowCoord);
    // 光向下=1，光向上(夜晚)=0
    float sunUp = saturate(light.Direction.y);
    // 光向下=1，光向上(夜晚)=0

    // 光照钳制，避免发光过亮导致溢出
    float3 lightBaseColor = clamp(light.Color * sunUp, emissiveWeight, IonArg_LightMax);
    // 综合距离衰减和阴影衰减，得到最终光照颜色
    float3 lightColor = lightBaseColor * light.DistanceAttenuation * light.ShadowAttenuation;
    lightColor = lightColor + ambient;

    // 计算光照亮度（灰度）
    float lightLuma = saturate(dot(lightColor, float3(0.299, 0.587, 0.114)));
    // 主体光照色影响度，防止过度受光源颜色调制
    float3 mainLightColor = lerp(lightLuma, saturate(lightColor), IonArg_LightInfluence);
    // 当光线消失时，保持固定方向以维持 SkinRamp 的结构性阴影效果
    half3 lightDirection = lerp(IonArg_SkinObjRampPos, light.Direction, ceil(lightLuma));


    //===[皮肤着色]=================================================
    //皮肤细节遮罩
    half4 skinMask = 0;
    //皮肤灰度
    float skinMaskLuma = 0;
    //皮肤颜色
    float3 skinRgb = 0;
    //最终透明度
    float finalAlpha = 1;
    // 根据 uvId 选择对应的纹理和颜色

    //临时颜色！！！！
    IonArg_SkinRgb10 =IonArg_SkinRgb00;
    IonArg_SkinRgb20 =IonArg_SkinRgb00;
    IonArg_SkinRgb30 =IonArg_SkinRgb00;
    IonArg_SkinRgb11 = IonArg_SkinRgb01;
    IonArg_SkinRgb21 = IonArg_SkinRgb01;
    IonArg_SkinRgb31 = IonArg_SkinRgb01;

    float4 skinRgb0 = IonSwitch_Float4(uvId,IonArg_SkinRgb00,IonArg_SkinRgb10,IonArg_SkinRgb20,IonArg_SkinRgb30);
    float4 skinRgb1 = IonSwitch_Float4(uvId,IonArg_SkinRgb01,IonArg_SkinRgb11,IonArg_SkinRgb21,IonArg_SkinRgb31);
    //原图
    switch (uvId)
    {
        case 0:skinMask = tex2D(IonArg_SkinMask0, localUV); break;
        case 1:skinMask = tex2D(IonArg_SkinMask1, localUV); break;
        case 2:skinMask = tex2D(IonArg_SkinMask2, localUV); break;
        case 3:skinMask = tex2D(IonArg_SkinMask3, localUV); break;
        default:skinMask = 1; break;
    }
    //灰度
    skinMaskLuma = IonMath_Luma(skinMask.rgb) * skinMask.a;
    //渐变着色
    skinRgb = lerp(skinRgb0.rgb, skinRgb1.rgb,  skinMaskLuma);
    //最终透明度
    finalAlpha = skinMask.a;

    //===[皮肤渐变喷涂]========================
    //当前皮肤色
    float3 skinHsv = IonMath_RgbToHsv(skinRgb);
    //渐变基准色
    float3 skinRampHsv = IonMath_RgbToHsv(IonArg_RampRgbBase.rgb);

    //===[边缘光颜色]====================================
    float3 rimDeltaHsv1 = IonMath_HsvDelta(IonMath_RgbToHsv(IonArg_RampRgb1.rgb), skinRampHsv);
    float3 rimRgb1 = IonMath_HsvToRgb(IonMath_ApplyHsvDelta(skinHsv , rimDeltaHsv1));
    float3 dirPosToCamWs = normalize(vecPosToCamWs);

    if(IonArg_SkinRampToggle != 0)
    {
        //半Lambert喷涂
        float skinObjRampLambert = IonRamp_Lambert(nrmOs, IonArg_SkinObjRampPos, 0.5);
        //计算当前皮肤色与渐变基准色的 HSV 差值
        float3 skinObjDeltaHsv0 = IonMath_HsvDelta(IonMath_RgbToHsv(IonArg_SkinObjRampRgb0.rgb), skinRampHsv);
        float3 skinObjDeltaHsv1 = IonMath_HsvDelta(IonMath_RgbToHsv(IonArg_SkinObjRampRgb1.rgb), skinRampHsv);
        //根据当前皮肤色与渐变基准色的 HSV 差值，计算出当前皮肤色在各个渐变域的颜色
        float3 skinObjRampRgb0 = IonMath_HsvToRgb(IonMath_ApplyHsvDelta(skinHsv , skinObjDeltaHsv0));
        float3 skinObjRampRgb1 = IonMath_HsvToRgb(IonMath_ApplyHsvDelta(skinHsv , skinObjDeltaHsv1));
        //根据 Lambert 灰度权重，计算出当前片元在各个渐变域的颜色
        skinRgb = IonRamp_Rgb3(
        skinObjRampLambert,
        skinObjRampRgb0, IonArg_SkinObjRampThreshold0, IonArg_SkinObjRampSoftness,
        skinRgb, 1 - IonArg_SkinObjRampThreshold1, IonArg_SkinObjRampSoftness,
        skinObjRampRgb1);

        //重新计算当前皮肤色
        skinHsv = IonMath_RgbToHsv(skinRgb);

        float skinViewRampLambert = IonRamp_Lambert(normalWs,dirPosToCamWs);
        float3 skinViewDeltaHsv0 = IonMath_HsvDelta(IonMath_RgbToHsv(IonArg_SkinViewRampRgb0.rgb), skinRampHsv);
        float3 skinViewDeltaHsv1 = IonMath_HsvDelta(IonMath_RgbToHsv(IonArg_SkinViewRampRgb1.rgb), skinRampHsv);
        float3 skinViewRampRgb0 = IonMath_HsvToRgb(IonMath_ApplyHsvDelta(skinHsv , skinViewDeltaHsv0));
        float3 skinViewRampRgb1 = IonMath_HsvToRgb(IonMath_ApplyHsvDelta(skinHsv , skinViewDeltaHsv1));
        skinRgb = IonRamp_Rgb3(
        skinViewRampLambert, 
        skinViewRampRgb0, IonArg_SkinViewRampThreshold0,IonArg_SkinViewRampSoftness,
        skinRgb,1 - IonArg_SkinViewRampThreshold1, IonArg_SkinViewRampSoftness,
        skinViewRampRgb1);
   }
 

    //===[光照阴影]====================================
    // 光照阴影（灰度，跟随光源方向）
    float lightLambert = IonRamp_Lambert(normalWs, lightDirection, 0.5);
    float lightLambrtGray  = IonRamp_Gray(lightLambert, IonArg_LightRampThreshold, IonArg_LightRampSoftness);
    // 光照强度映射到指定范围，避免过暗或过亮
    lightLambrtGray  = lightLambrtGray  * (IonArg_LightMax - IonArg_LightMin) + IonArg_LightMin;
    //漫反射光照颜色（随光源方向变化）
    float3 diffuseLight = mainLightColor * lightLambrtGray;
 
    //===[边缘光]====================================
    float fresnel = IonRamp_Fresnel(normalWs,dirPosToCamWs, IonArg_LightRimSoftness) * IonArg_RimIntensity * lightLuma;
    half3 rimLight = fresnel * rimRgb1 * lightColor ;

    //===[背光]====================================
    float backRim = IonRamp_BackRim(normalWs, dirPosToCamWs, lightDirection, IonArg_BackLightRimSoftness) * IonArg_BackRimIntensity * lightLuma;
    half3 backRimLight = backRim* rimRgb1 * lightColor ;

    //===[高光]====================================
    float3 H1 = normalize(lightDirection + vecPosToCamWs);
    float high = IonRamp_HighLight(normalWs, H1,IonArg_HighLightRimSoftness) * IonArg_HighLightIntensity * lightLuma;
    half3 highLight = high * skinRgb * lightColor *  lightLambrtGray;// * light.ShadowAttenuation;

    float3 addLight =  rimLight + backRimLight + highLight;
    //===[特效向量映射]=====================================================

    // 0.物体空间视线方向（无限远天空盒，角度跟随物体旋转）
    float3 skyOsVecMap = IonVecMap_SkyOs(camOs, posOs);
    // 1.世界空间视线方向（无限远天空盒，角度跟世界）
    float3 skyWsVecMap = IonVecMap_SkyWs(camWs, posWs);
    // 2.摄像机视线
    float3 camVsVecMap = IonVecMap_CamVs(vecCamToPosWs);
    // 3.镜面反射效果
    float3 reflectVecMap = IonVecMap_Reflect(vecCamToPosWs, normalWs);
    // 4.法线映射到物体表面，跟随物体移动和旋转
    float3 nrmPosOsVecMap = IonVecMap_NrmPosOs(nrmOs, posOs);
    // 5.法线映射到物体表面，跟随物体移动但不旋转
    float3 nrmPosWsVecMap = IonVecMap_NrmPosWs(nrmOs, posOs);
    // 6.法线映射到物体表面，跟随视角同步旋转
    float3 nrmPosVsVecMap = IonVecMap_NrmPosVs(normalWs, posOs);

    float3 vecMap, vecMap0, vecMap1, vecMap2, vecMap3, vecMap4;
    float effectMask = 1;

    vecMap0 = IonSwitch_Float3(IonArg_VecMap0, skyOsVecMap, skyWsVecMap, camVsVecMap, reflectVecMap, nrmPosOsVecMap, nrmPosWsVecMap, nrmPosVsVecMap);
    vecMap1 = IonSwitch_Float3(IonArg_VecMap1, skyOsVecMap, skyWsVecMap, camVsVecMap, reflectVecMap, nrmPosOsVecMap, nrmPosWsVecMap, nrmPosVsVecMap);
    vecMap2 = IonSwitch_Float3(IonArg_VecMap2, skyOsVecMap, skyWsVecMap, camVsVecMap, reflectVecMap, nrmPosOsVecMap, nrmPosWsVecMap, nrmPosVsVecMap);
    vecMap3 = IonSwitch_Float3(IonArg_VecMap3, skyOsVecMap, skyWsVecMap, camVsVecMap, reflectVecMap, nrmPosOsVecMap, nrmPosWsVecMap, nrmPosVsVecMap);

    vecMap = vecMap0;
    vecMap += vecMap1;
    vecMap += vecMap2;
    vecMap += vecMap3;

    //===[对特效图的映射]==
    float tHit = length(skyOsVecMap);
    float tNear, tFar;
    float depth = 1;//假设厚度为1
    if (isFront)
    {
        // 体外看：从表面往里积一段（假厚度，或以后换成背面深度）
        tNear = tHit;
        tFar = tHit + depth;
    }
    else 
    {
        // 体内看背面：从相机积到出口（背面片元）
        tNear = 0.0;
        tFar = tHit + 0.1;
        vecMap = skyOsVecMap; // 内部强制渲染为体积云
    }

    //特效图强遮罩位图
    int effectMapBitMask = 0;
    //根据alpha通道选择特效图,最多支持30种
    //0和1为不启用特效图，2~31为启用特效图
    if(isFront)
    {
        if(uvId == 0)effectMapBitMask |= 1<<IonArg_EffectMap0;
        if(uvId == 1)effectMapBitMask |= 1<<IonArg_EffectMap1;
        if(uvId == 2)effectMapBitMask |= 1<<IonArg_EffectMap2;
        if(uvId == 3)effectMapBitMask |= 1<<IonArg_EffectMap3;
    }
    else
    {
        if(IonArg_EffectMapInside!=0) effectMapBitMask |= 1 << IonArg_EffectMapInside;
    }


    // 位运算判断筛选特效
    //effectMapBitMask 为0和1则不启用特效图
    float3 vol1 = 0, vol2 = 0, vol3 = 0;
    if(effectMapBitMask&(1<<1)) vol1 += IonEffect_VolumeStar(vecMap, camOs, tNear, tFar);
    if(effectMapBitMask&(1<<2)) vol2 += IonEffect_VolumeCrystal(vecMap, camOs, tNear, tFar);
    if(effectMapBitMask&(1<<3)) vol3 += IonEffect_StarNest(vecMap, IonParam_Time.x * 0.1, float2(1, 1));

    // 通道特效混合
    float3 effectMapRgb = 0;
    if(isFront)
    {
        if(uvId == 0) effectMapRgb += IonSwitch_Float3(IonArg_EffectMap0, 0, vol1, vol2, vol3);
        if(uvId == 1) effectMapRgb += IonSwitch_Float3(IonArg_EffectMap1, 0, vol1, vol2, vol3);
        if(uvId == 2) effectMapRgb += IonSwitch_Float3(IonArg_EffectMap2, 0, vol1, vol2, vol3);
        if(uvId == 3) effectMapRgb += IonSwitch_Float3(IonArg_EffectMap3, 0, vol1, vol2, vol3);
    }
    else
    {
        effectMapRgb += IonSwitch_Float3(IonArg_EffectMapInside, 0, vol1, vol2, vol3);
    }

    if(effectMapBitMask==1)effectMapBitMask = 0;
    if(effectMapBitMask>1)effectMapBitMask = 1;

    //===[对映射图的映射]==
    // 投影到平面（类似相机投影视差）
    //float2 tileUV = worldDir.xy / max(abs(worldDir.z), 1e-3);
    // 投影到球面（类似天空盒映射）
    //float3 D1 = normalize(vecMap);
    //float2 tileUV;
    //tileUV.x = atan2(D1.x, D1.z) / (2.0 * 3.14159265) + 0.5;
    //tileUV.y = asin(clamp(D1.y, -1.0, 1.0)) / 3.14159265 + 0.5;
    //effectMapRgb = tex2D(IonArg_MetalMatCap, tileUV).rgb;

    //VecMap是底色。金属是附加反射，不走VecMap的程序图，而是统一一张金属反射图。是否金属走Bool*colorWeight1。

    //===[金属]=====================================================
    // MatCap贴图（VRChat 稳定）
    float2 matcapUV = normalWs.xy * 0.5 + 0.5;
    float3 matcapReflect = tex2D(IonArg_MetalMatCap, matcapUV).rgb;

    float metalMask = saturate(IonArg_Metallic * tex2D(IonArg_MetalMask, uv).r);
    // 金属 tint（金/银/铜来自 skinRgb / Color1）
    float3 metalTint = skinRgb;
    float3 F0 = metalTint;
    // 金属 F0 ≈ 自身颜色
    // 1. 弱漫反射 + 环境底色
    float3 metalDiffuse = metalTint * ambient * IonArg_MetalDiffuseScale;
    metalDiffuse += metalTint * mainLightColor * lightLambrtGray  * IonArg_MetalDiffuseScale;
    // 2. 方向高光（Blinn-Phong）
    float3 H = normalize(lightDirection + vecPosToCamWs);
    float NdotH = saturate(dot(normalWs, H));
    float specPower = lerp(256.0, 16.0, IonArg_MetalRoughness);
    float spec = pow(NdotH, specPower) * lightLambrtGray  * light.ShadowAttenuation;
    float3 specular = skinRgb * spec * mainLightColor * IonArg_MetalSpecularIntensity;
    // 3. 环境反射：MatCap 保底 + SpecCube 增色
    float3 R = reflect(-vecPosToCamWs, normalWs);
    // BRP 反射探针（可选）
    // 粗糙度
    float mip = IonArg_MetalRoughness * 6.0;
    float4 envRaw = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, R, mip);
    float3 probeReflect = DecodeHDR(envRaw, unity_SpecCube0_HDR);
    // 探针混合
    float3 envReflect = lerp(matcapReflect, probeReflect, IonArg_MetalProbeInfluence);
    // 菲涅耳增强边缘反射
    float fresnelMetal = IonRamp_Fresnel(envReflect, vecPosToCamWs, IonArg_LightRimSoftness);
    envReflect *= lerp(1.0, 1.5, fresnelMetal);
    float3 metalReflect = envReflect * F0 * IonArg_MetalReflectIntensity;
    // 4. 金属合成
    half3 metalColor = metalDiffuse + specular + metalReflect;
    // 可选：金属上保留弱 Rim
    metalColor += rimLight * metalMask * 0.5;

    //透镜，水波

    //===[最终混合]=================================================
    half3 dielectric = skinRgb * diffuseLight + addLight;

    half3 finalColor = lerp(dielectric, metalColor, metalMask);
    finalColor = lerp(finalColor, effectMapRgb , effectMapBitMask);

    // 后面最终混合处：
    FragOut fragOut;
    fragOut.TargetRgba = half4(finalColor, finalAlpha);
    return fragOut;

}

#endif// Def(IonPassMainSimple)






// ===星旋效果

//       float iTime = IonParam_Time.y;
//   //float2 uv = (fragData.UV / iResolution.xy) - .5;
//   float2 uv = fragData.UV*0.5;
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