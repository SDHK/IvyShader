/****************************************
*
* 作者： 闪电黑客
* 日期： 2026/6/14
*
* 描述： IonPassDepthPre - 深度预写 Pass
*        在颜色渲染前将前面深度写入深度缓冲区。
*        结合 Alpha Cutoff，实现：
*          alpha >= Cutoff → 写深度（不透明区域阻挡内部面）
*          alpha <  Cutoff → 不写深度（透明区域可看到内部）
*
* 使用说明：
* - Pass 设置：ZWrite On, ColorMask 0, Cull Back
* - LightMode = Always（每帧每摄像机都执行，在 ForwardBase 前运行）
* - 必须放在 ForwardBase Pass 之前声明
*
****************************************/

#if Def(IonPassDepthPre)
#define Def_IonPassDepthPre

//===[必要参数声明]====================================================
sampler2D IonArg_MainTex;
float4    IonArg_MainTex_ST;
float     IonArg_Cutoff;

#pragma vertex vert
#pragma fragment frag

#define Link_IonBase
#define Link_IonMatrix
#define Link_IonMath
#include "../../Core/IonCore.hlsl"

struct VertData
{
    IonVar_PosOs
    IonVar_T0(float2, UV)
};

struct FragData
{
    IonVar_PosCs
    IonVar_T0(float2, UV)
};

FragData vert(VertData vertData)
{
    FragData fragData;
    fragData.PosCs = IonMatrix_PosOsToCs(vertData.PosOs);
    fragData.UV         = IonMath_Transform2D(vertData.UV, IonArg_MainTex_ST.xy, IonArg_MainTex_ST.zw);
    return fragData;
}

half4 frag(FragData fragData) : SV_Target
{
    // alpha >= Cutoff → 正值 → 写深度（阻挡内部面）
    // alpha <  Cutoff → 负值 → clip 丢弃，不写深度（透明穿透）
    clip(tex2D(IonArg_MainTex, fragData.UV).a - IonArg_Cutoff);
    return 0;
}

#endif // Def(IonPassDepthPre)
