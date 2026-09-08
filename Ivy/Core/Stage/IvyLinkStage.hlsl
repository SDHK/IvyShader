/****************************************
*
* 作者： 闪电黑客
* 日期： 2026/9/5
*
* 描述： Ivy 阶段函数统一入口
* 
* 功能：统一包含所有阶段函数文件
*       根据 Link_IvyXXX 宏控制是否链接
*
*/

#if Link(IvyGeom)
#include "IvyGeom.hlsl"      
#endif

#if Link(IvyLight)
#include "IvyLight.hlsl"      
#endif

#if Link(IvySkin)
#include "IvySkin.hlsl"
#endif

#if Link(IvyReflect)
#include "IvyReflect.hlsl"
#endif

#if Link(IvyEffect3D)
#include "IvyEffect3D.hlsl"
#endif

#if Link(IvyTransmit)
#include "IvyTransmit.hlsl"
#endif
