/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/16
*
* 描述： URP 基础库统一入口
* 
* 功能：统一包含 URP 所需的所有基础库
*       根据 Link_IvyXXX 宏控制是否链接
*
*/

//===[基础库]===
#if Link(IvyBase)
#include "IvyBase.hlsl"
#endif

//===[光照库]===
#if Link(IvyLight)
#include "IvyLight.hlsl"
#endif


