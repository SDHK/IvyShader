/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/10 14:18
*
* 描述： BRP 顶点 / 插值器语义字段
*        GPU 绑定，不进 Core
*
*/

#if DefPart(IvyStruct, Library)
#define Def_IvyStruct_Library

//===[数据结构字段映射]===
// 顶点位置
#define IvyVar_PosOs float4 PosOs : POSITION;
// 顶点颜色
#define IvyVar_Rgba half4 Rgba : COLOR;
// 顶点法线
#define IvyVar_NrmOs float3 NrmOs : NORMAL;
// 顶点切线
#define IvyVar_TanOs float4 TanOs : TANGENT;
// 顶点在屏幕空间位置
#define IvyVar_PosCs float4 PosCs : SV_POSITION;
// 顶点ID
#define IvyVar_VertId uint VertId : SV_VertexID;
// 实例ID
#define IvyVar_InstId uint InstId : SV_InstanceID;

// 三角面朝向（相对相机）：+1 正面，-1 背面
#define IvyVar_ViewFace float ViewFace : VFACE;
// 是否正面;与VFACE冲突，DX10+ / 较新的 HLSL 风格
#define IvyVar_IsFront bool IsFront : SV_IsFrontFace;

// 片元输出颜色
#define IvyVar_TargetRgba half4 TargetRgba : SV_Target;

// ===[传值通道字段映射]===
#define IvyVar_T0(type,name) type name : TEXCOORD0;
#define IvyVar_T1(type,name) type name : TEXCOORD1;
#define IvyVar_T2(type,name) type name : TEXCOORD2;
#define IvyVar_T3(type,name) type name : TEXCOORD3;
#define IvyVar_T4(type,name) type name : TEXCOORD4;
#define IvyVar_T5(type,name) type name : TEXCOORD5;
#define IvyVar_T6(type,name) type name : TEXCOORD6;
#define IvyVar_T7(type,name) type name : TEXCOORD7;

#endif
