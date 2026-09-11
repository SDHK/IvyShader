/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/XX
*
* 说明： Unity URP 的 Ivy 关键字映射实现
*
* 设计理念：
* - 将 IvyKey_XXX 映射到 Unity URP 的 _XXX 关键字
* - 只有当 Pass 文件定义了 IvyKey_XXX 时才进行映射
*
*/

#ifndef Def_IvyKey
#define Def_IvyKey

//===[阴影关键字映射]===

// 主光源阴影（含级联 / 屏幕空间）
#ifdef IvyKey_MainLightShadows
#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
#define IvyKey_MainLightShadows defined(_MAIN_LIGHT_SHADOWS)
#endif

#ifdef IvyKey_MainLightShadowsCascade
#define IvyKey_MainLightShadowsCascade defined(_MAIN_LIGHT_SHADOWS_CASCADE)
#endif

// 软阴影：生成 #pragma multi_compile _ _SHADOWS_SOFT
// 代码中使用 #if IvyKey_ShadowsSoft 判断是否有软阴影
#ifdef IvyKey_ShadowsSoft
#pragma multi_compile _ _SHADOWS_SOFT
#define IvyKey_ShadowsSoft defined(_SHADOWS_SOFT)
#endif

// 附加光源：生成 #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
// 代码中使用 #if IvyKey_AdditionalLights 判断是否有附加光源（点光源、聚光灯）
#ifdef IvyKey_AdditionalLights
#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
#define IvyKey_AdditionalLights defined(_ADDITIONAL_LIGHTS)
#endif

// 附加光源阴影：生成 #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
// 代码中使用 #if IvyKey_AdditionalLightShadows 判断是否有附加光源阴影
#ifdef IvyKey_AdditionalLightShadows
#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
#define IvyKey_AdditionalLightShadows defined(_ADDITIONAL_LIGHT_SHADOWS)
#endif

// 阴影投射器：生成 #pragma multi_compile_shadowcaster
#ifdef IvyKey_ShadowCaster
#pragma multi_compile_shadowcaster
#define IvyKey_ShadowCaster
#endif

//===[基础功能关键字映射]===

// 雾效：生成 #pragma multi_compile_fog
// 注意：IvyKey_Fog 映射到组合判断（FOG_LINEAR || FOG_EXP || FOG_EXP2），用于在代码中判断是否有雾效
// Unity 会根据场景设置自动选择 FOG_LINEAR/FOG_EXP/FOG_EXP2 变体
// URP 中使用 MixFog/MixFogColor 函数（需包含 URP 库），BRP 中使用 UNITY_APPLY_FOG 宏
// 代码中使用 #if IvyKey_Fog 判断是否有雾效（注意是 #if 不是 #ifdef）
#ifdef IvyKey_Fog
#pragma multi_compile_fog
#define IvyKey_Fog (defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2))
#endif

// GPU Instancing：生成 #pragma multi_compile_instancing
// 代码中使用 #if IvyKey_Instancing 判断是否启用 GPU Instancing
#ifdef IvyKey_Instancing
#pragma multi_compile_instancing
#define IvyKey_Instancing defined(_INSTANCING)
#endif

// DOTS Instancing：生成 #pragma multi_compile _ DOTS_INSTANCING_ON
// 代码中使用 #if IvyKey_DotsInstancing 判断是否启用 DOTS Instancing
#ifdef IvyKey_DotsInstancing
#pragma multi_compile _ DOTS_INSTANCING_ON
#define IvyKey_DotsInstancing defined(DOTS_INSTANCING_ON)
#endif

//===[光照相关关键字映射]===

// 光照贴图：IvyKey_Lightmap -> LIGHTMAP_ON
// 注意：Unity 根据场景设置自动控制此关键字，不需要 #pragma
// 代码中使用 #if IvyKey_Lightmap 判断是否有光照贴图
#ifdef IvyKey_Lightmap
#define IvyKey_Lightmap defined(LIGHTMAP_ON)
#endif

// 动态光照贴图：IvyKey_DynamicLightmap -> DYNAMICLIGHTMAP_ON
// 注意：Unity 根据场景设置自动控制此关键字，不需要 #pragma
// 代码中使用 #if IvyKey_DynamicLightmap 判断是否有动态光照贴图
#ifdef IvyKey_DynamicLightmap
#define IvyKey_DynamicLightmap defined(DYNAMICLIGHTMAP_ON)
#endif

// 方向性光照贴图：IvyKey_DirectionalLightmap -> DIRLIGHTMAP_COMBINED
// 注意：Unity 根据场景设置自动控制此关键字，不需要 #pragma
// 代码中使用 #if IvyKey_DirectionalLightmap 判断是否有方向性光照贴图
#ifdef IvyKey_DirectionalLightmap
#define IvyKey_DirectionalLightmap defined(DIRLIGHTMAP_COMBINED)
#endif

// 顶点光照：URP 不支持顶点光照
#ifdef IvyKey_VertexLight
#define IvyKey_VertexLight
#endif

//===[BRP 特有关键字映射]===

// Forward Base：URP 不支持 Forward Base
#ifdef IvyKey_ForwardBase
#define IvyKey_ForwardBase
#endif

//===[纹理相关关键字映射]===

// 法线贴图：IvyKey_NormalMap -> _NORMALMAP
// 代码中使用 #if IvyKey_NormalMap 判断是否有法线贴图
#ifdef IvyKey_NormalMap
#define IvyKey_NormalMap defined(_NORMALMAP)
#endif

// 镜面高光贴图：IvyKey_SpecGlossMap -> _SPECGLOSSMAP
// 代码中使用 #if IvyKey_SpecGlossMap 判断是否有镜面高光贴图
#ifdef IvyKey_SpecGlossMap
#define IvyKey_SpecGlossMap defined(_SPECGLOSSMAP)
#endif

// 金属度光泽度贴图：IvyKey_MetallicGlossMap -> _METALLICGLOSSMAP
// 代码中使用 #if IvyKey_MetallicGlossMap 判断是否有金属度光泽度贴图
#ifdef IvyKey_MetallicGlossMap
#define IvyKey_MetallicGlossMap defined(_METALLICGLOSSMAP)
#endif

// 反照率贴图：IvyKey_AlbedoMap -> _ALBEDOMAP
// 代码中使用 #if IvyKey_AlbedoMap 判断是否有反照率贴图
#ifdef IvyKey_AlbedoMap
#define IvyKey_AlbedoMap defined(_ALBEDOMAP)
#endif

// 细节贴图：IvyKey_DetailMap -> _DETAIL_MAP
// 代码中使用 #if IvyKey_DetailMap 判断是否有细节贴图
#ifdef IvyKey_DetailMap
#define IvyKey_DetailMap defined(_DETAIL_MAP)
#endif

//===[高级功能关键字映射]===

// 像素对齐：IvyKey_PixelSnap -> PIXELSNAP_ON
// 代码中使用 #if IvyKey_PixelSnap 判断是否启用像素对齐
#ifdef IvyKey_PixelSnap
#define IvyKey_PixelSnap defined(PIXELSNAP_ON)
#endif

// 屏幕空间反射：IvyKey_ScreenSpaceReflections -> _SCREEN_SPACE_REFLECTIONS
// 代码中使用 #if IvyKey_ScreenSpaceReflections 判断是否启用屏幕空间反射
#ifdef IvyKey_ScreenSpaceReflections
#define IvyKey_ScreenSpaceReflections defined(_SCREEN_SPACE_REFLECTIONS)
#endif

// 环境光遮蔽：IvyKey_AmbientOcclusion -> _AMBIENT_OCCLUSION
// 代码中使用 #if IvyKey_AmbientOcclusion 判断是否启用环境光遮蔽
#ifdef IvyKey_AmbientOcclusion
#define IvyKey_AmbientOcclusion defined(_AMBIENT_OCCLUSION)
#endif

// 反射探针：IvyKey_ReflectionProbe -> _REFLECTION_PROBE
// 注意：Unity 根据场景设置自动控制此关键字，不需要 #pragma
// 代码中使用 #if IvyKey_ReflectionProbe 判断是否有反射探针
#ifdef IvyKey_ReflectionProbe
#define IvyKey_ReflectionProbe defined(_REFLECTION_PROBE)
#endif

// 光照探针：IvyKey_LightProbe -> _LIGHT_PROBE
// 注意：Unity 根据场景设置自动控制此关键字，不需要 #pragma
// 代码中使用 #if IvyKey_LightProbe 判断是否有光照探针
#ifdef IvyKey_LightProbe
#define IvyKey_LightProbe defined(_LIGHT_PROBE)
#endif

//===[自定义功能关键字映射]===

// 动画循环：生成 #pragma multi_compile ___ ANIM_LOOP
// 代码中使用 #if IvyKey_AnimLoop 判断是否启用动画循环
#ifdef IvyKey_AnimLoop
#pragma multi_compile ___ ANIM_LOOP
#define IvyKey_AnimLoop defined(ANIM_LOOP)
#endif

// 动画暂停：生成 #pragma multi_compile ___ ANIM_PAUSED
// 代码中使用 #if IvyKey_AnimPaused 判断是否启用动画暂停
#ifdef IvyKey_AnimPaused
#pragma multi_compile ___ ANIM_PAUSED
#define IvyKey_AnimPaused defined(ANIM_PAUSED)
#endif

// 启用动画：生成 #pragma shader_feature _ ENABLE_ANIM
// 代码中使用 #if IvyKey_EnableAnim 判断是否启用动画
#ifdef IvyKey_EnableAnim
#pragma shader_feature _ ENABLE_ANIM
#define IvyKey_EnableAnim defined(ENABLE_ANIM)
#endif

#endif // Def_IvyKey

