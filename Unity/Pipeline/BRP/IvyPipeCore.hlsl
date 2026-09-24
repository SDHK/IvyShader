//===[引入核心基础支持]===
#include "../../../Ivy/Core/Base/IvyLinkBase.hlsl"

//===[注入映射系统]===
#define Inc_IvyMap "../../Unity/Pipeline/BRP/Core/Map/IvyLinkMap.hlsl"
//===[注入环境履约]===
#define Inc_IvyEnv "../../Unity/Pipeline/BRP/Core/Env/IvyLinkEnv.hlsl"
//===[注入核心]===
#include "Core/IvyCore.hlsl"
