/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/XX
*
* 说明： Unity URP 的 Ivy 变体关键字映射
*
* 设计理念：
* - Shader 写 IvyKey_XXX（空定义），本文件负责发 #pragma
* - 需要在代码里判断的，改写成可 #if 的表达式（注意是 #if 不是 #ifdef）
* - 只处理 Shader 已定义的条目，没写的不生成变体
*
* URP 没有对应物的语义：
* - ForwardBase / ForwardAdd：URP 用 UniversalForward 一次算完主光与附加光
* - VertexLight：URP 的顶点光照走 _ADDITIONAL_LIGHTS_VERTEX
*
*/

#ifndef Def_IvyKey
#define Def_IvyKey

//===[阴影变体]===

// 主光阴影。透明 Pass 默认不含 SCREEN：屏幕空间阴影采不透明深度，会在身上打出块状投影
// 需要 SCREEN 时，Shader 在本文件之前写 IvySet_ShadowScreen
#ifdef IvyKey_MainLightShadows
#ifdef IvySet_ShadowScreen
#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
#else
#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE
#endif
#define IvyKey_MainLightShadows (defined(_MAIN_LIGHT_SHADOWS) || defined(_MAIN_LIGHT_SHADOWS_CASCADE) || defined(_MAIN_LIGHT_SHADOWS_SCREEN))
#endif

// 级联阴影：变体由 MainLightShadows 一并生成，这里只给判断值
#ifdef IvyKey_MainLightShadowsCascade
#define IvyKey_MainLightShadowsCascade defined(_MAIN_LIGHT_SHADOWS_CASCADE)
#endif

#ifdef IvyKey_ShadowsSoft
#pragma multi_compile_fragment _ _SHADOWS_SOFT
#pragma multi_compile_fragment _ _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
#define IvyKey_ShadowsSoft (defined(_SHADOWS_SOFT) || defined(_SHADOWS_SOFT_LOW) || defined(_SHADOWS_SOFT_MEDIUM) || defined(_SHADOWS_SOFT_HIGH))
#endif

// 阴影投射变体
#ifdef IvyKey_ShadowCaster
#pragma multi_compile_shadowcaster
#endif

//===[光照变体]===

// 附加光：点光与聚光
#ifdef IvyKey_AdditionalLights
#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
#define IvyKey_AdditionalLights defined(_ADDITIONAL_LIGHTS)
#endif

#ifdef IvyKey_AdditionalLightShadows
#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
#define IvyKey_AdditionalLightShadows defined(_ADDITIONAL_LIGHT_SHADOWS)
#endif

//===[基础变体]===

// 雾效：Unity 按场景设置选 FOG_LINEAR / FOG_EXP / FOG_EXP2
#ifdef IvyKey_Fog
#pragma multi_compile_fog
#define IvyKey_Fog (defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2))
#endif

#ifdef IvyKey_Instancing
#pragma multi_compile_instancing
#define IvyKey_Instancing defined(_INSTANCING)
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
