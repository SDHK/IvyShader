/****************************************
*
* 作者： 闪电黑客
* 日期： 2026/9/13
*
* 说明： Ivy 环境合同 · 基础（矩阵 / 相机 / 时间）
*
* 设计理念：
* - 本文件是合同：Flow / Stage / Pass 只认这里的 IvyEnvBase_ 名字
* - 管线目录写履约；编辑器单独打开时走这份假实现
*
*/

#if Def(IvyEnvBase)
#define Def_IvyEnvBase

//===[矩阵接口]===

//float4x4 模型矩阵
#define IvyEnvBase_Matrix_M IvyConst_Float4x4_Identity
//float4x4 视图矩阵
#define IvyEnvBase_Matrix_V IvyConst_Float4x4_Identity
//float4x4 投影矩阵
#define IvyEnvBase_Matrix_P IvyConst_Float4x4_Identity

//float4x4 模型矩阵的逆矩阵
#define IvyEnvBase_Matrix_I_M IvyConst_Float4x4_Identity
//float4x4 视图矩阵的逆矩阵
#define IvyEnvBase_Matrix_I_V IvyConst_Float4x4_Identity
//float4x4 投影矩阵的逆矩阵
#define IvyEnvBase_Matrix_I_P IvyConst_Float4x4_Identity

//float4x4 模型视图矩阵
#define IvyEnvBase_Matrix_MV   mul(IvyEnvBase_Matrix_V, IvyEnvBase_Matrix_M)
//float4x4 视图投影矩阵
#define IvyEnvBase_Matrix_VP   mul(IvyEnvBase_Matrix_P, IvyEnvBase_Matrix_V)
//float4x4 模型视图投影矩阵
#define IvyEnvBase_Matrix_MVP  mul(IvyEnvBase_Matrix_VP, IvyEnvBase_Matrix_M)

//float4x4 模型视图矩阵的逆矩阵
#define IvyEnvBase_Matrix_I_MV  mul(IvyEnvBase_Matrix_I_M, IvyEnvBase_Matrix_I_V)
//float4x4 视图投影矩阵的逆矩阵
#define IvyEnvBase_Matrix_I_VP  mul(IvyEnvBase_Matrix_I_V, IvyEnvBase_Matrix_I_P)
//float4x4 模型视图投影矩阵的逆矩阵
#define IvyEnvBase_Matrix_I_MVP mul(IvyEnvBase_Matrix_I_M, IvyEnvBase_Matrix_I_VP)

//===[方法接口]===

/// <summary>
/// 获取摄像机世界坐标
/// </summary>
float3 IvyEnvBase_GetCamWs()
{
    return 0;
}

/// <summary>
/// 获取摄像机正交投影状态
/// </summary>
bool IvyEnvBase_IsCamOrtho()
{
    return false;
}

/// <summary>
/// 获取时间
/// </summary>
float IvyEnvBase_GetTime()
{
    return 0;
}

#endif // Def_IvyEnvBase
