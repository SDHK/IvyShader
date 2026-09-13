/****************************************
*
* 作者： 闪电黑客
* 日期： 2026/9/13
*
* 说明： URP 环境履约 · 基础（矩阵 / 相机 / 时间）
*
*/

#if Def(IvyEnvBase)
#define Def_IvyEnvBase

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

#if defined(SHADER_API_D3D11) || defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE) || defined(SHADER_API_VULKAN) || defined(SHADER_API_METAL) || defined(SHADER_API_PSSL)
#ifndef UNITY_CAN_COMPILE_TESSELLATION
#define UNITY_CAN_COMPILE_TESSELLATION 1
#endif
#endif

//===[矩阵接口]===

//float4x4 模型矩阵
#define IvyEnvBase_Matrix_M UNITY_MATRIX_M
//float4x4 视图矩阵
#define IvyEnvBase_Matrix_V UNITY_MATRIX_V
//float4x4 投影矩阵
#define IvyEnvBase_Matrix_P UNITY_MATRIX_P

//float4x4 模型矩阵的逆矩阵
#define IvyEnvBase_Matrix_I_M UNITY_MATRIX_I_M
//float4x4 视图矩阵的逆矩阵
#define IvyEnvBase_Matrix_I_V UNITY_MATRIX_I_V
//float4x4 投影矩阵的逆矩阵
#define IvyEnvBase_Matrix_I_P UNITY_MATRIX_I_P

//float4x4 模型视图矩阵
#define IvyEnvBase_Matrix_MV UNITY_MATRIX_MV
//float4x4 视图投影矩阵
#define IvyEnvBase_Matrix_VP UNITY_MATRIX_VP
//float4x4 模型视图投影矩阵
#define IvyEnvBase_Matrix_MVP UNITY_MATRIX_MVP

//float4x4 模型视图矩阵的逆矩阵
#define IvyEnvBase_Matrix_I_MV  mul(IvyEnvBase_Matrix_I_M, IvyEnvBase_Matrix_I_V)
//float4x4 视图投影矩阵的逆矩阵
#define IvyEnvBase_Matrix_I_VP UNITY_MATRIX_I_VP
//float4x4 模型视图投影矩阵的逆矩阵
#define IvyEnvBase_Matrix_I_MVP mul(IvyEnvBase_Matrix_I_M, IvyEnvBase_Matrix_I_VP)

//===[方法接口]===

/// <summary>
/// 获取摄像机世界坐标
/// </summary>
float3 IvyEnvBase_GetCamWs()
{
    return _WorldSpaceCameraPos;
}

/// <summary>
/// 获取摄像机正交投影状态
/// </summary>
bool IvyEnvBase_IsCamOrtho()
{
    return unity_OrthoParams.w > 0.5;
}

/// <summary>
/// 获取时间
/// </summary>
float IvyEnvBase_GetTime()
{
    return _Time.x;
}

#endif // Def_IvyEnvBase
