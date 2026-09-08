/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/19
*
* 描述： Ivy Shader 编辑器辅助入口文件
*
* 设计目的：
* - 为编辑器提供代码跳转和依赖提示功能
* - 运行时完全无效化，避免不必要的代码包含
*
* 工作机制：
* - 编辑器时（未定义 IvyShader）：
*   包含 IvyCore.hlsl，提供代码跳转和依赖提示
*   让开发者能够：
*   * 通过 #include "../IvyEdit.hlsl" 跳转到依赖模块
* - 运行时（定义 IvyShader）：
*   不包含任何内容，完全无效化
*   实际包含由 IvyLinkTool.hlsl 统一控制
*   避免循环引用，确保只包含需要的模块
*
* 注意：
* - 本文件仅用于编辑器辅助，运行时会被 IvyShader 宏禁用
* - 外部 Shader 文件应使用 IvyCore.hlsl 作为入口
*
*/

#ifndef IvyShader
#include "IvyCore.hlsl"
#endif