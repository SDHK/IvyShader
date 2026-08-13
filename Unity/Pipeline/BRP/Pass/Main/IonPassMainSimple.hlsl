#if Def(IonPassMainSimple)
#define Def_IonPassMainSimple

//===[必要参数声明]====================================================
// 主贴图：启用颜色系统时作灰度细节图（.r 通道），否则全彩贴图
sampler2D IonArg_MainTex;
float4 IonArg_MainTex_ST;

// 抓取贴图：用于屏幕空间特效（如模糊、折射、后期等）
sampler2D IonArg_GrabTexture;


// ColorMask：RGBA 四通道权重分别对应 Color1 ~ Color4 区域
sampler2D IonArg_TexMask0;
sampler2D IonArg_TexMask1;
sampler2D IonArg_TexMask2;
sampler2D IonArg_TexMask3;

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

// BaseRamp 光照（固定参考方向，提供不随光源变化的结构性阴影）
float IonArg_BaseRampToggle;// BaseRamp 混合权重（0=不启用，1=完全启用）
float4 IonArg_BaseRampDir;// 固定参考方向（世界空间，默认 (0,1,0) 向上）

float4 IonArg_BaseRampColor1;
float4 IonArg_BaseRampColor2;
float4 IonArg_BaseRampColor3;
float4 IonArg_BaseRampColor4;
float4 IonArg_BaseRampColor5;

float IonArg_BaseRampThreshold1;
float IonArg_BaseRampThreshold2;
float IonArg_BaseRampThreshold3;
float IonArg_BaseRampThreshold4;

float IonArg_BaseRampSoftness1;
float IonArg_BaseRampSoftness2;
float IonArg_BaseRampSoftness3;
float IonArg_BaseRampSoftness4;

// Ramp 动态光照（灰度，只控制阴影边界，颜色由光源颜色和 BaseRamp 提供）
float IonArg_LightRampThreshold;// 阴影边界位置（NdotL 轴 0~1）
float IonArg_LightRampSoftness;// 边界过渡宽度（0=硬切卡通）


// 菲涅耳边缘光
float IonArg_RimPower;// 边缘集中度（高=细窄，低=宽泛，建议 2~8）
float IonArg_RimIntensity;// 边缘光强度（0=关闭）

// 背光边缘光（逆光轮廓光，跟随光源方向）
float4 IonArg_BackRimColor;// 背光颜色
float IonArg_BackRimPower;// 边缘集中度（建议 2~8）
float IonArg_BackRimIntensity;// 背光强度（0=关闭）

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
int IonArg_EffectMap1;
int IonArg_EffectMap2;
int IonArg_EffectMap3;
int IonArg_EffectMap4;
int IonArg_EffectMapInside;

// 映射图
int IonArg_DirMap1;
int IonArg_DirMap2;
int IonArg_DirMap3;
int IonArg_DirMap4;


//色板暂定为：10*5 : 白 → 粉 → 红 → 橘 → 橙 → 黄 → 绿 → 青 → 蓝 → 紫
//6+3=18色，6个细节贴图，法线贴图。6个材质枚举。
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
#define Link_IonDirMap
#define Link_IonEffect
#include "../../Core/IonCore.hlsl"


struct VertData
{
    IonVar_PositionOs
    IonVar_Normal
    IonVar_T0(float2, UV)
};

struct FragData
{
    IonVar_PositionCs
    IonVar_T0(float2, UV)
    IonVar_T1(float3, Normal)
    IonVar_T2(float3, PositionOs)
    IonVar_T3(float3, NormalWs)
    IonVar_T4(float3, PositionWs)
    IonVar_T5(float4, ShadowCoord)
    IonVar_T6(float4, GrabPos)
};


#pragma vertex vert
FragData vert(VertData vertData)
{
    FragData fragData;

    fragData.UV = IonMath_Transform2D(vertData.UV.xy, IonArg_MainTex_ST.xy, IonArg_MainTex_ST.zw);
    fragData.PositionCs = IonMatrix_PosOsToCs(vertData.PositionOs);
    fragData.Normal = vertData.Normal;
    fragData.PositionOs = vertData.PositionOs;
    fragData.NormalWs = IonMatrix_NrmOsToWs(vertData.Normal);
    fragData.PositionWs = IonMatrix_PosOsToWs(vertData.PositionOs);
    // light-space shadow coord：基于顶点世界坐标变换，不依赖屏幕深度缓冲
    fragData.ShadowCoord = IonLight_ShadowCoord(vertData.PositionOs, fragData.PositionCs, fragData.PositionWs);
    fragData.GrabPos = IonBase_GrabScreenPos(fragData.PositionCs);
    return fragData;
}

#pragma fragment frag
half4 frag(FragData fragData, float facing : VFACE) : SV_Target
{
    //===[透镜折射效果}]===================================================
    float2 grabUV = fragData.GrabPos.xy / fragData.GrabPos.w;
    // 简单整屏相对中心放大（先用片元 UV 中心试；更好是物体中心投到屏幕）
    float2 center = float2(0.5, 0.5);
    float zoom = 1.5;
    // >1 放大
    float2 zoomedUV = center + (grabUV - center) / zoom;
    float3 bg = tex2D(IonArg_GrabTexture, zoomedUV).rgb;
    //======

    //===[UV九宫格分区]===================================================
    // uv: 模型 UV0，假设在 [0,1)
    float2 uv = fragData.UV;
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
    bool isFront = facing > 0.0;

    half4 mainTex = tex2D(IonArg_MainTex, fragData.UV);

    float3 camWs = IonParam_CameraPosWs;
    float3 camOs = IonMatrix_PosWsToOs(camWs);

    float3 posWs = fragData.PositionWs;
    float3 posOs = fragData.PositionOs;
    float3 nrmWs = fragData.NormalWs;
    float3 nrmOs = fragData.Normal;

    // 世界相机到世界坐标的向量
    float3 dirCamToPosWs = IonDirMap_LookTo(camWs, fragData.PositionWs);
    // 世界坐标到世界相机的向量
    float3 dirPosToCamWs = -dirCamToPosWs;


    float3 objWs = IonMatrix_PosOsToWs(float3(0, 0, 0));
    // 世界物体到世界相机的向量
    float3 dirObjToCamWs = IonDirMap_LookTo(objWs, camWs);
    // 世界相机到世界物体的向量
    float3 dirCamToObjWs = -dirObjToCamWs;

    //===[自发光]===================================================
    float emissiveMask = tex2D(IonArg_EmissiveTex, fragData.UV).r;
    float emissiveWeight = saturate(emissiveMask * IonArg_EmissiveIntensity);

    //===[场景光照]================================================
    float3 normalWs = normalize(fragData.NormalWs);
    //环境光球谐光照，晚上没有球谐光照。
    float3 ambient = ShadeSH9(float4(normalWs, 1));
    IonStruct_Light light = IonLight_MainLight(fragData.ShadowCoord);
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
    // 当光线消失时，保持固定方向以维持 BaseRamp 的结构性阴影效果
    half3 lightDirection = lerp(IonArg_BaseRampDir, light.Direction, ceil(lightLuma));


    //===[颜色混合]=================================================
    //原图+透明度
    half4 texMask = 0;
    //灰度
    float maskLuma = 0;
    //颜色
    float3 baseColor = 0;
    //透明度
    float finalAlpha = 0;
    // 根据 uvId 选择对应的纹理和颜色
    IonArg_SkinRgb10 =IonArg_SkinRgb00;
    IonArg_SkinRgb20 =IonArg_SkinRgb00;
    IonArg_SkinRgb30 =IonArg_SkinRgb00;

    float4 color0 = IonSwitch_Float4(uvId,IonArg_SkinRgb00,IonArg_SkinRgb10,IonArg_SkinRgb20,IonArg_SkinRgb30);
    float4 color1 = IonSwitch_Float4(uvId,IonArg_SkinRgb01,IonArg_SkinRgb11,IonArg_SkinRgb21,IonArg_SkinRgb31);
   
    //原图
    switch (uvId)
    {
        case 0:texMask = tex2D(IonArg_TexMask0, localUV); break;
        case 1:texMask = tex2D(IonArg_TexMask1, localUV); break;
        case 2:texMask = tex2D(IonArg_TexMask2, localUV); break;
        case 3:texMask = tex2D(IonArg_TexMask3, localUV); break;
        default:texMask = 1; break;
    }
    //灰度
    maskLuma  = IonMath_Luma(texMask.rgb) * texMask.a;
    //渐变着色
    baseColor = lerp(color0.rgb, color1.rgb, 1 - maskLuma );
    //透明度
    finalAlpha = texMask.a;



    // BaseRamp：固定方向结构性阴影（定义颜色区间，受光源强度/阴影调制，不自发光）
    // 将固定方向转换到世界空间
    float3 baseRampDirWs = IonMatrix_PosOsToWs(IonArg_BaseRampDir).xyz;
    // 从观察空间转换到世界空间
    //float3 baseRampDirWs = IonMatrix_PosVsToWs( IonArg_BaseRampDir).xyz;
    // 光源方向当做阴影用
    //float3 baseRampDirWs = light.Direction;

    float NdotBase = saturate(dot(nrmOs, IonArg_BaseRampDir.xyz) * 0.5 + 0.5);

    // 计算法线与固定方向的夹角，映射到 0~1 作为 BaseRamp 权重
    float3 N = normalize(nrmOs);
    float3 D = normalize(IonArg_BaseRampDir.xyz);
    float cosTheta = clamp(dot(N, D), -1.0, 1.0);
    float angle = acos(cosTheta) * (180.0 / UNITY_PI);
    // 0 ~ 180（角度）
    float NdotBaseLine = 1 - angle / 180.0;


    //float3 offsetColor1 = (IonArg_BaseRampColor1 - IonArg_BaseRampColor3).rgb;
    //float3 offsetColor2 = (IonArg_BaseRampColor2 - IonArg_BaseRampColor3).rgb;
    //float3 offsetColor4 = (IonArg_BaseRampColor4 - IonArg_BaseRampColor3).rgb;
    //float3 offsetColor5 = (IonArg_BaseRampColor5 - IonArg_BaseRampColor3).rgb;

    //float3 baseRampColor = IonLight_Ramp(NdotBaseLine, baseColor + offsetColor1, IonArg_BaseRampThreshold1, IonArg_BaseRampSoftness1, baseColor + offsetColor2, IonArg_BaseRampThreshold2, IonArg_BaseRampSoftness2, baseColor, IonArg_BaseRampThreshold3, IonArg_BaseRampSoftness3, baseColor + offsetColor4, IonArg_BaseRampThreshold4, IonArg_BaseRampSoftness4, baseColor + offsetColor5);


    float3 refHsv  = IonMath_RgbToHsv(IonArg_BaseRampColor3.rgb);
    float3 baseHsv = IonMath_RgbToHsv(saturate(baseColor));

    float3 deltaHsv1 = IonMath_HsvDelta(IonMath_RgbToHsv(IonArg_BaseRampColor1.rgb), refHsv);
    float3 deltaHsv2 = IonMath_HsvDelta(IonMath_RgbToHsv(IonArg_BaseRampColor2.rgb), refHsv);
    float3 deltaHsv4 = IonMath_HsvDelta(IonMath_RgbToHsv(IonArg_BaseRampColor4.rgb), refHsv);
    float3 deltaHsv5 = IonMath_HsvDelta(IonMath_RgbToHsv(IonArg_BaseRampColor5.rgb), refHsv);

    float3 rampColor1 = IonMath_HsvToRgb(IonMath_ApplyHsvDelta(baseHsv, deltaHsv1));
    float3 rampColor2 = IonMath_HsvToRgb(IonMath_ApplyHsvDelta(baseHsv, deltaHsv2));
    float3 rampColor3 = baseColor;
    float3 rampColor4 = IonMath_HsvToRgb(IonMath_ApplyHsvDelta(baseHsv, deltaHsv4));
    float3 rampColor5 = IonMath_HsvToRgb(IonMath_ApplyHsvDelta(baseHsv, deltaHsv5));

    float3 baseRampColor = IonLight_Ramp(
    NdotBaseLine,
    rampColor1, IonArg_BaseRampThreshold1, IonArg_BaseRampSoftness1,
    rampColor2, IonArg_BaseRampThreshold2, IonArg_BaseRampSoftness2,
    rampColor3, IonArg_BaseRampThreshold3, IonArg_BaseRampSoftness3,
    rampColor4, IonArg_BaseRampThreshold4, IonArg_BaseRampSoftness4,
    rampColor5);



    // 混合NdotBase 是为了让BaseRampColor 随法线方向变化而变化
    //baseRampColor = (baseRampColor * (NdotBase * 0.5 + 0.5));
    baseColor = lerp(baseColor, baseRampColor, IonArg_BaseRampToggle);




    //=======================================
    // Ramp：动态光照（灰度，跟随光源方向）
    float NdotL = saturate(dot(normalWs, lightDirection) * 0.5 + 0.5);
    float rampGray = IonLight_RampGray(NdotL, IonArg_LightRampThreshold, IonArg_LightRampSoftness);
    // 光照强度映射到指定范围，避免过暗或过亮
    rampGray = rampGray * (IonArg_LightMax - IonArg_LightMin) + IonArg_LightMin;

    // 菲涅耳边缘光（始终存在，不依赖光源）
    float fresnel = IonLight_Fresnel(normalWs, normalize (dirPosToCamWs), (IonArg_RimPower + lightLuma) * 0.5);
    IonArg_RimIntensity = IonArg_RimIntensity * (IonArg_LightMax + lightLuma);
    half3 rimLight = baseColor * lightColor * fresnel * IonArg_RimIntensity;

    // 背光边缘光（逆光时才亮，颜色受光源颜色调制）
    float backRim = IonLight_BackRim(normalWs, normalize(dirPosToCamWs), lightDirection, (IonArg_BackRimPower + lightLuma) * 0.5);
    IonArg_BackRimIntensity = IonArg_BackRimIntensity * (IonArg_LightMax + lightLuma);
    half3 backRimLight = baseColor * lightColor * backRim * IonArg_BackRimIntensity;

    float3 dynamicShading = mainLightColor * rampGray + rimLight + backRimLight;
    // 合并：颜色 + 动态光照（随光源）
    //half3 finalColor = baseColor * dynamicShading;

    //===[特效向量映射]=====================================================

    // 0.物体空间视线方向（无限远天空盒，角度跟随物体旋转）
    float3 skyOsDirMap = IonDirMap_SkyOs(camOs, posOs);
    // 1.世界空间视线方向（无限远天空盒，角度跟世界）
    float3 skyWsDirMap = IonDirMap_SkyWs(camWs, posWs);
    // 2.摄像机视线
    float3 camVsDirMap = IonDirMap_CamVs(dirCamToPosWs);
    // 3.镜面反射效果
    float3 reflectDirMap = IonDirMap_Reflect(dirCamToPosWs, normalWs);
    // 4.法线映射到物体表面，跟随物体移动和旋转
    float3 nrmPosOsDirMap = IonDirMap_NrmPosOs(fragData.Normal, fragData.PositionOs);
    // 5.法线映射到物体表面，跟随物体移动但不旋转
    float3 nrmPosWsDirMap = IonDirMap_NrmPosWs(fragData.Normal, fragData.PositionOs);
    // 6.法线映射到物体表面，跟随视角同步旋转
    float3 nrmPosVsDirMap = IonDirMap_NrmPosVs(normalWs, fragData.PositionOs);

    float3 dirMap, dirMap1, dirMap2, dirMap3, dirMap4;
    float effectMask = 0;

    dirMap1 = IonSwitch_Float3(IonArg_DirMap1, skyOsDirMap, skyWsDirMap, camVsDirMap, reflectDirMap, nrmPosOsDirMap, nrmPosWsDirMap, nrmPosVsDirMap);
    dirMap2 = IonSwitch_Float3(IonArg_DirMap2, skyOsDirMap, skyWsDirMap, camVsDirMap, reflectDirMap, nrmPosOsDirMap, nrmPosWsDirMap, nrmPosVsDirMap);
    dirMap3 = IonSwitch_Float3(IonArg_DirMap3, skyOsDirMap, skyWsDirMap, camVsDirMap, reflectDirMap, nrmPosOsDirMap, nrmPosWsDirMap, nrmPosVsDirMap);
    dirMap4 = IonSwitch_Float3(IonArg_DirMap4, skyOsDirMap, skyWsDirMap, camVsDirMap, reflectDirMap, nrmPosOsDirMap, nrmPosWsDirMap, nrmPosVsDirMap);

    dirMap = dirMap1;
    dirMap += dirMap2 ;
    dirMap += dirMap3 ;
    dirMap += dirMap4 ;
    //effectMask = colorWeight1.r + colorWeight2.r + colorWeight3.r + colorWeight4.r;

    //===[对特效图的映射]==
    float tHit = length(skyOsDirMap);
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
        dirMap = skyOsDirMap; // 内部强制渲染为体积云
    }

    //特效图强遮罩位图
    int effectMapMask = 0;
    //根据alpha通道选择特效图,最多支持30种
    //0和1为不启用特效图，2~31为启用特效图
    if(isFront)
    {
        //if(colorWeight1 !=0)effectMapMask |= 1<<IonArg_EffectMap1;
        //if(colorWeight2 !=0)effectMapMask |= 1<<IonArg_EffectMap2;
        //if(colorWeight3 !=0)effectMapMask |= 1<<IonArg_EffectMap3;
        //if(colorWeight4 !=0)effectMapMask |= 1<<IonArg_EffectMap4;
    }
    else
    {
        if(IonArg_EffectMapInside!=0) effectMapMask |= 1 << IonArg_EffectMapInside;
    }

    // 位运算判断筛选特效
    //effectMapMask 为0和1则不启用特效图
    float3 vol1 = 0, vol2 = 0, vol3 = 0;
    if(effectMapMask&(1<<1)) vol1 += IonEffect_VolumeStar(dirMap, camOs, tNear, tFar);
    if(effectMapMask&(1<<2)) vol2 += IonEffect_VolumeCrystal(dirMap, camOs, tNear, tFar);
    if(effectMapMask&(1<<3)) vol3 += IonEffect_StarNest(dirMap, IonParam_Time.x * 0.1, float2(1, 1));

    // 通道特效混合
    float3 effectMapRgb = 0;
    if(isFront)
    {
        //effectMapRgb += IonSwitch_Float3(IonArg_EffectMap1, 0, vol1, vol2, vol3) * colorWeight1;
        //effectMapRgb += IonSwitch_Float3(IonArg_EffectMap2, 0, vol1, vol2, vol3) * colorWeight2;
        //effectMapRgb += IonSwitch_Float3(IonArg_EffectMap3, 0, vol1, vol2, vol3) * colorWeight3;
        //effectMapRgb += IonSwitch_Float3(IonArg_EffectMap4, 0, vol1, vol2, vol3) * colorWeight4;
    }
    else
    {
        effectMapRgb += IonSwitch_Float3(IonArg_EffectMapInside, 0, vol1, vol2, vol3);
    }


    //===[对映射图的映射]==
    // 投影到平面（类似相机投影视差）
    //float2 tileUV = worldDir.xy / max(abs(worldDir.z), 1e-3);
    // 投影到球面（类似天空盒映射）
    //float3 D1 = normalize(dirMap);
    //float2 tileUV;
    //tileUV.x = atan2(D1.x, D1.z) / (2.0 * 3.14159265) + 0.5;
    //tileUV.y = asin(clamp(D1.y, -1.0, 1.0)) / 3.14159265 + 0.5;
    //effectMapRgb = tex2D(IonArg_MetalMatCap, tileUV).rgb;

    //DirMap是底色。金属是附加反射，不走DirMap的程序图，而是统一一张金属反射图。是否金属走Bool*colorWeight1。

    //===[金属]=====================================================
    // MatCap贴图（VRChat 稳定）
    float2 matcapUV = normalWs.xy * 0.5 + 0.5;
    float3 matcapReflect = tex2D(IonArg_MetalMatCap, matcapUV).rgb;

    float metalMask = saturate(IonArg_Metallic * tex2D(IonArg_MetalMask, fragData.UV).r);
    // 金属 tint（金/银/铜来自 baseColor / Color1）
    float3 metalTint = baseColor;
    float3 F0 = metalTint;
    // 金属 F0 ≈ 自身颜色
    // 1. 弱漫反射 + 环境底色
    float3 metalDiffuse = metalTint * ambient * IonArg_MetalDiffuseScale;
    metalDiffuse += metalTint * mainLightColor * rampGray * IonArg_MetalDiffuseScale;
    // 2. 方向高光（Blinn-Phong）
    float3 H = normalize(lightDirection + dirPosToCamWs);
    float NdotH = saturate(dot(normalWs, H));
    float specPower = lerp(256.0, 16.0, IonArg_MetalRoughness);
    float spec = pow(NdotH, specPower) * rampGray * light.ShadowAttenuation;
    float3 specular = F0 * spec * mainLightColor * IonArg_MetalSpecularIntensity;
    // 3. 环境反射：MatCap 保底 + SpecCube 增色
    float3 R = reflect(-dirPosToCamWs, normalWs);
    // BRP 反射探针（可选）
    // 粗糙度
    float mip = IonArg_MetalRoughness * 6.0;
    float4 envRaw = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, R, mip);
    float3 probeReflect = DecodeHDR(envRaw, unity_SpecCube0_HDR);
    // 探针混合
    float3 envReflect = lerp(matcapReflect, probeReflect, IonArg_MetalProbeInfluence);
    // 菲涅耳增强边缘反射
    float fresnelMetal = IonLight_Fresnel(envReflect, dirPosToCamWs, IonArg_RimPower);
    envReflect *= lerp(1.0, 1.5, fresnelMetal);
    float3 metalReflect = envReflect * F0 * IonArg_MetalReflectIntensity;
    // 4. 金属合成
    half3 metalColor = metalDiffuse + specular + metalReflect;
    // 可选：金属上保留弱 Rim
    metalColor += rimLight * metalMask * 0.5;

    //透镜，水波

    //===[最终混合]=================================================
    half3 dielectric = baseColor * dynamicShading;
    half3 finalColor = lerp(dielectric, metalColor, metalMask);
    
    float a1 = saturate(dot(effectMapRgb, float3(0.299, 0.587, 0.114)));
    // 亮度当透明度
    a1 = pow(a1, 0.005);
    // 可选：调曲线，让淡雾更明显/更透
    //a1 *= baseAlpha2;  // 可选：总强度


    //float3 rgb = lerp(bg, effectMapRgb, a1);
    //return half4(effectMapRgb, a1);

    finalColor = dielectric;
    return half4(finalColor, finalAlpha);

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