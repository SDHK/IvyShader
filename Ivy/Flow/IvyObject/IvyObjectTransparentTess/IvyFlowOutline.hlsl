/****************************************

* 作者： 闪电黑客
* 日期： 2026/9/13

* 描述： IvyObjectTransparentTess 描边 Domain

*/

#if Def(IvyFlowOutlineTess)
#define Def_IvyFlowOutlineTess

IvyFlowOutline_VertOut IvyFlowOutline_Domain(IvyTess_Point pointIn)
{
    IvyFlowOutline_VertIn vertIn;
    vertIn.PosOs = pointIn.PosOs;
    vertIn.NrmOs = pointIn.NrmOs;
    return IvyFlowOutline_Vert(vertIn);
}

#endif
