/****************************************

* 作者： 闪电黑客
* 日期： 2026/9/13

* 描述： IvyObjectTransparentTess Flow 细分配方
*        无 GPU 语义。Pass 用 IvyTess_HullTri / DomainTri 挂号。

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

#if Link(IvyFlowMain)
IvyFlowMain_VertOut IvyFlowMain_Domain(IvyTess_Point pointIn)
{
    IvyFlowMain_VertIn vertIn;
    vertIn.PosOs = pointIn.PosOs;
    vertIn.NrmOs = pointIn.NrmOs;
    vertIn.Uv = pointIn.Uv;
    return IvyFlowMain_Vert(vertIn);
}
#endif

#if Link(IvyFlowAdd)
IvyFlowAdd_VertOut IvyFlowAdd_Domain(IvyTess_Point pointIn)
{
    IvyFlowAdd_VertIn vertIn;
    vertIn.PosOs = pointIn.PosOs;
    vertIn.NrmOs = pointIn.NrmOs;
    vertIn.Uv = pointIn.Uv;
    return IvyFlowAdd_Vert(vertIn);
}
#endif

#if Link(IvyFlowOutline)
IvyFlowOutline_VertOut IvyFlowOutline_Domain(IvyTess_Point pointIn)
{
    IvyFlowOutline_VertIn vertIn;
    vertIn.PosOs = pointIn.PosOs;
    vertIn.NrmOs = pointIn.NrmOs;
    return IvyFlowOutline_Vert(vertIn);
}
#endif

#if Link(IvyFlowShadow)
IvyFlowShadow_VertOut IvyFlowShadow_Domain(IvyTess_Point pointIn)
{
    IvyFlowShadow_VertIn vertIn;
    vertIn.PosOs = pointIn.PosOs;
    vertIn.NrmOs = pointIn.NrmOs;
    return IvyFlowShadow_Vert(vertIn);
}
#endif

#endif
