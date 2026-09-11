/****************************************
*
* 描述： IvyObjectTransparentTess Pass 链接（URP）
*        产品门 Link_IvyObjectTransparentTess
*        角色门 Link_IvyPassMain / Outline / ShadowCaster
*
****************************************/

#ifndef Def_IvyObjectTransparentTess 
#define Def_IvyObjectTransparentTess 

#if Link(IvyObjectTransparentTess)

#define Link_IvyTess

#include "IvyArg.hlsl"

#if Link(IvyPassMain)
#include "IvyPassMain.hlsl"
#endif

#if Link(IvyPassOutline)
#include "IvyPassOutline.hlsl"
#endif

#if Link(IvyPassShadowCaster)
#include "IvyPassShadowCaster.hlsl"
#endif

#endif

#endif
