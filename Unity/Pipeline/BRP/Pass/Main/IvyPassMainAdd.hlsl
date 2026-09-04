/****************************************
*
* 作者： 闪电黑客
* 日期： 2026/1/19
*
* 描述： IvyPassMainAdd - BRP 附加光源 Pass
*        用于 ForwardAdd，处理点光源和聚光灯
*        每个附加光源执行一次此 Pass
*
* 使用说明：
* - 必须配合 IvyPassMainSimple（ForwardBase）使用
* - Pass 设置：Blend One One, ZWrite Off
* - 不包含环境光，只有直接光照
*
****************************************/

#if Def(IvyPassMainAdd)
#define Def_IvyPassMainAdd


//===[必要参数声明]====================================================
sampler2D IvyArg_MainTex;
float4    IvyArg_MainTex_ST;

sampler2D IvyArg_ColorMask;
float4    IvyArg_Color1;
float4    IvyArg_Color2;
float4    IvyArg_Color3;
float4    IvyArg_Color4;

sampler2D IvyArg_EmissiveTex;
float     IvyArg_EmissiveIntensity;

float     IvyArg_LambertScale;
float     IvyArg_LambertOffset;

// Ramp 动态光照（灰度，只控制阴影边界）
float     IvyArg_LightRampThreshold;
float     IvyArg_LightRampSoftness;

// BaseRamp 光照（固定方向结构性阴影）
float     IvyArg_BaseRampEnable;    // BaseRamp 混合权重（0=不启用，1=完全启用）
float3    IvyArg_BaseRampDir;          // 固定参考方向（世界空间，默认 (0,1,0) 向上）

float4    IvyArg_BaseRampColor1;
float4    IvyArg_BaseRampColor2;
float4    IvyArg_BaseRampColor3;
float4    IvyArg_BaseRampColor4;
float4    IvyArg_BaseRampColor5;

float     IvyArg_BaseRampThreshold1;
float     IvyArg_BaseRampThreshold2;
float     IvyArg_BaseRampThreshold3;
float     IvyArg_BaseRampThreshold4;

float     IvyArg_BaseRampSoftness1;
float     IvyArg_BaseRampSoftness2;
float     IvyArg_BaseRampSoftness3;
float     IvyArg_BaseRampSoftness4;

// 背光边缘光（逆光轮廓光，跟随附加光源方向）
float4    IvyArg_BackRimColor;
float     IvyArg_BackRimPower;
float     IvyArg_BackRimIntensity;

// ForwardAdd 关键字（生成 multi_compile_fwdadd_fullshadows）
#define IvyKey_ForwardAdd

// 实例化支持
#define IvyKey_Instancing

// 雾效支持
#define IvyKey_Fog

#define Link_IvyBase
#define Link_IvyLight
#define Link_IvyMatrix
#define Link_IvyMath
#define Link_IvyRamp
#define Link_IvyVertex
#define Link_IvyUv
#include "../../Core/IvyCore.hlsl"


#pragma vertex vert
#pragma fragment frag

struct VertData
{
    IvyVar_PosOs
    IvyVar_NrmOs
    IvyVar_T0(float2, UV)
};

struct FragData
{
    IvyVar_PosCs
    IvyVar_T0(float2, UV)
    IvyVar_T1(float3, NormalWs)
    IvyVar_T2(float3, PositionWs)
    // 光照坐标（用于距离衰减计算）
    // 点光源和聚光灯需要此坐标来计算距离衰减
    // 根据光源类型可能是 float3 或 float4，这里统一声明 float4
    IvyVar_T3(float4, LightCoord)
    // 阴影坐标（用于阴影采样）
    // 根据阴影类型可能使用 float3 或 float4，这里统一声明 float4
    IvyVar_T4(float4, ShadowCoord)
};

FragData vert(VertData vertData)
{
    FragData fragData;
    
    // 计算 UV 坐标
    fragData.UV = IvyUv_Transform2D(vertData.UV.xy, IvyArg_MainTex_ST.xy, IvyArg_MainTex_ST.zw);
    
    // 计算裁剪空间位置
    fragData.PosCs = IvyMatrix_PosOsToCs(vertData.PosOs);
    
    // 将法线转换到世界空间
    fragData.NormalWs = IvyMatrix_NrmOsToWs(vertData.NrmOs);
    
    // 计算世界空间位置
    fragData.PositionWs = IvyMatrix_PosOsToWs(vertData.PosOs);
    
    // 计算光照坐标（用于距离衰减）
    // 对应 Unity 的 COMPUTE_LIGHT_COORDS 宏
    fragData.LightCoord = IvyLight_LightCoord(vertData.PosOs);
    
    // 计算阴影坐标（用于阴影采样）
    // 对应 Unity 的 TRANSFER_SHADOW 宏
    fragData.ShadowCoord = IvyLight_ShadowCoord(vertData.PosOs, fragData.PosCs, fragData.PositionWs);
    
    return fragData;
}

half4 frag(FragData fragData) : SV_Target
{
    half4 mainTex = tex2D(IvyArg_MainTex, fragData.UV);

    //===[4 色混合]（与 ForwardBase 保持一致）======================
    half4  colorMask   = tex2D(IvyArg_ColorMask, fragData.UV);
    float  maskedSum   = colorMask.r + colorMask.g + colorMask.b + colorMask.a;
    float  unmasked    = saturate(1.0 - maskedSum);
    half3  tintedColor = colorMask.r * IvyArg_Color1.rgb
                       + colorMask.g * IvyArg_Color2.rgb
                       + colorMask.b * IvyArg_Color3.rgb
                       + colorMask.a * IvyArg_Color4.rgb;
    half3  baseColor   = (tintedColor + mainTex.rgb * unmasked) * mainTex.r;

    //===[附加光源 Ramp 光照]========================================
    float3 normalWs = normalize(fragData.NormalWs);
    float  atten    = IvyLight_Attenuation(fragData.LightCoord, fragData.ShadowCoord);
    float3 lightDir = IvyLight_Direction(fragData.PositionWs);

    // BaseRamp：固定方向结构性阴影（受附加光源衰减调制，不自发光）
    float NdotBase = saturate(dot(normalWs, normalize(IvyArg_BaseRampDir)));
    float3 baseRampColor = IvyRamp_Rgb5(
        NdotBase,
        IvyArg_BaseRampColor1.rgb, IvyArg_BaseRampThreshold1, IvyArg_BaseRampSoftness1,
        IvyArg_BaseRampColor2.rgb, IvyArg_BaseRampThreshold2, IvyArg_BaseRampSoftness2,
        IvyArg_BaseRampColor3.rgb, IvyArg_BaseRampThreshold3, IvyArg_BaseRampSoftness3,
        IvyArg_BaseRampColor4.rgb, IvyArg_BaseRampThreshold4, IvyArg_BaseRampSoftness4,
        IvyArg_BaseRampColor5.rgb
    );
    float3 baseShading = baseRampColor * IvyArg_BaseRampEnable * atten;


    float NdotL     = saturate(dot(normalWs, lightDir) * IvyArg_LambertScale + IvyArg_LambertOffset);
    float rampGray  = IvyRamp_Gray(NdotL, IvyArg_LightRampThreshold, IvyArg_LightRampSoftness);
    half3 lightContrib = baseShading + rampGray * IvyParam_LightColor * atten;

    //===[背光边缘光]===============================================
    float3 viewDir     = normalize(IvyParam_CameraPosWs - fragData.PositionWs);
    float  backRim     = IvyRamp_BackRim(normalWs, viewDir, lightDir, IvyArg_BackRimPower);
    half3  backRimLight = backRim * IvyArg_BackRimColor.rgb * IvyArg_BackRimIntensity
                        * IvyParam_LightColor.rgb * atten;

    //===[自发光区域屏蔽]============================================
    // 自发光权重越高的区域越不受附加光影响，与 ForwardBase 行为一致
    float emissiveMask   = tex2D(IvyArg_EmissiveTex, fragData.UV).r;
    float emissiveWeight = saturate(emissiveMask * IvyArg_EmissiveIntensity);

    // ForwardAdd 只输出直接光照，Alpha 为 0（Blend One One 叠加模式）
    return half4((baseColor * lightContrib + backRimLight) * (1.0 - emissiveWeight), 0);
}


#endif // Def(IvyPassMainAdd)
