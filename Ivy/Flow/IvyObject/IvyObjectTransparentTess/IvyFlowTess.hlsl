/****************************************

* 作者： 闪电黑客
* 日期： 2026/9/13

* 描述： IvyObjectTransparentTess 共用细分配方
*        Hull / HullConst。无 GPU 语义。

*/

#if Def(IvyFlowTess)
#define Def_IvyFlowTess

IvyTess_Point IvyFlowTess_Hull(IvyTess_Point pointIn)
{
    return pointIn;
}

float IvyFlowTess_HullConst(float3 pos0, float3 pos1, float3 pos2)
{
    return IvyTess_Factor(pos0, pos1, pos2, IvyArg_PressDepth, IvyArg_PressPos.xyz, IvyArg_PressRadius, IvyArg_TessFactor);
}

#endif
