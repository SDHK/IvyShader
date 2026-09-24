/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/4 14:16
*
* 说明： Unity 引擎的 Ivy Shader 库统一入口
*
* 功能：按 IvyConfig 选中的管线，进入对应的 IvyPipeCore
*
* 产品的 PassPort 在写完语义尾巴后引入本文件
*
*/

#ifndef Def_IvyCoreUnity
#define Def_IvyCoreUnity

//===[选管线]===
#include "../IvyConfig.hlsl"

#if defined(IvyShader_URP)
#include "Pipeline/URP/IvyPipeCore.hlsl"
#elif defined(IvyShader_BRP)
#include "Pipeline/BRP/IvyPipeCore.hlsl"
#endif


#endif
