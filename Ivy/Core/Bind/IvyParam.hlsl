/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/4 19:42
*
* 说明： Ivy Shader环境参数接口规范/模板
* 
* 设计理念：
* - 本文件定义了统一的参数接口规范
* - 不同引擎需要按照此规范实现对应的参数映射文件
* - 所有环境参数使用 IvyParam_ 前缀，保持命名空间统一
* 
* 实现要求：
* 1. 每个 #define 必须映射到对应引擎的内置变量
* 2. 变量类型必须匹配（float3/float4/float4x4等）
* 3. 参数语义需保持一致
*
*/

#if DefPart(IvyBase, Param)
#define Def_IvyBase_Param
   
//===[矩阵接口]===

//float4x4 模型矩阵
#define IvyParam_Matrix_M IvyConst_Float4x4_Identity
//float4x4 视图矩阵
#define IvyParam_Matrix_V IvyConst_Float4x4_Identity
//float4x4 投影矩阵
#define IvyParam_Matrix_P IvyConst_Float4x4_Identity

//float4x4 模型矩阵的逆矩阵
#define IvyParam_Matrix_I_M IvyConst_Float4x4_Identity
//float4x4 视图矩阵的逆矩阵
#define IvyParam_Matrix_I_V IvyConst_Float4x4_Identity
//float4x4 投影矩阵的逆矩阵
#define IvyParam_Matrix_I_P IvyConst_Float4x4_Identity

//float4x4 模型视图矩阵
#define IvyParam_Matrix_MV   mul(IvyParam_Matrix_V, IvyParam_Matrix_M)
//float4x4 视图投影矩阵
#define IvyParam_Matrix_VP   mul(IvyParam_Matrix_P, IvyParam_Matrix_V)
//float4x4 模型视图投影矩阵
#define IvyParam_Matrix_MVP  mul(IvyParam_Matrix_VP, IvyParam_Matrix_M)

//float4x4 模型视图矩阵的逆矩阵
#define IvyParam_Matrix_I_MV  mul(IvyParam_Matrix_I_M, IvyParam_Matrix_I_V)
//float4x4 视图投影矩阵的逆矩阵
#define IvyParam_Matrix_I_VP  mul(IvyParam_Matrix_I_V, IvyParam_Matrix_I_P)
//float4x4 模型视图投影矩阵的逆矩阵
#define IvyParam_Matrix_I_MVP mul(IvyParam_Matrix_I_M, IvyParam_Matrix_I_VP)

#endif // DefPart(IvyBase, Param)

