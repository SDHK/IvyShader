/****************************************
*
* 作者： 闪电黑客
* 日期： 2026/9/13
*
* 说明： URP 环境履约链接
*
*/

#if Link(IvyEnvBase)
#include "IvyEnvBase.hlsl"
#endif

#if Link(IvyEnvLight)
#include "IvyEnvLight.hlsl"
#endif

#if Link(IvyTess)
#include "IvyTess.hlsl"
#endif
