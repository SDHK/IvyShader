/****************************************
*
* 描述： URP 顶点 / 插值器语义字段
*        GPU 绑定，不进 Core
*
****************************************/

#if DefPart(IvyStruct, Library)
#define Def_IvyStruct_Library

#define IvyVar_PosOs float4 PosOs : POSITION;
#define IvyVar_Rgba half4 Rgba : COLOR;
#define IvyVar_NrmOs float3 NrmOs : NORMAL;
#define IvyVar_TanOs float4 TanOs : TANGENT;
#define IvyVar_PosCs float4 PosCs : SV_POSITION;
#define IvyVar_VertId uint VertId : SV_VertexID;
#define IvyVar_InstId uint InstId : SV_InstanceID;

#define IvyVar_ViewFace float ViewFace : VFACE;
#define IvyVar_IsFront bool IsFront : SV_IsFrontFace;

#define IvyVar_TargetRgba half4 TargetRgba : SV_Target;

#define IvyVar_T0(type,name) type name : TEXCOORD0;
#define IvyVar_T1(type,name) type name : TEXCOORD1;
#define IvyVar_T2(type,name) type name : TEXCOORD2;
#define IvyVar_T3(type,name) type name : TEXCOORD3;
#define IvyVar_T4(type,name) type name : TEXCOORD4;
#define IvyVar_T5(type,name) type name : TEXCOORD5;
#define IvyVar_T6(type,name) type name : TEXCOORD6;
#define IvyVar_T7(type,name) type name : TEXCOORD7;

#endif
