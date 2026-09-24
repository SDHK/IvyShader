/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/XX
*
* 说明： Unity URP 的 Ivy 功能设置映射
*
* 设计理念：
* - IvySet_XXX 是编译期开关，由 Shader 在 Pass 里定义
* - 与 IvyKey_ 的区别：不生成变体，只打开引擎的编译期宏
* - 本文件在 IvyKey 之前引入
*
* URP 不需要映射：
* - ShadowScreen 不打开引擎宏，而是被 IvyKey 读取，决定主光阴影是否生成
*   _MAIN_LIGHT_SHADOWS_SCREEN 变体，所以直接用 Shader 的定义即可
* - ShadowDepth / ShadowCube 是 BRP 的阴影类型宏，URP 无对应物
*
*/

#ifndef Def_IvySet
#define Def_IvySet

#endif // Def_IvySet
