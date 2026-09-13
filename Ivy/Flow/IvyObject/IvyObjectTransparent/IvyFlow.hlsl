/****************************************

* 作者： 闪电黑客
* 日期： 2026/9/13

* 描述： IvyObjectTransparent 产品 Flow 链接
*        基本库：Vert / Frag

*/

#if Def(IvyFlow)
#define Def_IvyFlow

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
