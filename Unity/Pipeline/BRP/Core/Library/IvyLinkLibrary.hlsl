/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/16
*
* 描述： BRP 基础库统一入口
* 
* 功能：统一包含 BRP 所需的所有基础库
*       根据 Link_IvyXXX 宏控制是否链接
*
*/

//===[基础库]===
#if Link(IvyBase)
#include "IvyBase.hlsl"
#include "IvyStruct.hlsl"
#endif

//===[光照库]===
#if Link(IvyLight)
#include "IvyLight.hlsl"
#endif

#if Link(IvyAudioLink)
#include "IvyAudioLink.hlsl"
#endif

#if Link(IvyTess)
#include "IvyTess.hlsl"
#endif


