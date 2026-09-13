/****************************************

* 作者： 闪电黑客
* 日期： 2026/9/12

* 描述： Ivy 流程统一入口

*/

#ifndef Def_IvyLinkFlow
#define Def_IvyLinkFlow

#if Link(IvyObjectTransparent)
#include "IvyObject/IvyObjectTransparent/IvyFlow.hlsl"
#endif

#if Link(IvyObjectTransparentTess)
#include "IvyObject/IvyObjectTransparentTess/IvyFlow.hlsl"
#endif

#endif // Def_IvyLinkFlow
