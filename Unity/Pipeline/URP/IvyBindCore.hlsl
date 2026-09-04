
//===[引入核心宏定义]===
#include "../../../Ivy/IvyMacro.hlsl"

//===[注入映射系统]===
#define Inc_IvyMap "../../Unity/Pipeline/URP/Core/Map/IvyLinkMap.hlsl"
//===[注入基础库]===
#define Inc_IvyLibrary "../../Unity/Pipeline/URP/Core/Library/IvyLinkLibrary.hlsl"
//===[注入 Unity 绑定]===
#define Inc_IvyBind "../../Unity/Pipeline/URP/Core/Bind/IvyLinkBind.hlsl"

#include "Pass/IvyPass.hlsl"


