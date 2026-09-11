/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/16
*
* 描述： Ivy Shader Pass 统一入口（URP）
*
* 使用方法：
*    #define Link_IvyObjectTransparentTess
*    #define Link_IvyPassMain
*
*/

#ifndef Def_IvyLinkPass
#define Def_IvyLinkPass

#if Link(IvyObjectTransparentTess)
#include "IvyObject/IvyObjectTransparentTess/IvyPass.hlsl"
#endif

#endif // Def_IvyLinkPass
