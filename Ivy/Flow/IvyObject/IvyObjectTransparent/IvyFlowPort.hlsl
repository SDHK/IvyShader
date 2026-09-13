/****************************************

* 作者： 闪电黑客
* 日期： 2026/9/13

* 描述： IvyObjectTransparent Flow 端口声明

*/

#ifndef Def_IvyFlowPort
#define Def_IvyFlowPort

//===[抽象方法]==================================================
// 计算并返回阴影坐标
float4 IvyFunc_ShadowCoord(IvyGeom_BuildOut geomOut);

//贴图
half4 IvyFunc_SkinMask0(half2 uv);
half4 IvyFunc_SkinMask1(half2 uv);
half4 IvyFunc_SkinMask2(half2 uv);
half4 IvyFunc_SkinMask3(half2 uv);
half4 IvyFunc_FilmMaskTex(half2 uv);

//反射贴图 
half4 IvyFunc_EnvMapTex(half2 uv,half mipMap);
half4 IvyFunc_MatCapTex(half2 uv,half mipMap);

//===[虚方法]==================================================

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
