/****************************************

* 作者： 闪电黑客
* 日期： 2026/9/13

* 描述： IvyObjectTransparentTess 附加光 Domain

*/

#if Def(IvyFlowAddTess)
#define Def_IvyFlowAddTess

IvyFlowAdd_VertOut IvyFlowAdd_Domain(IvyTess_Point pointIn)
{
    IvyFlowAdd_VertIn vertIn;
    vertIn.PosOs = pointIn.PosOs;
    vertIn.NrmOs = pointIn.NrmOs;
    vertIn.Uv = pointIn.Uv;
    return IvyFlowAdd_Vert(vertIn);
}

#endif
