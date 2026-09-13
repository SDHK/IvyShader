/****************************************

* 作者： 闪电黑客
* 日期： 2026/9/13

* 描述： IvyObjectTransparent BRP 描边 Pass 适配

*/

#if Def(IvyPassOutline)
#define Def_IvyPassOutline

#include "../../../Core/IvyStruct.hlsl"

struct IvyFlow_VertIn
{
    IvyVar_PosOs
    IvyVar_NrmOs
};

struct IvyFlow_VertOut
{
    IvyVar_PosCs
};

struct IvyFlow_FragIn
{
    IvyFlow_VertOut VertOut;
};

struct IvyFlow_FragOut { IvyVar_TargetRgba };

#define Link_IvyEnvBase
#define Link_IvyFlowOutline
#include "../../../Core/IvyCore.hlsl"

#pragma vertex IvyFlow_Vert
#pragma fragment IvyFlow_Frag

#endif
