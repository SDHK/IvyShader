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


float IvyArg_ReflectSmoothness;
float IvyArg_ReflectIntensity;

// 金属环境贴图（CubeMap 和 2D equirectangular）
sampler2D IvyArg_EnvMapTex;
float IvyArg_EnvMapInfluence;

sampler2D IvyArg_MatCapTex;
float IvyArg_MatCapInfluence;

// 特效图
int IvyArg_EffectMap0;
int IvyArg_EffectMap1;
int IvyArg_EffectMap2;
int IvyArg_EffectMap3;
int IvyArg_EffectMap;
int IvyArg_EffectMapInside;
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
#define Link_IvyHash
#define Link_IvyNoise
#define Link_IvyLight
#define Link_IvyMatrix
#define Link_IvyMath
#define Link_IvyVertex
#define Link_IvyField
#define Link_IvyVecMap
#define Link_IvyRamp
#define Link_IvyEffect
#define Link_IvyUv
#include "../../Core/IvyCore.hlsl"


struct VertIn
{
    IvyVar_PosOs
    IvyVar_NrmOs
    IvyVar_T0(float2, UV)
};

struct VertOut
{
    IvyVar_PosCs
    IvyVar_T0(float2, UV)
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
    //vertOut.UV = IvyUv_Transform2D(vertIn.UV.xy, IvyArg_MainTex_ST.xy, IvyArg_MainTex_ST.zw);

    vertOut.UV = vertIn.UV;
    vertOut.PosCs = IvyMatrix_PosOsToCs(vertIn.PosOs);
    vertOut.NrmOs = vertIn.NrmOs;
    vertOut.PosOs = vertIn.PosOs;
    vertOut.NrmWs = IvyMatrix_NrmOsToWs(vertIn.NrmOs);
    vertOut.PosWs = IvyMatrix_PosOsToWs(vertIn.PosOs);
    // light-space shadow coord：基于顶点世界坐标变换，不依赖屏幕深度缓冲
    vertOut.ShadowCoord = IvyLight_ShadowCoord(vertIn.PosOs, vertOut.PosCs, vertOut.PosWs);
    vertOut.GrabPos = IvyBase_GrabScreenPos(vertOut.PosCs);
    return vertOut;
}

FragOut Frag(FragIn fragIn)
{
    //===[片元输入]===================================================
    float4 posCs = fragIn.VertOut.PosCs;
    float2 uv = fragIn.VertOut.UV;
    float3 nrmOs = fragIn.VertOut.NrmOs;
    float3 posOs = fragIn.VertOut.PosOs;
    float3 nrmWs = fragIn.VertOut.NrmWs;
    float3 posWs = fragIn.VertOut.PosWs;
    float4 shadowCoord = fragIn.VertOut.ShadowCoord;
    float4 grabPos = fragIn.VertOut.GrabPos;
    float viewFace = fragIn.ViewFace;
    bool isFront = viewFace > 0.0;

    if(!isFront)
    {
        nrmOs = -nrmOs;
        nrmWs = -nrmWs;
    }

    //===[透镜折射效果]===================================================
    float2 grabUV = grabPos.xy / grabPos.w;
    // 简单整屏相对中心放大（先用片元 UV 中心试；更好是物体中心投到屏幕）
    float2 center = float2(0.5, 0.5);
    float zoom = 1;
    // >1 放大
    float2 zoomedUV = center + (grabUV - center) / zoom;
    float3 bg = tex2D(IvyArg_GrabTexture, zoomedUV).rgb;
    //======


    //===[自发光]===================================================
    float emissiveMask = tex2D(IvyArg_EmissiveTex, uv).r;
    float emissiveWeight = saturate(emissiveMask * IvyArg_EmissiveIntensity);
    //===[场景光照]================================================
    // 环境光球谐光照，晚上没有球谐光照。
    half3 envLight = ShadeSH9(float4(nrmWs, 1));
    // 环境光影响度
    envLight = lerp(IvyMath_Luma(envLight), envLight, IvyArg_EnvLightInfluence);
    // 环境光钳制，避免发光过亮导致溢出
    envLight = clamp(envLight , IvyArg_LightMin, IvyArg_LightMax);

    // 主光源信息
    IvyStruct_Light light = IvyLight_MainLight(shadowCoord);
    half3 lightRgb = light.Rgb;
    half3 lightDir = light.Direction;
    float lightDistAtten = light.DistAtten;
    half lightShadowAtten = light.ShadowAtten;
    // 光照钳制，避免发光过亮导致溢出,但y可能达不到1
    float sunUp = clamp(lightDir.y, 0 , 1)*2;
    half3 lightBaseRgb = clamp(lightRgb * sunUp,IvyArg_LightMin, IvyArg_LightMax);


    // 综合距离衰减和阴影衰减，得到最终光照颜色
    lightRgb = lightBaseRgb * lightDistAtten * lightShadowAtten;
    // 主体光照色影响度，防止过度受光源颜色调制
    half3 mainLightRgb = lerp(IvyMath_Luma(lightRgb), lightRgb, IvyArg_LightInfluence);


    // 如果光线向下，则反转光线方向，让光线始终在上方，保证阴影效果
    if(lightDir.y <= 0 )lightDir.y = -lightDir.y;
    // 当光线消失时，保持固定头顶方向以维持阴影效果
    if(length(lightDir) == 0)lightDir = float3(0,1,0);

    // 计算光照亮度（灰度）
    half lightLuma = IvyMath_Luma(lightRgb);
    //===[变量]===================================================
    float3 camWs = IvyParam_CameraPosWs;
    float3 camOs = IvyMatrix_PosWsToOs(camWs);
    float3 objWs = IvyMatrix_PosOsToWs(float3(0, 0, 0));
    float3 nrmVs = (normalize(camOs-nrmOs));


  //float3   nrmVs = IvyVecMap_LookTo()

    // 向量世界相机到世界坐标
    // 正交投影时，视线方向为相机前方
     float3 vecCamToPosWs;
    if (IvyParam_OrthoParams.w > 0.5)
    {
        vecCamToPosWs = -IvyParam_Matrix_V[2].xyz;
    }
    else
    {
        vecCamToPosWs = IvyVecMap_LookTo(camWs, posWs);
    }

    float3 vecCamToPosOs = IvyVecMap_LookTo(camOs, posOs);
    // 向量世界坐标到世界相机
    float3 vecPosToCamWs = -vecCamToPosWs;
    // 向量世界物体到世界相机
    float3 vecObjToCamWs = IvyVecMap_LookTo(objWs, camWs);
    // 向量世界相机到世界物体
    float3 vecCamToObjWs = -vecObjToCamWs;
    // 方向世界坐标到世界相机
    float3 dirPosToCamWs = normalize(vecPosToCamWs);
    // 方向高光
    float3 dirHighLight = normalize(lightDir + dirPosToCamWs);
 
    //===[UV分区]===================================================
    // uv: 模型 UV0，假设在 [0,1)
    // 防止 uv==1 时落到第 3 格
    uv = min(uv, 0.999999);// 防止 uv==1 时落到第 3 格
    int col = (int)floor(uv.x * 2.0); // 0,1 → u0,u1
    int row = (int)floor(uv.y * 2.0); // 0,1 → v0,v1（左下为 0）
    int visualRow = 1 - row; // 把数学 row0(下) 翻成「上=0」
    // 格子内局部 UV（采细节用）
    float2 localUV = frac(uv * 2.0);
    // uv的九宫格分区索引，0~3
    int uvId = visualRow * 2 + col; // 0..3

    
    //===[皮肤着色]=================================================
    //皮肤细节遮罩
    half4 skinMask = 0;
    //皮肤灰度
    half skinMaskLuma = 0;
    //皮肤颜色
    half3 skinRgb = 0;
    //最终透明度
    half finalAlpha = 1;
    // 根据 uvId 选择对应的纹理和颜色

    //临时颜色！！！！
    //IvyArg_SkinRgb10 =IvyArg_SkinRgb00;
    //IvyArg_SkinRgb20 =IvyArg_SkinRgb00;
    //IvyArg_SkinRgb30 =IvyArg_SkinRgb00;
    //IvyArg_SkinRgb11 = IvyArg_SkinRgb01;
    //IvyArg_SkinRgb21 = IvyArg_SkinRgb01;
    //IvyArg_SkinRgb31 = IvyArg_SkinRgb01;

    half4 skinRgb0 = IvySwitch_Float4(uvId,IvyArg_SkinRgb00,IvyArg_SkinRgb10,IvyArg_SkinRgb20,IvyArg_SkinRgb30);
    half4 skinRgb1 = IvySwitch_Float4(uvId,IvyArg_SkinRgb01,IvyArg_SkinRgb11,IvyArg_SkinRgb21,IvyArg_SkinRgb31);
    //原图
    switch (uvId)
    {
        case 0:skinMask = tex2D(IvyArg_SkinMask0, localUV); break;
        case 1:skinMask = tex2D(IvyArg_SkinMask1, localUV); break;
        case 2:skinMask = tex2D(IvyArg_SkinMask2, localUV); break;
        case 3:skinMask = tex2D(IvyArg_SkinMask3, localUV); break;
        default:skinMask = 1; break;
    }
    //灰度
    skinMaskLuma = IvyMath_Luma(skinMask.rgb);// * skinMask.a
    //渐变着色
    skinRgb = lerp(skinRgb0.rgb, skinRgb1.rgb,  skinMaskLuma);

    //最终透明度
    finalAlpha = skinMask.a;

    //===[皮肤渐变喷涂]========================
    //当前皮肤色
    half3 skinHsv = IvyMath_RgbToHsv(skinRgb);
    //渐变基准色
    half3 skinRampHsv = IvyMath_RgbToHsv(IvyArg_RampRgbBase.rgb);
    float3 skinRgbTest = 0;
    //===[边缘光颜色]====================================
    if(IvyArg_SkinRampToggle != 0)
    {
        //半Lambert喷涂
        half skinObjRampLambert = IvyRamp_Lambert(nrmOs, IvyArg_SkinObjRampPos, 0.5);
        //计算当前皮肤色与渐变基准色的 HSV 差值
        half3 skinObjDeltaHsv0 = IvyMath_HsvDelta(IvyMath_RgbToHsv(IvyArg_SkinObjRampRgb0.rgb), skinRampHsv);
        half3 skinObjDeltaHsv1 = IvyMath_HsvDelta(IvyMath_RgbToHsv(IvyArg_SkinObjRampRgb1.rgb), skinRampHsv);
        //根据当前皮肤色与渐变基准色的 HSV 差值，计算出当前皮肤色在各个渐变域的颜色
        half3 skinObjRampRgb0 = IvyMath_HsvToRgb(IvyMath_ApplyHsvDelta(skinHsv , skinObjDeltaHsv0));
        half3 skinObjRampRgb1 = IvyMath_HsvToRgb(IvyMath_ApplyHsvDelta(skinHsv , skinObjDeltaHsv1));
        //根据 Lambert 灰度权重，计算出当前片元在各个渐变域的颜色
        skinRgb = IvyRamp_Rgb3(
        skinObjRampLambert,
        skinObjRampRgb0, IvyArg_SkinObjRampThreshold0, IvyArg_SkinObjRampSoftness,
        skinRgb, 1 - IvyArg_SkinObjRampThreshold1, IvyArg_SkinObjRampSoftness,
        skinObjRampRgb1);

        //skinRgbTest = skinObjRampLambert;


        //重新计算当前皮肤色
        skinHsv = IvyMath_RgbToHsv(skinRgb);
        half skinViewRampLambert = IvyRamp_Lambert(nrmWs,dirPosToCamWs);
        half3 skinViewDeltaHsv0 = IvyMath_HsvDelta(IvyMath_RgbToHsv(IvyArg_SkinViewRampRgb0.rgb), skinRampHsv);
        half3 skinViewDeltaHsv1 = IvyMath_HsvDelta(IvyMath_RgbToHsv(IvyArg_SkinViewRampRgb1.rgb), skinRampHsv);
        half3 skinViewRampRgb0 = IvyMath_HsvToRgb(IvyMath_ApplyHsvDelta(skinHsv , skinViewDeltaHsv0));
        half3 skinViewRampRgb1 = IvyMath_HsvToRgb(IvyMath_ApplyHsvDelta(skinHsv , skinViewDeltaHsv1));
        skinRgb = IvyRamp_Rgb3(
        skinViewRampLambert, 
        skinViewRampRgb0, IvyArg_SkinViewRampThreshold0,IvyArg_SkinViewRampSoftness,
        skinRgb,1 - IvyArg_SkinViewRampThreshold1, IvyArg_SkinViewRampSoftness,
        skinViewRampRgb1);
   }
    //假sss次表面散射思路，如果摄像逐渐看向主光照，则增加边缘光强度，取暗色为次表面边光颜色。
    //===[光照阴影]====================================
    // 光照阴影（灰度，跟随光源方向）
    half lightLambert = IvyRamp_Lambert(nrmWs, lightDir, 0.5);
    half lightLambrtGray  = IvyRamp_Gray(lightLambert, IvyArg_LightRampThreshold, IvyArg_LightRampSoftness);
    // 光照强度映射到指定范围，避免过暗或过亮
    lightLambrtGray  = lightLambrtGray  * (IvyArg_LightMax - IvyArg_LightShadowMin) + IvyArg_LightShadowMin;
    //漫反射光照颜色（随光源方向变化）
    half3 diffuseLight = envLight + mainLightRgb * lightLambrtGray;
    //===[附加光照]====================================
    //边缘光
    half rimRamp = IvyRamp_Fresnel(nrmWs,dirPosToCamWs, IvyArg_LightRimSoftness) * IvyArg_RimIntensity;
    half3 rimLight = rimRamp * mainLightRgb ;
    //背光
    half backRimRamp = IvyRamp_BackRim(nrmWs, dirPosToCamWs, lightDir, IvyArg_BackLightRimSoftness) * IvyArg_BackRimIntensity ;
    half3 backRimLight = backRimRamp * mainLightRgb ;

    half3 addLight = rimLight + backRimLight;


    //===[特效向量映射]=====================================================
    // 0.物体空间视线方向（无限远天空盒，角度跟随物体旋转）
    float3 skyOsVecMap = vecCamToPosOs;
    // 1.世界空间视线方向（无限远天空盒，角度跟世界）
    float3 skyWsVecMap = vecCamToPosWs;
    // 2.摄像机视线
    float3 camVsVecMap = IvyVecMap_CamVs(vecCamToPosWs);
    // 3.镜面反射效果
    float3 reflectVecMap = IvyVecMap_Reflect(vecCamToPosWs, nrmWs);
    // 4.法线映射到物体表面，跟随物体移动和旋转
    float3 nrmPosOsVecMap = IvyVecMap_NrmPosOs(nrmOs, posOs);
    // 5.法线映射到物体表面，跟随物体移动但不旋转
    float3 nrmPosWsVecMap = IvyVecMap_NrmPosWs(nrmOs, posOs);
    // 6.法线映射到物体表面，跟随视角同步旋转
    float3 nrmPosVsVecMap = IvyVecMap_NrmPosVs(nrmWs, posOs);

    float3 nrmLookVecMap = IvyVecMap_VecLookAt(nrmWs, vecPosToCamWs);
    //float3 nrmLookVecMap = IvyVecMap_VecRotateEuler(nrmOs, float3(0,0,0));

    float3 vecMap, vecMap0, vecMap1, vecMap2, vecMap3, vecMap4;
    float effectMask = 1;

    //int vecMapSwitch = IvySwitch_Float3(uvId,IvyArg_VecMap0,IvyArg_VecMap1,IvyArg_VecMap2,IvyArg_VecMap3);
    //vecMap = IvySwitch_Float3(IvyArg_VecMap0, skyOsVecMap, skyWsVecMap, camVsVecMap, reflectVecMap, nrmPosOsVecMap, nrmPosWsVecMap, nrmPosVsVecMap);

    vecMap = skyOsVecMap; // 3D特效渲染为体积云
    //===[对特效图的映射]==
    float tNear, tFar;
    float depth = 1;//假设厚度为1
    float tHit = length(vecCamToPosOs);
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
    }

    //特效图强遮罩位图,0和1为不启用特效图，2~31为启用特效图,最多支持30种
    int effectMapBitMask = 0;
    //特效图遮罩权重
    float effectMapMask = 0;

    if(IvyArg_EffectMap != 0)
    {
        if(isFront)
        {
            float skinMaskLumaReverse = 1 - skinMaskLuma;
            //根据uvId选择特效图注入方式
            int effectMap = IvySwitch_Float3(uvId,IvyArg_EffectMap0,IvyArg_EffectMap1,IvyArg_EffectMap2,IvyArg_EffectMap3);
            //根据皮肤遮罩的灰度值，计算特效图的遮罩权重
            effectMapMask = IvySwitch_Float3(effectMap, 0, skinMaskLuma, skinMaskLumaReverse,  1);
            //区域特效遮罩。
            if(IvyArg_EffectMap !=0 && effectMapMask != 0) effectMapBitMask |= 1 << IvyArg_EffectMap;
        }
        else
        {
            effectMapMask = 1;
            //区域特效遮罩。
            if(IvyArg_EffectMapInside !=0 )  effectMapBitMask |= 1 << IvyArg_EffectMap;
        }
    }


    // 位运算判断筛选特效
    float3 vol1 = 0, vol2 = 0, vol3 = 0;
    // 特效场扰动
    float2 timecs = float2(cos(IvyParam_Time.x),sin(IvyParam_Time.x));
    //timecs =float2(1,1);
    // 特效平移
    float2 dir = IvyParam_Time.x * 0.1* float2(1, 1);
    dir = float2(0,0);
    if(effectMapBitMask&(1<<1)) vol1 += IvyEffect_VolumeStar(vecMap,  camOs, tNear, tFar,dir,timecs);
    if(effectMapBitMask&(1<<2)) vol2 += IvyEffect_VolumeCrystal(vecMap, camOs, tNear, tFar,dir,timecs);
    if(effectMapBitMask&(1<<3)) vol3 += IvyEffect_StarNest(vecMap,camOs, tNear, tFar, dir,timecs);

    // 通道特效混合
    float3 effectMapRgb = IvySwitch_Float3(IvyArg_EffectMap, 0, vol1, vol2, vol3);
    if(isFront)
    {
        effectMapRgb *= skinRgb;
    }
    else
    {
        //内部用通道3亮色
        effectMapRgb *= IvyArg_SkinRgb31;
    }
    skinRgb = lerp(skinRgb, effectMapRgb, effectMapMask) ;


    //金属为粗糙时需要阴影，边缘反射为瓷器和塑料
    //===[金属]=====================================================
    //粗糙度
    half rough  = 1.0 - IvyArg_ReflectSmoothness;

    //  方向高光（Blinn-Phong）
    //高光遮罩
    half highLightFacingMask = IvyRamp_Lambert(nrmWs, lightDir);
    half highLightRamp = IvyRamp_HighLight(nrmWs, dirHighLight, rough) * highLightFacingMask;

    // 反射模糊度
    half mip = rough * 8.0; 
    // BRP 环境反射探针
    float4 envRaw = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectVecMap, mip);
    float3 probeReflect = DecodeHDR(envRaw, unity_SpecCube0_HDR);
    // 环境贴图反射
    float2 envUV = IvyUv_DirToSphere(reflectVecMap);
    float3 metalEnvReflect = tex2Dlod(IvyArg_EnvMapTex, float4(envUV, 0, mip)).rgb;
    float3 metalReflect = lerp(probeReflect ,metalEnvReflect , IvyArg_EnvMapInfluence);
    // MatCap贴图反射
    float2 matCupUV = IvyUv_DirToMatCap(nrmLookVecMap);
    float3 matCapReflect = tex2Dlod(IvyArg_MatCapTex, float4(matCupUV, 0, mip)).rgb;
    metalReflect = lerp(metalReflect ,matCapReflect , IvyArg_MatCapInfluence);

    // 菲涅耳边缘反射
    half fresnelMetal = IvyRamp_Fresnel(nrmWs, dirPosToCamWs, 0.5) ;

    float phaseUniform = saturate(IvyArg_ReflectIntensity * 2.0 - 1.0); // 0.5~1 → 0~1：均匀化
    half reflectRim = IvyRamp_Lambert(nrmWs,dirPosToCamWs,0.5);
    reflectRim = 1-IvyRamp_Gray(reflectRim,  IvyArg_ReflectIntensity,0.5);
    reflectRim = lerp( reflectRim , 1.0, phaseUniform);

    // 金属高光可用 max(skinRgb,0.2) 防止暗色 albedo 高光过黑（保留原逻辑）
    half3 specColor =  max(skinRgb,0.1);
    // NPR 附加：rim / 背光（不含 highLight，避免和主光高光重复）
    half3 addPart = specColor * addLight;//*notMetal 光滑度代替。
    // 金属共用的漫射光照（已含 Metal）
    half3 metalLight = skinRgb * diffuseLight;
    //粗糙：整面漫射底
    half roughDiffuseWeight = rough * rough;
    //光滑：菲涅尔弱的地方补漫射（填中心变黑），边缘留给 reflectSpec
    half smoothCenterFillWeight = (1.0 - reflectRim) * IvyArg_ReflectSmoothness;
    half3 metalDiffusePart = metalLight * (roughDiffuseWeight + smoothCenterFillWeight);
    // 4 直射 spec：金属/非金属共用，不再 specAlbedo * metalHighLight
    half3 highLightPart = specColor * highLightRamp * mainLightRgb;
    // 5 环境反射
    float3 reflectSpec = metalReflect * lerp(skinRgb, 1, fresnelMetal) * reflectRim;
    float3 finalColor =  metalDiffusePart + reflectSpec + addPart + highLightPart;

    FragOut fragOut;
    fragOut.TargetRgba = half4(finalColor, 1);
    //fragOut.TargetRgba = half4(skinRgbTest.rgb, 0.5);
    return fragOut;

}

#endif// Def(IvyPassMainSimple)



//透镜，水波

// ===星旋效果

//       float iTime = IvyParam_Time.y;
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