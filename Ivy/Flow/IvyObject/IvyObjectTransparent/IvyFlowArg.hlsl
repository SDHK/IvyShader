/****************************************
*
* 描述： IvyObjectTransparentTess 材质参数
*        Main / Add / Outline / Shadow 声明并集
*        与 .shader Properties 同名 IvyFlowArg_*
*
****************************************/

#ifndef Def_IvyFlowArg
#define Def_IvyFlowArg

//===[抽象方法]==================================================

//获取摄像机世界坐标
float3 IvyFunc_GetCamWs();

//获取摄像机正交投影状态
bool IvyFunc_IsCamOrtho();

// 计算并返回阴影坐标（片元中调用，避免顶点插值）
// 参数：positionOS - 物体空间位置
// 参数：positionCS - 裁剪空间位置（屏幕空间阴影用）
// 参数：positionWS - 世界空间位置
float4 IvyFunc_ShadowCoord(float4 posOs, float4 posCs, float3 posWs);

//获取主光照
IvyStruct_Light IvyFunc_GetMainLight(float4 shadowCoord);


//贴图
half4 IvyFunc_SkinMask0(half2 uv);
half4 IvyFunc_SkinMask1(half2 uv);
half4 IvyFunc_SkinMask2(half2 uv);
half4 IvyFunc_SkinMask3(half2 uv);
half4 IvyFunc_FilmMaskTex(half2 uv);

//环境反射
half3 IvyFunc_GetProbeReflect(float3 dirWs, half mip);
//反射贴图 
half4 IvyFunc_EnvMapTex(half2 uv,half mipMap);
half4 IvyFunc_MatCapTex(half2 uv,half mipMap);


/// <summary>
/// 获取光照颜色（漫反射） 可写成全局
/// </summary>
half3 IvyFunc_LightSH(float3 nrmWs);

/// <summary>
/// 获取时间 可写成全局？
/// </summary>
float IvyFunc_GetTime();


//===[虚方法]==================================================
/// <summary>
/// 获取附加光数量 
/// </summary>
uint IvyOverFunc_GetLightCount();
#ifndef IvyFunc_GetLightCount
#define IvyFunc_GetLightCount() 0
#endif

/// <summary>
/// 附加光（URP 的附加点光）
/// </summary>
/// <param name="lightIn"> 光照输入参数 </param>
/// <param name="index"> 光照索引 </param>
/// <param name="posWs"> 对象世界坐标 </param>
/// <returns> 漫反射光照阶段参数 </returns>
IvyLight_DiffuseIn IvyOverFunc_GetAddLight(IvyLight_DiffuseIn lightIn, uint index, float3 posWs);
#ifndef IvyFunc_GetAddLight
#define IvyFunc_GetAddLight(lightIn, index, posWs) (IvyLight_DiffuseIn)0
// 参考实现：
//IvyLight_DiffuseIn addIn = lightIn;
//addIn.Rgb = addLightUrp.color;
//addIn.Dir = addLightUrp.direction;
//addIn.DistAtten = addLightUrp.distanceAttenuation;
//addIn.ShadowAtten = addLightUrp.shadowAttenuation;
#endif

/// <summary>
/// 音频频段幅度 
/// </summary>
half IvyOverFunc_AudioLinkBand(uint band);
#ifndef IvyFunc_AudioLinkBand 
#define IvyFunc_AudioLinkBand(band) 0
#endif



//===[面板参数]==================================================
float4 IvyArg_SkinMask0_ST;
float4 IvyArg_SkinMask1_ST;
float4 IvyArg_SkinMask2_ST;
float4 IvyArg_SkinMask3_ST;

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

float IvyArg_EmissiveIntensity;
float IvyArg_AudioPulse;
int IvyArg_AudioBand;

// SkinRamp 光照（固定参考方向，提供不随光源变化的结构性阴影）
float IvyArg_SkinRampToggle;
float4 IvyArg_SkinObjRampPos;

float4 IvyArg_RampRgbBase;
float4 IvyArg_SkinObjRampRgb0;
float4 IvyArg_SkinObjRampRgb1;

float IvyArg_SkinObjRampThreshold0;
float IvyArg_SkinObjRampThreshold1;
float IvyArg_SkinObjRampSoftness;

float IvyArg_SkinViewRampThreshold0;
float IvyArg_SkinViewRampThreshold1;
float IvyArg_SkinViewRampSoftness;

float IvyArg_LightRampThreshold;
float IvyArg_LightRampSoftness;

float4 IvyArg_SkinViewRampRgb0;
float4 IvyArg_SkinViewRampRgb1;

float IvyArg_RimIntensity;
float IvyArg_LightRimSoftness;

float IvyArg_BackRimIntensity;
float IvyArg_BackLightRimSoftness;

float IvyArg_ReflectIntensity00;
float IvyArg_ReflectIntensity01;
float IvyArg_ReflectIntensity10;
float IvyArg_ReflectIntensity11;
float IvyArg_ReflectIntensity20;
float IvyArg_ReflectIntensity21;
float IvyArg_ReflectIntensity30;
float IvyArg_ReflectIntensity31;
float IvyArg_ReflectSmoothness00;
float IvyArg_ReflectSmoothness01;
float IvyArg_ReflectSmoothness10;
float IvyArg_ReflectSmoothness11;
float IvyArg_ReflectSmoothness20;
float IvyArg_ReflectSmoothness21;
float IvyArg_ReflectSmoothness30;
float IvyArg_ReflectSmoothness31;

float IvyArg_Transmit00;
float IvyArg_Transmit01;
float IvyArg_Transmit10;
float IvyArg_Transmit11;
float IvyArg_Transmit20;
float IvyArg_Transmit21;
float IvyArg_Transmit30;
float IvyArg_Transmit31;

float IvyArg_Glitter00;
float IvyArg_Glitter01;
float IvyArg_Glitter10;
float IvyArg_Glitter11;
float IvyArg_Glitter20;
float IvyArg_Glitter21;
float IvyArg_Glitter30;
float IvyArg_Glitter31;

float IvyArg_Film00;
float IvyArg_Film01;
float IvyArg_Film10;
float IvyArg_Film11;
float IvyArg_Film20;
float IvyArg_Film21;
float IvyArg_Film30;
float IvyArg_Film31;
float IvyArg_IridescenceHue;
float IvyArg_IridescenceSpread;
float IvyArg_IridescenceBands;


float IvyArg_EnvMapInfluence;

float IvyArg_MatCapInfluence;

int IvyArg_EffectMap;
int IvyArg_Effect2DMap;
float IvyArg_EffectIntensity00;
float IvyArg_EffectIntensity01;
float IvyArg_EffectIntensity10;
float IvyArg_EffectIntensity11;
float IvyArg_EffectIntensity20;
float IvyArg_EffectIntensity21;
float IvyArg_EffectIntensity30;
float IvyArg_EffectIntensity31;
float IvyArg_EffectInside;
int IvyArg_VecMap0;

float IvyArg_Cutoff;
float4 IvyArg_Color;
float IvyArg_Scale;
float IvyArg_PressDepth;
float4 IvyArg_PressPos;
float IvyArg_PressRadius;
float IvyArg_TessFactor;

#endif
