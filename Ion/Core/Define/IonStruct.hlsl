/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/10 14:18
*
* 描述： 结构体定义
* 

*/

#ifndef Def_IonStruct
#define Def_IonStruct

//=== [光照阴影数据结构] ===


//光照阴影数据
struct IonStruct_Light
{
    // 光源方向
    half3   Direction;
    // 光源颜色
    half3   Color;
    // 光源衰减
    float   DistanceAttenuation; 
    // 阴影衰减
    half    ShadowAttenuation;
    // 阴影层级
    uint    LayerMask;
};

//===[数据结构字段映射]===
// 顶点位置
#define IonVar_PosOs float4 PosOs : POSITION;
// 顶点颜色
#define IonVar_Rgba float4 Rgba : COLOR;
// 顶点法线
#define IonVar_NrmOs float3 NrmOs : NORMAL;
// 顶点切线
#define IonVar_TanOs float4 TanOs : TANGENT;
// 顶点在屏幕空间位置
#define IonVar_PosCs float4 PosCs : SV_POSITION;
// 顶点ID
#define IonVar_VertId uint VertId : SV_VertexID;
// 实例ID
#define IonVar_InstId uint InstId : SV_InstanceID;

// 三角面朝向（相对相机）：+1 正面，-1 背面
#define IonVar_ViewFace float ViewFace : VFACE;
// 是否正面;与VFACE冲突，DX10+ / 较新的 HLSL 风格
#define IonVar_IsFront bool IsFront : SV_IsFrontFace;

// 片元输出颜色
#define IonVar_TargetRgba half4 TargetRgba : SV_Target;

// ===[传值通道字段映射]===
#define IonVar_T0(type,name) type name : TEXCOORD0;
#define IonVar_T1(type,name) type name : TEXCOORD1;
#define IonVar_T2(type,name) type name : TEXCOORD2;
#define IonVar_T3(type,name) type name : TEXCOORD3;
#define IonVar_T4(type,name) type name : TEXCOORD4;
#define IonVar_T5(type,name) type name : TEXCOORD5;
#define IonVar_T6(type,name) type name : TEXCOORD6;
#define IonVar_T7(type,name) type name : TEXCOORD7;

#endif
