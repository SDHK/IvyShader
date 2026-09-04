/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/XX
*
* 说明： Unity BRP 的 Ivy 关键字映射实现
*
* 设计理念：
* - 将 IvyKey_XXX 映射到 Unity BRP 的关键字
* - 只有当 Pass 文件定义了 IvyKey_XXX 时才进行映射
* - BRP 的阴影和光照通过 fwdbase 变体处理，部分关键字不需要映射
*
*/

#ifndef Def_IvyKey
#define Def_IvyKey

//===[阴影关键字映射]===
// BRP 的阴影通过 fwdbase 变体处理，不需要单独的关键字映射

// 主光源阴影：BRP 通过 fwdbase 处理，不需要关键字映射
#ifdef IvyKey_MainLightShadows
#define IvyKey_MainLightShadows
#endif

// 级联阴影：BRP 不支持级联阴影
#ifdef IvyKey_MainLightShadowsCascade
#define IvyKey_MainLightShadowsCascade
#endif

// 软阴影：BRP 不支持软阴影关键字
#ifdef IvyKey_ShadowsSoft
#define IvyKey_ShadowsSoft
#endif

// 附加光源阴影：BRP 通过 fwdbase 处理
#ifdef IvyKey_AdditionalLightShadows
#define IvyKey_AdditionalLightShadows
#endif

// 阴影投射器：生成 #pragma multi_compile_shadowcaster
// 注意：IvyKey_ShadowCaster 是空定义（不映射到 Unity 关键字），仅用于触发变体生成
// BRP 的 shadowcaster 变体由 multi_compile_shadowcaster 自动处理，代码中无需判断关键字
#ifdef IvyKey_ShadowCaster
#pragma multi_compile_shadowcaster
#define IvyKey_ShadowCaster
#endif

//===[基础功能关键字映射]===

// 雾效：生成 #pragma multi_compile_fog
// 注意：IvyKey_Fog 映射到组合判断（FOG_LINEAR || FOG_EXP || FOG_EXP2），用于在代码中判断是否有雾效
// Unity 会根据场景设置自动选择 FOG_LINEAR/FOG_EXP/FOG_EXP2 变体
// BRP 中使用 UNITY_APPLY_FOG 宏（需包含 UnityCG.cginc）：UNITY_FOG_COORDS + UNITY_TRANSFER_FOG + UNITY_APPLY_FOG
// 代码中使用 #if IvyKey_Fog 判断是否有雾效（注意是 #if 不是 #ifdef）
#ifdef IvyKey_Fog
#pragma multi_compile_fog
#define IvyKey_Fog (defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2))
#endif

// GPU Instancing：BRP 不支持 _INSTANCING 关键字
#ifdef IvyKey_Instancing
#define IvyKey_Instancing
#endif

// DOTS Instancing：BRP 不支持 DOTS Instancing
#ifdef IvyKey_DotsInstancing
#define IvyKey_DotsInstancing
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

// 顶点光照：IvyKey_VertexLight -> VERTEXLIGHT_ON
// 代码中使用 #if IvyKey_VertexLight 判断是否启用顶点光照
#ifdef IvyKey_VertexLight
#define IvyKey_VertexLight defined(VERTEXLIGHT_ON)
#endif

//===[BRP 特有关键字映射]===

// Forward Base：生成 #pragma multi_compile_fwdbase
// 注意：IvyKey_ForwardBase 是空定义（不映射到 Unity 关键字），仅用于触发变体生成
// BRP 的 fwdbase 变体包含光照和阴影信息，代码中无需判断此关键字，Unity 会自动选择正确的变体
#ifdef IvyKey_ForwardBase
#pragma multi_compile_fwdbase
#define IvyKey_ForwardBase
#endif

// Forward Add：生成 #pragma multi_compile_fwdadd_fullshadows
// 注意：IvyKey_ForwardAdd 是空定义（不映射到 Unity 关键字），仅用于触发变体生成
// BRP 的 fwdadd 变体用于附加光源（点光、聚光），每个附加光源执行一次
// fullshadows 版本包含所有阴影类型（屏幕空间阴影、深度阴影、立方体阴影）
#ifdef IvyKey_ForwardAdd
#pragma multi_compile_fwdadd_fullshadows
#define IvyKey_ForwardAdd
#endif

//===[纹理相关关键字映射]===

// 法线贴图：IvyKey_NormalMap -> _NORMALMAP
// 代码中使用 #if IvyKey_NormalMap 判断是否有法线贴图
#ifdef IvyKey_NormalMap
#define IvyKey_NormalMap defined(_NORMALMAP)
#endif

// 镜面高光贴图：BRP 可能使用不同的关键字
#ifdef IvyKey_SpecGlossMap
#define IvyKey_SpecGlossMap
#endif

// 金属度光泽度贴图：BRP 可能使用不同的关键字
#ifdef IvyKey_MetallicGlossMap
#define IvyKey_MetallicGlossMap
#endif

// 反照率贴图：BRP 可能使用不同的关键字
#ifdef IvyKey_AlbedoMap
#define IvyKey_AlbedoMap
#endif

// 细节贴图：BRP 可能使用不同的关键字
#ifdef IvyKey_DetailMap
#define IvyKey_DetailMap
#endif

//===[高级功能关键字映射]===

// 像素对齐：IvyKey_PixelSnap -> PIXELSNAP_ON
// 代码中使用 #if IvyKey_PixelSnap 判断是否启用像素对齐
#ifdef IvyKey_PixelSnap
#define IvyKey_PixelSnap defined(PIXELSNAP_ON)
#endif

// 屏幕空间反射：BRP 不支持屏幕空间反射关键字
#ifdef IvyKey_ScreenSpaceReflections
#define IvyKey_ScreenSpaceReflections
#endif

// 环境光遮蔽：BRP 可能使用不同的关键字
#ifdef IvyKey_AmbientOcclusion
#define IvyKey_AmbientOcclusion
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

