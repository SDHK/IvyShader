/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/4 20:33
*
* 说明： Unity 引擎BRP的 Ivy 环境参数映射实现
* 
*/

#if DefPart(IvyBase, Param)
#define Def_IvyBase_Param

// 改名叫做IvyEnv 实现参数和全局接口方法

//===[矩阵接口实现]===

//float4x4 模型矩阵
#define IvyParam_Matrix_M unity_ObjectToWorld
//float4x4 视图矩阵
#define IvyParam_Matrix_V UNITY_MATRIX_V
//float4x4 投影矩阵
#define IvyParam_Matrix_P  UNITY_MATRIX_P

//float4x4 模型矩阵的逆矩阵
#define IvyParam_Matrix_I_M unity_WorldToObject
//float4x4 视图矩阵的逆矩阵
#define IvyParam_Matrix_I_V UNITY_MATRIX_I_V
//float4x4 投影矩阵的逆矩阵, Unity没提供，所以可能是错的。
#define IvyParam_Matrix_I_P unity_CameraInvProjection

//float4x4 模型视图矩阵
#define IvyParam_Matrix_MV UNITY_MATRIX_MV
//float4x4 视图投影矩阵
#define IvyParam_Matrix_VP UNITY_MATRIX_VP
//float4x4 模型视图投影矩阵
#define IvyParam_Matrix_MVP UNITY_MATRIX_MVP

//float4x4 模型视图矩阵的逆矩阵
#define IvyParam_Matrix_I_MV  mul(IvyParam_Matrix_I_M, IvyParam_Matrix_I_V)
//float4x4 视图投影矩阵的逆矩阵
#define IvyParam_Matrix_I_VP  mul(IvyParam_Matrix_I_V, IvyParam_Matrix_I_P)
//float4x4 模型视图投影矩阵的逆矩阵
#define IvyParam_Matrix_I_MVP mul(IvyParam_Matrix_I_M, IvyParam_Matrix_I_VP)

//===[类型接口]===
#define IvyTexType sampler2D
#define IvyTex(name) IvyTexType name

//===[方法接口]===
#define IvyTex2D(tex, uv) tex2D(tex, uv)
#define IvyTex2DLod(tex, uv, lod) tex2Dlod(tex, float4((uv).xy, 0, (lod)))

#endif // DefPart(IvyBase, Param)
