/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/5 10:29
*
* 说明： Ivy Shader 库外部统一入口文件
*
* 设计理念：
* - 本文件是外部 Shader 文件使用的统一入口，避免路径写错
* - 内部工具文件之间使用直接路径引用
*
* IvyShader 宏说明：
* - 编辑器时（未定义 IvyShader）：
*   用于代码跳转和依赖提示，让开发者能够：
*   * 通过 #include "../IvyEdit.hlsl" 跳转到依赖模块
*   * 看到需要定义的 Link_XXX 宏（如 Link_IvyHash）
*   * 理解模块间的依赖关系
* - 运行时（定义 IvyShader）：
*   让编辑器辅助入口（IvyEdit.hlsl）无效化，实际包含由 IvyLinkTool.hlsl 统一控制
*   避免循环引用，确保只包含需要的模块
*
* 注意：
* - 本文件是给外部 Shader 文件使用的运行时入口
* - 内部工具文件（Tool/）和 Pass 文件（Pass/）应使用 IvyEdit.hlsl 作为编辑器辅助入口
* - IvyEdit.hlsl 在运行时会被 IvyShader 宏禁用，避免不必要的代码包含
*
*/


#ifndef Def_IvyCore
#define Def_IvyCore

//===[引入核心宏定义]===
#include "../IvyMacro.hlsl"

//===[引入映射系统]===
// 注意：Map 必须在 Library 之前引入，以便 Unity 库代码能正确识别关键字
#ifdef Inc_IvyMap
#include Inc_IvyMap
#endif

//===[环境库引用]===
// 引用基础库（根据 URP/BRP 自动选择）
// 使用 Link_IvyBase 和 Link_IvyLight 宏控制是否链接
#ifdef Inc_IvyLibrary
#include Inc_IvyLibrary
#endif

//===[Ivy库引用]===

//===[引入定义]===
#include "Define/IvyLinkDefine.hlsl"

//===[引入外部绑定]===
#ifdef Inc_IvyBind
#include Inc_IvyBind 
#else
#include "Bind/IvyLinkBind.hlsl"
#endif

//===[入口引用]===

// 组装流程统一入口（根据 Link_IvyXXX 宏控制是否链接）
#include "Flow/IvyLinkFlow.hlsl"

#endif // Def_IvyCore