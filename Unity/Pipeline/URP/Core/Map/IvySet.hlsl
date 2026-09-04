/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/XX
*
* 说明： Unity URP 的 Ivy 功能设置映射实现
*
* 设计理念：
* - 将 IvySet_XXX 映射到 Unity URP 的编译时宏
* - 只有当 Pass 文件定义了 IvySet_XXX 时才进行映射
* - URP 不使用 BRP 的阴影类型宏，但保留接口以保持一致性
*
*/

#ifndef Def_IvySet
#define Def_IvySet

//===[阴影类型设置]===
// URP 不使用这些阴影类型宏，但保留接口以保持一致性

// 屏幕空间阴影：URP 不支持
#ifdef IvySet_ShadowScreen
#define IvySet_ShadowScreen
#endif

// 深度阴影：URP 不支持
#ifdef IvySet_ShadowDepth
#define IvySet_ShadowDepth
#endif

// 立方体阴影：URP 不支持
#ifdef IvySet_ShadowCube
#define IvySet_ShadowCube
#endif

#endif // Def_IvySet

