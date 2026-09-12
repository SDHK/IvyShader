/****************************************
*
* 作者： 闪电黑客
* 日期： 2026/9/13 10:29
*
* 说明： Ivy Shader 工具库
*
* 设计理念：
*
*/


#ifndef Def_IvyKit
#define Def_IvyKit


#ifndef IvyShader
#include "IvyCore.hlsl"
#endif

//===[工具引用]===

// 工具函数统一入口（根据 Link_IvyXXX 宏控制是否链接）
#include "Tool/IvyLinkTool.hlsl"

// 阶段函数统一入口（根据 Link_IvyXXX 宏控制是否链接）
#include "Stage/IvyLinkStage.hlsl"
#endif // Def_IvyKit