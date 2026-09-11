/****************************************
*
* 描述： URP 基础库统一入口
*
****************************************/

#if Link(IvyBase)
#include "IvyBase.hlsl"
#include "IvyStruct.hlsl"
#endif

#if Link(IvyLight)
#include "IvyLight.hlsl"
#endif

#if Link(IvyTess)
#include "IvyTess.hlsl"
#endif
