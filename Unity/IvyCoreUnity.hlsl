/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/4 14:16
*
* 说明： Unity 引擎的 Ivy Shader 库统一入口
*
* 功能：初始化 Ivy Shader 库在 Unity 引擎下的运行环境
*
* 注入 Unity 引擎相关的 Ivy 参数映射
* 注入 Unity 引擎相关的 Shader 核心模块
*
* 加载 IvyPass 入口（IvyPass.hlsl）
* 加载 Ivy 库入口（IvyCore.hlsl）
*
*/

#ifndef Def_IvyCoreUnity
#define Def_IvyCoreUnity

//===[引入配置]===

#include "../IvyConfig.hlsl"

//===[引入引擎绑定]===
#if defined(IvyShader_BRP)
#include "Pipeline/BRP/IvyBindCore.hlsl"
#endif

#if defined(IvyShader_URP)
#include "Pipeline/URP/IvyBindCore.hlsl"
#endif


#endif
