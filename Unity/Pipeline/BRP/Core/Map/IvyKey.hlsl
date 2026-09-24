/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/XX
*
* 说明： Unity BRP 的 Ivy 变体关键字映射
*
* 设计理念：
* - Shader 写 IvyKey_XXX（空定义），本文件负责发 #pragma
* - 需要在代码里判断的，改写成可 #if 的表达式（注意是 #if 不是 #ifdef）
* - 只处理 Shader 已定义的条目，没写的不生成变体
*
* BRP 无需单独映射的语义：
* - MainLightShadows / MainLightShadowsCascade / ShadowsSoft / AdditionalLightShadows
*   由 multi_compile_fwdbase 与 fwdadd_fullshadows 一并带出，代码中不判断
* - Instancing：BRP 没有对应的关键字
*
*/

#ifndef Def_IvyKey
#define Def_IvyKey

//===[变体生成]===

// 阴影投射变体
#ifdef IvyKey_ShadowCaster
#pragma multi_compile_shadowcaster
#endif

// 主光：含主光阴影与环境光
#ifdef IvyKey_ForwardBase
#pragma multi_compile_fwdbase
#endif

// 附加光：逐光一次，fullshadows 含屏幕空间 / 深度 / 立方体阴影
#ifdef IvyKey_ForwardAdd
#pragma multi_compile_fwdadd_fullshadows
#endif

// 雾效：Unity 按场景设置选 FOG_LINEAR / FOG_EXP / FOG_EXP2
#ifdef IvyKey_Fog
#pragma multi_compile_fog
#define IvyKey_Fog (defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2))
#endif

//===[场景自动控制，不需要 pragma]===

#ifdef IvyKey_Lightmap
#define IvyKey_Lightmap defined(LIGHTMAP_ON)
#endif

#ifdef IvyKey_DynamicLightmap
#define IvyKey_DynamicLightmap defined(DYNAMICLIGHTMAP_ON)
#endif

#ifdef IvyKey_DirectionalLightmap
#define IvyKey_DirectionalLightmap defined(DIRLIGHTMAP_COMBINED)
#endif

// 顶点光照：fwdbase 变体带出
#ifdef IvyKey_VertexLight
#define IvyKey_VertexLight defined(VERTEXLIGHT_ON)
#endif

//===[Ivy 自定义变体]===

#ifdef IvyKey_AnimLoop
#pragma multi_compile ___ ANIM_LOOP
#define IvyKey_AnimLoop defined(ANIM_LOOP)
#endif

#ifdef IvyKey_AnimPaused
#pragma multi_compile ___ ANIM_PAUSED
#define IvyKey_AnimPaused defined(ANIM_PAUSED)
#endif

#ifdef IvyKey_EnableAnim
#pragma shader_feature _ ENABLE_ANIM
#define IvyKey_EnableAnim defined(ENABLE_ANIM)
#endif

#endif // Def_IvyKey
