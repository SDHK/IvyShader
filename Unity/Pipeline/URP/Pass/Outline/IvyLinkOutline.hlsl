/****************************************
*
* 作者： 闪电黑客
* 日期： 2026/1/8
*
* 描述： Ivy Shader Outline Pass 库入口
* 
* 功能：管理 Outline 文件夹下的所有 Pass 的链接
*
*/


#if Link(IvyPass)
#if Link(IvyPassOutline)
#include "IvyPassOutline.hlsl"
#endif
#endif
