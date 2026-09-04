/****************************************

* 作者： 闪电黑客
* 日期： 2025/12/10 18:29

* 描述： Ivy 顶点工具函数 

*/
#if DefPart(IvyVertex, Tool) 
#define Def_IvyVertex_Tool

#define Link_IvyMatrix
#include "../IvyEdit.hlsl"


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

// 触摸变形
// float4 positionOS: 输入的模型空间位置
// float3 normalOS: 输入的模型空间法线
// float2 uv: 输入的UV坐标
// float3 touchPosWS: 触摸点的世界空间位置
// float touchStrength: 触摸强度
// float touchRadius: 触摸半径
// float maxDepth: 最大深度
// sampler2D mask: 遮罩纹理
// float3 return: 变形后的模型空间位置 
float3 IvyVertex_Displace(float4 positionOS, float3 normalOS, float2 uv,
    float3 touchPosWS, float touchStrength, float touchRadius,
    float maxDepth, sampler2D mask)
{
    // 把触摸点从世界空间转到模型空间，统一在模型空间计算距离
    float3 touchPosOS = IvyMatrix_PosWsToOs(float4(touchPosWS, 1.0)).xyz;
    float dist = distance(positionOS.xyz, touchPosOS);
    // 平滑衰减：中心最强，边缘归零
    float falloff = 1.0 - smoothstep(0.0, touchRadius, dist);
    falloff *= falloff; // 更柔软的曲线
    // 遮罩：白=柔软可压，黑=刚硬不动
    float softness = tex2Dlod(mask, float4(uv, 0, 0)).r;
    // 沿法线内陷
    float depth = touchStrength * falloff * softness * maxDepth;
    return positionOS.xyz - normalOS * depth;
}


#endif