/****************************************
*
* 作者： 闪电黑客
* 日期： 2026/07/08
*
* 描述： Ion 坐标生成工具
*
* 功能：提供坐标生成工具函数
*
*/

#if DefPart(IonCoord, Tool)
#define Def_IonCoord_Tool

#define Link_IonMatrix
#include "../IonEdit.hlsl"

/// <summary>
/// 向量：指向目标
/// </summary>
/// <param name="origin">原点</param>
/// <param name="target">目标</param>
/// <returns>指向向量</returns>
float3 IonCoord_LookTo(float3 origin,float3 target)
{
    return normalize(target - origin);
}

/// <summary>
/// 天空盒效果
/// </summary>
/// <param name="CameraWs">世界相机</param>
/// <param name="PosWs">世界坐标</param>
/// <returns>天空盒效果后的向量</returns>
float3 IonCoord_SkyBox(float3 CameraWs,float3 PosWs)
{
    return IonCoord_LookTo(CameraWs, PosWs);
}

/// <summary>
/// 贴图固定到摄像机前方计算
/// </summary>
/// <param name="dirCameraWsToPosWs">世界相机到世界坐标的向量</param>
/// <returns>贴图固定到摄像机前方计算后的向量</returns>
float3 IonCoord_ViewSpace(float3 dirCameraWsToPosWs)
{
    float3 dir = IonMatrix_WorldToView(float4(dirCameraWsToPosWs, 0));
    dir.x = -dir.x;
    return dir;
}

/// <summary>
/// 镜面反射效果
/// </summary>
/// <param name="dirCameraWsToPosWs">世界相机到世界坐标的向量</param>
/// <param name="normalWs">世界法线</param>
/// <returns>镜面反射效果后的向量</returns>
float3 IonCoord_Reflect(float3 dirCameraWsToPosWs, float3 normalWs)
{
    return reflect(dirCameraWsToPosWs, normalWs);
}

/// <summary>
/// 法线做为世界坐标 - 跟随物体移动和旋转
/// </summary>
/// <param name="normalOs">物体法线</param>
/// <returns>法线做为世界坐标后的向量</returns>
float3 IonCoord_NormalAsWorld(float3 normalOs)
{
    normalOs.x = -normalOs.x;
    return normalOs;
}

/// <summary>
/// 法线转为世界坐标 - 跟随物体移动但不旋转
/// </summary>
/// <param name="normalOs">物体法线</param>
/// <returns>法线转为世界坐标后的向量</returns>
float3 IonCoord_NormalToWorld(float3 normalOs)
{
    float3 normalWs = IonMatrix_ObjectToWorldNormal(normalOs);
    normalWs.x = -normalWs.x;
    return normalWs;
}

/// <summary>
/// 法线转换为模型空间（仅翻转X轴）
/// </summary>
/// <param name="normalOs">物体法线</param>
/// <returns>转换后的物体法线</returns>
float3 IonCoord_NormalAsObject(float3 normalOs)
{
    normalOs.x = - normalOs.x;
    return normalOs;
}

/// <summary>
/// 物体表面坐标转法线为世界坐标 - 跟随物体移动但不旋转
/// </summary>
/// <param name="posOs"> 物体位置 </param>
/// <returns> 物体表面天空盒效果后的方向 </returns>
float3 IonCoord_PositionToNormalAsWorld(float3 posOs)
{
    float3 posWS = IonMatrix_ObjectToWorldNormal(posOs);
    posWS.x = -posWS.x;
    return posWS;
}

/// <summary>
/// 法线映射到物体表面 - 跟随物体移动和旋转
/// </summary>
/// <param name="normalOs">物体法线</param>
/// <param name="posOs">物体坐标</param>
/// <returns>法线映射到物体表面后的方向</returns>
float3 IonCoord_ObjectSpace(float3 normalOs, float3 posOs)
{
    float3 normalWs = IonMatrix_ObjectToWorldNormal(posOs);
    posOs = IonMatrix_WorldToObject(float4(normalWs, 0));
    float3 dir = normalOs + posOs;
    dir.x = -dir.x;
    return dir;
}


/// <summary>
/// 物体表面法线渲染 - 跟随相机角度旋转
/// </summary>
/// <param name="normalWs">世界法线</param>
/// <param name="posOs">物体坐标</param>
/// <returns>物体表面法线渲染后的方向</returns>
float3 IonCoord_ObjectView(float3 normalWs, float3 posOs)
{
    float3 normalVs = IonMatrix_WorldToView(float4(normalWs, 0));
    // 球形中心扩散映射渲染，填补平面法线映射的空白区域
    // 将物体的点位，转为不带位置的向量，进行扰动计算，使得平面法线不会指向一个位置。
    float3 posWs = IonMatrix_ObjectToWorldNormal(posOs);
    float3 posVs = IonMatrix_WorldToView(float4(posWs, 0));
    return normalVs + posVs;
}

#endif