/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/XX
*
* 说明： Unity BRP 的 Ivy 功能设置映射
*
* 设计理念：
* - IvySet_XXX 是编译期开关，由 Shader 在 Pass 里定义
* - 与 IvyKey_ 的区别：不生成变体，只打开引擎的编译期宏
* - 本文件在 IvyKey 之前引入
*
*/

#ifndef Def_IvySet
#define Def_IvySet

//===[阴影类型]===

// 屏幕空间阴影
#ifdef IvySet_ShadowScreen
#define SHADOWS_SCREEN
#endif

// 深度阴影
#ifdef IvySet_ShadowDepth
#define SHADOWS_DEPTH
#endif

// 立方体阴影
#ifdef IvySet_ShadowCube
#define SHADOWS_CUBE
#endif

#endif // Def_IvySet
