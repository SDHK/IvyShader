/****************************************
*
* 描述： 三角面曲面细分因子
*        触摸球碰到该三角（含包围球）才加密
*        radius 为 0 时按 tessFactor 全模型加密面数
*
*/

#if DefPart(IvyTess, Tool)
#define Def_IvyTess_Tool

#include "IvyMatrix.hlsl"

/// <summary>
/// 三角面细分因子。depth 为 0 时返回 1（不加密）。
/// radius 为 0 时整模型按 tessFactor 加密；否则仅触摸球碰到该三角（含包围球）才加密。
/// </summary>
/// <param name="pos0">三角顶点 0，物体空间</param>
/// <param name="pos1">三角顶点 1，物体空间</param>
/// <param name="pos2">三角顶点 2，物体空间</param>
/// <param name="depth">按压深度，0 表示不细分</param>
/// <param name="touchPosWs">触摸球心，世界空间</param>
/// <param name="radius">触摸半径，0 表示全模型加密</param>
/// <param name="tessFactor">命中时的细分倍数，至少为 1</param>
float IvyTess_Factor(
    float3 pos0,
    float3 pos1,
    float3 pos2,
    float depth,
    float3 touchPosWs,
    float radius,
    float tessFactor)
{
    float factor = 1.0;
    if (abs(depth) > 1e-5)
    {
        factor = max(tessFactor, 1.0);
        if (radius > 1e-5)
        {
            float3 touchOs = IvyMatrix_PosWsToOs(touchPosWs);
            float3 center = (pos0 + pos1 + pos2) * (1.0 / 3.0);
            float bound = max(distance(center, pos0), max(distance(center, pos1), distance(center, pos2)));
            if (distance(center, touchOs) > bound + radius)
            {
                factor = 1.0;
            }
        }
    }
    return factor;
}

#endif
