/****************************************

* 作者： 闪电黑客
* 日期： 2026/9/13

* 描述： IvyObjectTransparentTess 产品 Flow 链接
*        直引基本库角色文件 + Tess 加法

*/

#if Def(IvyFlow)
#define Def_IvyFlow

#define Link_IvyTess

#if Link(IvyFlowMain)
#include "../IvyObjectTransparent/IvyFlowMain.hlsl"
#endif

#if Link(IvyFlowAdd)
#include "../IvyObjectTransparent/IvyFlowAdd.hlsl"
#endif

#if Link(IvyFlowOutline)
#include "../IvyObjectTransparent/IvyFlowOutline.hlsl"
#endif

#if Link(IvyFlowShadow)
#include "../IvyObjectTransparent/IvyFlowShadow.hlsl"
#endif

#include "IvyFlowTess.hlsl"

#if Link(IvyFlowMain)
#include "IvyFlowMain.hlsl"
#endif

#if Link(IvyFlowAdd)
#include "IvyFlowAdd.hlsl"
#endif

#if Link(IvyFlowOutline)
#include "IvyFlowOutline.hlsl"
#endif

#if Link(IvyFlowShadow)
#include "IvyFlowShadow.hlsl"
#endif

#endif
