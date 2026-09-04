/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/XX
*
* 说明： Unity BRP 的 Ivy 功能设置映射实现
*
* 设计理念：
* - 将 IvySet_XXX 映射到 Unity BRP 的编译时宏
* - 只有当 Pass 文件定义了 IvySet_XXX 时才进行映射
*
*/

#ifndef Def_IvySet
#define Def_IvySet

//===[阴影类型设置]===

// 屏幕空间阴影：IvySet_ShadowScreen -> SHADOWS_SCREEN
#ifdef IvySet_ShadowScreen
#define SHADOWS_SCREEN
#define IvySet_ShadowScreen
#endif

// 深度阴影：IvySet_ShadowDepth -> SHADOWS_DEPTH
#ifdef IvySet_ShadowDepth
#define SHADOWS_DEPTH
#define IvySet_ShadowDepth
#endif

// 立方体阴影：IvySet_ShadowCube -> SHADOWS_CUBE
#ifdef IvySet_ShadowCube
#define SHADOWS_CUBE
#define IvySet_ShadowCube
#endif

#endif // Def_IvySet

