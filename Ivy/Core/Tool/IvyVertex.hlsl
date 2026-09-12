/****************************************

* 作者： 闪电黑客
* 日期： 2025/12/10 18:29

* 描述： Ivy 顶点工具函数 

*/
#if DefPart(IvyVertex, Tool) 
#define Def_IvyVertex_Tool

#include "IvyMatrix.hlsl"



// 顶点沿法线方向缩放
// float4 positionOS: 输入的模型空间位置
// float3 normal: 输入的模型空间法线
// float scale: 缩放值
// float3 return: 缩放后的模型空间位置
float3 IvyVertex_Scale(float4 positionOS, float3 normal,  float scale)
{
    // 顶点沿法线方向扩展顶点
    return positionOS.xyz + normal * scale;
}

struct IvyVertex_PressOut
{
    float3 PosOs;
    float3 NrmOs;
};

/// <summary>
/// 按压：沿物体空间法线平移，并用高度场切向梯度重算法线。
/// depth -1 内凹，0 不动，+1 外扩。radius 为 0 时整网格；否则以世界空间 touchPosWs 为球心衰减。
/// 满幅度约 0.1 物体单位。
/// </summary>
IvyVertex_PressOut IvyVertex_Press(float3 posOs, float3 nrmOs, float depth, float3 touchPosWs, float radius)
{
    IvyVertex_PressOut pressOut;
    float3 nrm = IvyMatrix_SafeNormalize(nrmOs);
    pressOut.PosOs = posOs;
    pressOut.NrmOs = nrm;

    if (abs(depth) < 1e-5) return pressOut;

    float amp = depth * 0.1;
    float falloff = 1.0;
    float3 gradH = float3(0.0, 0.0, 0.0);
    if (radius > 1e-5)
    {
        float3 delta = posOs - IvyMatrix_PosWsToOs(touchPosWs);
        float dist = length(delta);
        float t = saturate(dist / radius);
        float s = t * t * (3.0 - 2.0 * t);
        float f = 1.0 - s;
        falloff = f * f;
        if (dist > 1e-8 && t > 0.0 && t < 1.0)
        {
            float dhdd = -12.0 * amp * f * t * (1.0 - t) / radius;
            gradH = dhdd * (delta / dist);
        }
    }
    if (falloff < 1e-5) return pressOut;

    pressOut.PosOs = posOs + nrm * amp * falloff;
    float3 gradTan = gradH - nrm * dot(gradH, nrm);
    pressOut.NrmOs = IvyMatrix_SafeNormalize(nrm - gradTan);
    return pressOut;
}

#endif