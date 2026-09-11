//===[引入核心宏定义]===
#include "../../../Ivy/IvyMacro.hlsl"

//===[注入映射系统]===
#define Inc_IvyMap "../../Unity/Pipeline/BRP/Core/Map/IvyLinkMap.hlsl"
//===[注入基础库]===
#define Inc_IvyLibrary "../../Unity/Pipeline/BRP/Core/Library/IvyLinkLibrary.hlsl"
//===[注入 Unity 绑定]===
#define Inc_IvyBind "../../Unity/Pipeline/BRP/Core/Bind/IvyLinkBind.hlsl"
//===[注入 Pass 系统]===
#include "Pass/IvyLinkPass.hlsl"
