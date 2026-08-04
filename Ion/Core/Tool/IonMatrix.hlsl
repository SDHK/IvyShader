/****************************************

* 作者： 闪电黑客
* 日期： 2025/12/9 19:53

* 描述： 矩阵计算集

* 缩写说明：
* - Os (Object Space)：物体空间，顶点相对于物体自身的坐标系
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
*    作用：将顶点从物体本地坐标系转换到世界坐标系
*    包含：坐标、旋转、缩放
* Ws → Vs（世界空间 → 观察空间）
*    使用：View Matrix (V)
*    作用：将顶点从世界坐标系转换到相机坐标系
*    本质：相机变换（Camera Transform）
* Vs → Cs（观察空间 → 裁剪空间）
*    使用：Projection Matrix (P)
*    作用：将顶点从观察空间投影到裁剪空间
*    功能：透视/正交投影、视锥裁剪
* 
* 附加说明：
* Obj -> 是模型位置，例如ObjWs
* Cam -> 是相机位置，例如CamWs
* Org -> 是世界原点位置，例如OrgWs

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


//===[Normal (Nrm) 转换]===

/// <summary>
/// 转换为法线：从物体空间转到世界空间（法线专用，使用逆转置矩阵，应对转世界阶段的模型非均匀缩放法线矫正）
/// </summary>
/// <param name="nrmOs">物体法线</param>
/// <returns>世界法线</returns>
float3 IonMatrix_NrmOsToWs(float3 nrmOs)
{
    // 使用物体矩阵的逆转置来转换法线到世界空间
    // 注意：IonParam_Matrix_IT_MV 会将法线转换到观察空间，而不是世界空间
    return normalize(mul((float3x3)IonParam_Matrix_IT_M, nrmOs)); // (M⁻¹)ᵀ × nrmOs
}


/// <summary>
/// 转换为法线：从世界空间转到物体空间（法线专用，使用逆转置矩阵，应对转世界阶段的模型非均匀缩放法线矫正）
/// </summary>
/// <param name="nrmWs">世界法线</param>
/// <returns>物体法线</returns>
float3 IonMatrix_NrmWsToOs(float3 nrmWs)
{
    return normalize(mul(transpose((float3x3)IonParam_Matrix_M), nrmWs)).xyz;// Mᵀ × nrmWs
}

//===[Object Space (Os) 转换]===

/// <summary>
/// 转换为坐标：从物体空间转到世界空间（Object Space -> World Space） 
/// </summary>
/// <param name="posOs">物体坐标</param>
/// <returns>世界坐标</returns>
float3 IonMatrix_PosOsToWs(float3 posOs)
{
    return mul(IonParam_Matrix_M, float4(posOs, 1.0)).xyz;
}

/// <summary>
/// 转换为向量：从物体空间转到世界空间（Object Space -> World Space）
/// </summary>
/// <param name="posOs">物体坐标</param>
/// <returns>世界向量</returns>
float3 IonMatrix_DirOsToWs(float3 posOs)
{
    return mul((float3x3)IonParam_Matrix_M, posOs);
}


/// <summary>
/// 转换为坐标：从物体空间转到观察空间（Object Space -> Camera Space） 
/// </summary>
/// <param name="posOs">物体坐标</param>
/// <returns>观察坐标</returns>
float3 IonMatrix_PosOsToVs(float3 posOs)
{
    return mul(IonParam_Matrix_MV, float4(posOs, 1.0)).xyz;
}

/// <summary>
/// 转换为向量：从物体空间转到观察空间（Object Space -> Camera Space）
/// </summary>
/// <param name="posOs">物体坐标</param>
/// <returns>观察向量</returns>
float3 IonMatrix_DirOsToVs(float3 posOs)
{
    return mul((float3x3)IonParam_Matrix_MV, posOs);
}

/// <summary>
/// 转换为坐标：从物体空间转到裁剪空间（Object Space -> Clip Space） 
/// </summary>
/// <param name="posOs">物体坐标</param>
/// <returns>裁剪坐标</returns>
float4 IonMatrix_PosOsToCs(float3 posOs)
{
    return mul(IonParam_Matrix_MVP, float4(posOs, 1.0));
}


//===[World Space (Ws) 转换]===

/// <summary>
/// 转换为坐标：从世界空间转到物体空间（World Space -> Object Space）
/// </summary>
/// <param name="posWs">世界坐标</param>
/// <returns>物体坐标</returns>
float3 IonMatrix_PosWsToOs(float3 posWs)
{
    return mul(IonParam_Matrix_I_M,float4(posWs, 1.0)).xyz;
}
/// <summary>
/// 转换为向量：从世界空间转到物体空间（World Space -> Object Space）
/// </summary>
/// <param name="posWs">世界坐标</param>
/// <returns>物体向量</returns>
float3 IonMatrix_DirWsToOs(float3 posWs)
{
    return mul((float3x3)IonParam_Matrix_I_M, posWs);
}

/// <summary>
/// 转换为坐标：从世界空间转到观察空间（World Space -> View Space）
/// </summary>
/// <param name="posWs">世界坐标</param>
/// <returns>观察坐标</returns>
float3 IonMatrix_PosWsToVs(float3 posWs)
{
    return mul(IonParam_Matrix_V, float4(posWs, 1.0)).xyz;
}
/// <summary>
/// 转换为向量：从世界空间转到观察空间（World Space -> View Space）
/// </summary>
/// <param name="posWs">世界坐标</param>
/// <returns>观察向量</returns>
float3 IonMatrix_DirWsToVs(float3 posWs)
{
    return mul((float3x3)IonParam_Matrix_V, posWs);
}

/// <summary>
/// 转换为坐标：从世界空间转到裁剪空间（World Space -> Clip Space）
/// </summary>
/// <param name="posWs">世界坐标</param>
/// <returns>裁剪坐标</returns>
float4 IonMatrix_PosWsToCs(float3 posWs)
{
    return mul(IonParam_Matrix_VP, float4(posWs, 1.0));
}

//===[View Space (Vs) 转换]===

/// <summary>
/// 转换为坐标：从观察空间转到物体空间（View Space -> Object Space）
/// </summary>
/// <param name="posVs">观察坐标</param>
/// <returns>物体坐标</returns>
float3 IonMatrix_PosVsToOs(float3 posVs)
{
    return mul(IonParam_Matrix_I_MV, float4(posVs, 1.0)).xyz;
}
/// <summary>
/// 转换为向量：从观察空间转到物体空间（View Space -> Object Space）
/// </summary>
/// <param name="posVs">观察坐标</param>
/// <returns>物体向量</returns>
float3 IonMatrix_DirVsToOs(float3 posVs)
{
    return mul((float3x3)IonParam_Matrix_I_MV, posVs);
}

/// <summary>
/// 转换为坐标：从观察空间转到世界空间（View Space -> World Space）
/// </summary>
/// <param name="posVs">观察坐标</param>
/// <returns>世界坐标</returns>
float3 IonMatrix_PosVsToWs(float3 posVs)
{
    return mul(IonParam_Matrix_I_V, float4(posVs, 1.0)).xyz;
}
/// <summary>
/// 转换为向量：从观察空间转到世界空间（View Space -> World Space）
/// </summary>
/// <param name="posVs">观察坐标</param>
/// <returns>世界向量</returns>
float3 IonMatrix_DirVsToWs(float3 posVs)
{
    return mul((float3x3)IonParam_Matrix_I_V, posVs);
}

/// <summary>
/// 转换为坐标：从观察空间转到裁剪空间（View Space -> Clip Space）
/// </summary>
/// <param name="posVs">观察坐标</param>
/// <returns>裁剪坐标</returns>
float4 IonMatrix_PosVsToCs(float3 posVs)
{
    return mul(IonParam_Matrix_P, float4(posVs, 1.0));
}


//===[Clip Space (Cs) 转换]===

/// <summary>
/// 转换为坐标：从裁剪空间转到物体空间（Clip Space -> Object Space）
/// </summary>
/// <param name="posCs">裁剪坐标</param>
/// <returns>物体坐标</returns>
float3 IonMatrix_PosCsToOs(float4 posCs)
{
    float4 posOs = mul(IonParam_Matrix_I_MVP, posCs);
    return posOs.xyz / posOs.w;
}

/// <summary>
/// 转换为坐标：从裁剪空间转到世界空间（Clip Space -> World Space）
/// </summary>
/// <param name="posCs">裁剪坐标</param>
/// <returns>世界坐标</returns>
float3 IonMatrix_PosCsToWs(float4 posCs)
{
    float4 posWs = mul(IonParam_Matrix_I_VP, posCs);
    return posWs.xyz / posWs.w;
}

/// <summary>
/// 转换为坐标：从裁剪空间转到观察空间（Clip Space -> View Space）
/// </summary>
/// <param name="posCs">裁剪坐标</param>
/// <returns>观察坐标</returns>
float3 IonMatrix_PosCsToVs(float4 posCs)
{
    float4 posVs = mul(IonParam_Matrix_I_P, posCs);
    return posVs.xyz / posVs.w;
}

#endif 