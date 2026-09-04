/****************************************
*
* 作者： 闪电黑客
* 日期： 2026/1/7
*
* 描述： Ivy Shader Main Pass 库入口
* 
* 功能：管理 Main 文件夹下的所有 Pass 的链接
*
*/

#if Link(IvyPassMainSimple)
#include "IvyPassMainSimple.hlsl"
#endif

#if Link(IvyPassMainAdd)
#include "IvyPassMainAdd.hlsl"
#endif
