/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/16
*
* 描述： URP 核心库转接层
* 
* 功能：统一管理 URP 核心库的包含
*
*/

#if DefPart(IvyBase, Library)
#define Def_IvyBase_Library

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

#if defined(SHADER_API_D3D11) || defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE) || defined(SHADER_API_VULKAN) || defined(SHADER_API_METAL) || defined(SHADER_API_PSSL)
#ifndef UNITY_CAN_COMPILE_TESSELLATION
#define UNITY_CAN_COMPILE_TESSELLATION 1
#endif
#endif

#endif // DefPart(IvyBase, Library)


