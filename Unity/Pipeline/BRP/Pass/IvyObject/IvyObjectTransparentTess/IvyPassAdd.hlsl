/****************************************

* 作者： 闪电黑客
* 日期： 2026/9/13

* 描述： IvyObjectTransparentTess BRP 附加光 Pass 适配

*/

#if Def(IvyPassAdd)
#define Def_IvyPassAdd

#define IvyKey_Instancing
#define IvyKey_Fog
#define IvyKey_ForwardAdd

#include "IvyPassVar.hlsl"

#define Link_IvyEnvBase
#define Link_IvyEnvLight
#define Link_IvyFlowAdd
#include "../../../Core/IvyCore.hlsl"
#include "IvyPassPort.hlsl"

#endif
