/****************************************
*
* 作者： 闪电黑客
* 日期： 2026/1/19
*
* 描述： IonPassMainAdd - BRP 附加光源 Pass
*        用于 ForwardAdd，处理点光源和聚光灯
*        每个附加光源执行一次此 Pass
*
* 使用说明：
* - 必须配合 IonPassMainSimple（ForwardBase）使用
* - Pass 设置：Blend One One, ZWrite Off
* - 不包含环境光，只有直接光照
*
****************************************/

#if Def(IonPassMainAdd)
#define Def_IonPassMainAdd


//===[必要参数声明]====================================================
sampler2D IonArg_MainTex;
float4    IonArg_MainTex_ST;

sampler2D IonArg_ColorMask;
float4    IonArg_Color1;
float4    IonArg_Color2;
float4    IonArg_Color3;
float4    IonArg_Color4;

sampler2D IonArg_EmissiveTex;
float     IonArg_EmissiveIntensity;

float     IonArg_LambertScale;
float     IonArg_LambertOffset;

// Ramp 动态光照（灰度，只控制阴影边界）
float     IonArg_LightRampThreshold;
float     IonArg_LightRampSoftness;

// BaseRamp 光照（固定方向结构性阴影）
float     IonArg_BaseRampEnable;    // BaseRamp 混合权重（0=不启用，1=完全启用）
float3    IonArg_BaseRampDir;          // 固定参考方向（世界空间，默认 (0,1,0) 向上）

float4    IonArg_BaseRampColor1;
float4    IonArg_BaseRampColor2;
float4    IonArg_BaseRampColor3;
float4    IonArg_BaseRampColor4;
float4    IonArg_BaseRampColor5;

float     IonArg_BaseRampThreshold1;
float     IonArg_BaseRampThreshold2;
float     IonArg_BaseRampThreshold3;
float     IonArg_BaseRampThreshold4;

float     IonArg_BaseRampSoftness1;
float     IonArg_BaseRampSoftness2;
float     IonArg_BaseRampSoftness3;
float     IonArg_BaseRampSoftness4;

// 背光边缘光（逆光轮廓光，跟随附加光源方向）
float4    IonArg_BackRimColor;
float     IonArg_BackRimPower;
float     IonArg_BackRimIntensity;

// ForwardAdd 关键字（生成 multi_compile_fwdadd_fullshadows）
#define IonKey_ForwardAdd

// 实例化支持
#define IonKey_Instancing

// 雾效支持
#define IonKey_Fog

#define Link_IonBase
#define Link_IonLight
#define Link_IonMatrix
#define Link_IonMath
#define Link_IonVertex
#include "../../Core/IonCore.hlsl"


#pragma vertex vert
#pragma fragment frag

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
    IonVar_T1(float3, NormalWs)
    IonVar_T2(float3, PositionWs)
    // 光照坐标（用于距离衰减计算）
    // 点光源和聚光灯需要此坐标来计算距离衰减
    // 根据光源类型可能是 float3 或 float4，这里统一声明 float4
    IonVar_T3(float4, LightCoord)
    // 阴影坐标（用于阴影采样）
    // 根据阴影类型可能使用 float3 或 float4，这里统一声明 float4
    IonVar_T4(float4, ShadowCoord)
};

FragData vert(VertData vertData)
{
    FragData fragData;
    
    // 计算 UV 坐标
    fragData.UV = IonMath_Transform2D(vertData.UV.xy, IonArg_MainTex_ST.xy, IonArg_MainTex_ST.zw);
    
    // 计算裁剪空间位置
    fragData.PositionCs = IonMatrix_PosOsToCs(vertData.PositionOs);
    
    // 将法线转换到世界空间
    fragData.NormalWs = IonMatrix_NrmOsToWs(vertData.Normal);
    
    // 计算世界空间位置
    fragData.PositionWs = IonMatrix_PosOsToWs(vertData.PositionOs);
    
    // 计算光照坐标（用于距离衰减）
    // 对应 Unity 的 COMPUTE_LIGHT_COORDS 宏
    fragData.LightCoord = IonLight_LightCoord(vertData.PositionOs);
    
    // 计算阴影坐标（用于阴影采样）
    // 对应 Unity 的 TRANSFER_SHADOW 宏
    fragData.ShadowCoord = IonLight_ShadowCoord(vertData.PositionOs, fragData.PositionCs, fragData.PositionWs);
    
    return fragData;
}

half4 frag(FragData fragData) : SV_Target
{
    half4 mainTex = tex2D(IonArg_MainTex, fragData.UV);

    //===[4 色混合]（与 ForwardBase 保持一致）======================
    half4  colorMask   = tex2D(IonArg_ColorMask, fragData.UV);
    float  maskedSum   = colorMask.r + colorMask.g + colorMask.b + colorMask.a;
    float  unmasked    = saturate(1.0 - maskedSum);
    half3  tintedColor = colorMask.r * IonArg_Color1.rgb
                       + colorMask.g * IonArg_Color2.rgb
                       + colorMask.b * IonArg_Color3.rgb
                       + colorMask.a * IonArg_Color4.rgb;
    half3  baseColor   = (tintedColor + mainTex.rgb * unmasked) * mainTex.r;

    //===[附加光源 Ramp 光照]========================================
    float3 normalWs = normalize(fragData.NormalWs);
    float  atten    = IonLight_Attenuation(fragData.LightCoord, fragData.ShadowCoord);
    float3 lightDir = IonLight_Direction(fragData.PositionWs);

    // BaseRamp：固定方向结构性阴影（受附加光源衰减调制，不自发光）
    float NdotBase = saturate(dot(normalWs, normalize(IonArg_BaseRampDir)));
    float3 baseRampColor = IonLight_Ramp(
        NdotBase,
        IonArg_BaseRampColor1.rgb, IonArg_BaseRampThreshold1, IonArg_BaseRampSoftness1,
        IonArg_BaseRampColor2.rgb, IonArg_BaseRampThreshold2, IonArg_BaseRampSoftness2,
        IonArg_BaseRampColor3.rgb, IonArg_BaseRampThreshold3, IonArg_BaseRampSoftness3,
        IonArg_BaseRampColor4.rgb, IonArg_BaseRampThreshold4, IonArg_BaseRampSoftness4,
        IonArg_BaseRampColor5.rgb
    );
    float3 baseShading = baseRampColor * IonArg_BaseRampEnable * atten;

    float NdotL     = saturate(dot(normalWs, lightDir) * IonArg_LambertScale + IonArg_LambertOffset);
    float rampGray  = IonLight_RampGray(NdotL, IonArg_LightRampThreshold, IonArg_LightRampSoftness);
    half3 lightContrib = baseShading + rampGray * IonParam_LightColor * atten;

    //===[背光边缘光]===============================================
    float3 viewDir     = normalize(IonParam_CameraPosWs - fragData.PositionWs);
    float  backRim     = IonLight_BackRim(normalWs, viewDir, lightDir, IonArg_BackRimPower);
    half3  backRimLight = backRim * IonArg_BackRimColor.rgb * IonArg_BackRimIntensity
                        * IonParam_LightColor.rgb * atten;

    //===[自发光区域屏蔽]============================================
    // 自发光权重越高的区域越不受附加光影响，与 ForwardBase 行为一致
    float emissiveMask   = tex2D(IonArg_EmissiveTex, fragData.UV).r;
    float emissiveWeight = saturate(emissiveMask * IonArg_EmissiveIntensity);

    // ForwardAdd 只输出直接光照，Alpha 为 0（Blend One One 叠加模式）
    return half4((baseColor * lightContrib + backRimLight) * (1.0 - emissiveWeight), 0);
}

#endif // Def(IonPassMainAdd)
