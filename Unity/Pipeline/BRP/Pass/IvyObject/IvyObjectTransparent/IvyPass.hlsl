/****************************************
*
* 描述： IvyObjectTransparent Pass 链接
*        产品门 Link_IvyObjectTransparent
*        角色门 Link_IvyPassMain / Add / Outline / ShadowCaster
*
****************************************/

#ifndef Def_IvyObjectTransparent 
#define Def_IvyObjectTransparent 

#if Link(IvyObjectTransparent)

#include "IvyArg.hlsl"

#if Link(IvyPassMain)
#include "IvyPassMain.hlsl"
#endif

#if Link(IvyPassAdd)
#include "IvyPassAdd.hlsl"
#endif

#if Link(IvyPassOutline)
#include "IvyPassOutline.hlsl"
#endif

#if Link(IvyPassShadowCaster)
#include "IvyPassShadowCaster.hlsl"
#endif

#endif

#endif
