/****************************************

* 作者： 闪电黑客
* 日期： 2026/9/13

* 描述： IvyObjectTransparentTess 阴影 Domain

*/

#if Def(IvyFlowShadowTess)
#define Def_IvyFlowShadowTess

IvyFlowShadow_VertOut IvyFlowShadow_Domain(IvyTess_Point pointIn)
{
    IvyFlowShadow_VertIn vertIn;
    vertIn.PosOs = pointIn.PosOs;
    vertIn.NrmOs = pointIn.NrmOs;
    return IvyFlowShadow_Vert(vertIn);
}

#endif
