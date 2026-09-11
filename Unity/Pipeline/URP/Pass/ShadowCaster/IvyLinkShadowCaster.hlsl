/****************************************
*
* 作者： 闪电黑客
* 日期： 2026/1/7
*
* 描述： Ivy Shader ShadowCaster Pass 库入口
* 
* 功能：管理 ShadowCaster 文件夹下的所有 Pass 的链接
*
*/

#if Link(IvyPass)
#if Link(IvyPassShadowCaster)
#include "IvyPassShadowCaster.hlsl"
#endif
#endif
