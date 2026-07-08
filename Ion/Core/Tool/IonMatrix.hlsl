/****************************************

* 作者： 闪电黑客
* 日期： 2025/12/9 19:53

* 描述： 矩阵计算集

* 缩写说明：
* - Os (Object Space)：物体空间，顶点相对于模型自身的坐标系
* - Ws (World Space)：世界空间，顶点相对于整个场景的坐标系
* - Vs (View Space)：观察空间，顶点相对于摄像机的坐标系
* - Cs (Clip Space)：裁剪空间，用于最终投影到屏幕的坐标系
* 
* 空间转换流程：Os --[M]--> Ws --[V]--> Vs --[P]--> Cs
* 代码实现：
*   float4 positionOs = float4(vertexPosition, 1.0);           // Os
*   float4 positionWs = mul(IonParam_Matrix_M, positionOs);       // Os → Ws (M)
*   float4 positionVs = mul(IonParam_Matrix_V, positionWs);       // Ws → Vs (V)
*   float4 positionCs = mul(IonParam_Matrix_P, positionVs);       // Vs → Cs (P)
*
* 详细说明：
* Os → Ws（物体空间 → 世界空间）
*   使用：Model Matrix (M)
*    作用：将顶点从模型本地坐标系转换到世界坐标系
*    包含：位置、旋转、缩放
* Ws → Vs（世界空间 → 观察空间）
*    使用：View Matrix (V)
*    作用：将顶点从世界坐标系转换到相机坐标系
*    本质：相机变换（Camera Transform）
* Vs → Cs（观察空间 → 裁剪空间）
*    使用：Projection Matrix (P)
*    作用：将顶点从观察空间投影到裁剪空间
*    功能：透视/正交投影、视锥裁剪

*/

#if DefPart(IonMatrix, Tool) 
#define Def_IonMatrix_Tool

#define Link_IonBase
#include "../IonEdit.hlsl"


// 归一化一个三维向量，避免除以零
// float3 inVec: 输入的三维向量
// float3 return: 归一化后的三维向量
float3 IonMatrix_SafeNormalize(float3 inVec)
{
    float dp3 = max(IonConst_Float_Min, dot(inVec, inVec));
    return inVec * rsqrt(dp3);
}

//===[Object Space (Os) 转换]===

// 转换坐标系：从模型空间转到裁剪空间（Clip Space）。顶点着色器常用，用于输出 PositionCS
// float4 pos: 输入的模型空间位置
// float4 return: 裁剪空间位置
float4 IonMatrix_ObjectToClip(float4 pos)
{
    return mul(IonParam_Matrix_MVP, pos);
}

// 转换坐标系：从模型空间转到观察空间（View Space / Camera Space）
// float4 pos: 输入的模型空间位置
// float4 return: 观察空间位置
float4 IonMatrix_ObjectToView(float4 pos)
{
    return mul(IonParam_Matrix_MV, pos);
}

// 转换坐标系：从模型空间转到世界空间
// float4 pos: 输入的模型空间位置
// float4 return: 世界空间位置
float4 IonMatrix_ObjectToWorld(float4 pos)
{
    return mul(IonParam_Matrix_M, pos);
}

// 转换坐标系：从模型空间转到世界空间（float3版本，常用于方向向量）
// 注意：对于法线向量，请使用 IonMatrix_ObjectToWorldNormal
// 如需归一化，请手动调用 IonMatrix_SafeNormalize()
// float3 pos: 输入的模型空间位置
// float3 return: 世界空间位置
float3 IonMatrix_ObjectToWorld(float3 pos)
{
    return mul(IonParam_Matrix_M, float4(pos, 1.0)).xyz;
}

// 转换坐标系：从模型空间转到世界空间（法线专用，使用逆转置矩阵）
// 用于法线向量转换，正确处理非均匀缩放
// float3 normal: 输入的模型空间法线
// float3 return: 世界空间法线
float3 IonMatrix_ObjectToWorldNormal(float3 normal)
{
    // 使用模型矩阵的逆转置来转换法线到世界空间
    // 注意：IonParam_Matrix_IT_MV 会将法线转换到观察空间，而不是世界空间
    return normalize(mul((float3x3)IonParam_Matrix_IT_M, normal));
}

//===[World Space (Ws) 转换]===

// 转换坐标系：从世界空间转到裁剪空间
// float4 pos: 输入的世界空间位置
// float4 return: 裁剪空间位置
float4 IonMatrix_WorldToClip(float4 pos)
{
    return mul(IonParam_Matrix_VP, pos);
}

// 转换坐标系：从世界空间转到观察空间
// float4 pos: 输入的世界空间位置
// float4 return: 观察空间位置
float4 IonMatrix_WorldToView(float4 pos)
{
    return mul(IonParam_Matrix_V, pos);
}

// 转换坐标系：从世界空间转到模型空间
// float4 pos: 输入的世界空间位置
// float4 return: 模型空间位置
float4 IonMatrix_WorldToObject(float4 pos)
{
    return mul(IonParam_Matrix_I_M, pos);
}

// 转换坐标系：从世界空间转到模型空间（float3版本，常用于方向向量）
// 注意：对于法线向量，请使用 IonMatrix_WorldToObjectNormal
// 如需归一化，请手动调用 IonMatrix_SafeNormalize()
// float3 pos: 输入的世界空间位置
// float3 return: 模型空间位置
float3 IonMatrix_WorldToObject(float3 pos)
{
    return mul(IonParam_Matrix_I_M, float4(pos, 1.0)).xyz;
}

// 转换坐标系：从世界空间转到模型空间（法线专用）
// 用于法线向量转换，正确处理非均匀缩放
// float3 normal: 输入的世界空间法线
// float3 return: 模型空间法线
float3 IonMatrix_WorldToObjectNormal(float3 normal)
{
    return normalize(mul((float3x3)IonParam_Matrix_I_M, normal));
}

//===[View Space (Vs) 转换]===

// 转换坐标系：从观察空间转到裁剪空间
// float4 pos: 输入的观察空间位置
// float4 return: 裁剪空间位置
float4 IonMatrix_ViewToClip(float4 pos)
{
    return mul(IonParam_Matrix_P, pos);
}

// 转换坐标系：从观察空间转到世界空间
// float4 pos: 输入的观察空间位置
// float4 return: 世界空间位置
float4 IonMatrix_ViewToWorld(float4 pos)
{
    return mul(IonParam_Matrix_I_V, pos);
}

// 转换坐标系：从观察空间转到模型空间
// float4 pos: 输入的观察空间位置
// float4 return: 模型空间位置
float4 IonMatrix_ViewToObject(float4 pos)
{
    return mul(IonParam_Matrix_I_MV, pos);
}

//===[Clip Space (Cs) 转换]===

// 转换坐标系：从裁剪空间转到模型空间
// float4 pos: 输入的裁剪空间位置
// float4 return: 模型空间位置
float4 IonMatrix_ClipToObject(float4 pos)
{
    return mul(IonParam_Matrix_I_MVP, pos);
}

// 转换坐标系：从裁剪空间转到世界空间
// float4 pos: 输入的裁剪空间位置
// float4 return: 世界空间位置
float4 IonMatrix_ClipToWorld(float4 pos)
{
    return mul(IonParam_Matrix_I_VP, pos);
}

// 转换坐标系：从裁剪空间转到观察空间
// float4 pos: 输入的裁剪空间位置
// float4 return: 观察空间位置
float4 IonMatrix_ClipToView(float4 pos)
{
    return mul(IonParam_Matrix_I_P, pos);
}

#endif 