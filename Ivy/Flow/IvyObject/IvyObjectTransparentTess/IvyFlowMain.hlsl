/****************************************

* 作者： 闪电黑客
* 日期： 2026/9/13

* 描述： IvyObjectTransparentTess 主光 Domain

*/

#if Def(IvyFlowMainTess)
#define Def_IvyFlowMainTess

IvyFlow_VertOut IvyFlow_Domain(IvyTess_Point pointIn)
{
    IvyFlow_VertIn vertIn;
    vertIn.PosOs = pointIn.PosOs;
    vertIn.NrmOs = pointIn.NrmOs;
    vertIn.Uv = pointIn.Uv;
    return IvyFlow_Vert(vertIn);
}

#endif
