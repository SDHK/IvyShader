/****************************************
*
* 作者： 闪电黑客
* 日期： 2026/07/08
*
* 描述： Ion 方向映射工具
*
* 功能：提供方向映射工具函数
*
*/

#if DefPart(IonDirMap, Tool)
#define Def_IonDirMap_Tool

#define Link_IonMatrix
#include "../IonEdit.hlsl"

/// <summary>
/// 向量：指向目标
/// </summary>
/// <param name="origin">原点</param>
/// <param name="target">目标</param>
/// <returns>指向向量</returns>
float3 IonDirMap_LookTo(float3 origin,float3 target)
{
    return (target - origin);
}

///// <summary>
///// 归一向量：指向目标
///// </summary>
///// <param name="origin">原点</param>
///// <param name="target">目标</param>
///// <returns>指向向量</returns>
//float3 IonDirMap_LookTo(float3 origin,float3 target)
//{
//    return normalize(target - origin);
//}

//========

/// <summary>
/// 天空盒效果
/// </summary>
/// <param name="camWs">世界相机</param>
/// <param name="posWs">世界坐标</param>
/// <returns>天空盒效果向量</returns>
float3 IonDirMap_SkyWs(float3 camWs,float3 posWs)
{
    return IonDirMap_LookTo(camWs, posWs);
}

/// <summary>
/// 天空盒效果，跟随物体旋转
/// </summary>
/// <param name="camOs">物体相机</param>
/// <param name="posOs">物体坐标</param>
/// <returns>天空盒效果向量</returns>
float3 IonDirMap_SkyOs(float3 camOs,float3 posOs)
{
    return IonDirMap_LookTo(camOs, posOs);
}



/// <summary>
/// 贴图固定到摄像机前方计算
/// </summary>
/// <param name="dirCamWsToPosWs">世界相机到世界坐标的向量</param>
/// <returns>摄像机前方向量</returns>
float3 IonDirMap_CamVs(float3 dirCamWsToPosWs)
{
    float3 dir = IonMatrix_DirWsToVs(dirCamWsToPosWs);
    dir.x = -dir.x;
    return dir;
}

/// <summary>
/// 镜面反射效果
/// </summary>
/// <param name="dirCamWsToPosWs">世界相机到世界坐标的向量</param>
/// <param name="nrmWs">世界法线</param>
/// <returns>镜面反射向量</returns>
float3 IonDirMap_Reflect(float3 dirCamWsToPosWs, float3 nrmWs)
{
    return reflect(dirCamWsToPosWs, nrmWs);
}

/// <summary>
/// 法线转为模型空间（仅翻转X轴） - 跟随物体移动和旋转
/// </summary>
/// <param name="nrmOs">物体法线</param>
/// <returns>物体法线</returns>
float3 IonDirMap_NrmOs(float3 nrmOs)
{
    nrmOs.x = - nrmOs.x;
    return nrmOs;
}

/// <summary>
/// 法线转为世界空间（仅翻转X轴) - 跟随物体移动但不旋转
/// </summary>
/// <param name="nrmWs">世界法线</param>
/// <returns>世界法线</returns>
float3 IonDirMap_NrmWs(float3 nrmWs)
{
    //带上旋转，但没有位置信息。所以映射看起来会是跟随物体移动，但不跟随旋转的效果。
    nrmWs.x = -nrmWs.x;
    return nrmWs;
}

/// <summary>
/// 法线转为观察空间 - 跟随相机角度旋转
/// </summary>
/// <param name="nrmWs">世界法线</param>
/// <returns>观察法线</returns>
float3 IonDirMap_NrmVs(float3 nrmWs)
{
    return IonMatrix_DirWsToVs(nrmWs);
}

/// <summary>
/// 法线映射到物体表面（加平面混合） - 跟随物体移动和旋转
/// </summary>
/// <param name="nrmOs">物体法线</param>
/// <param name="posOs">物体坐标</param>
/// <returns>物体混合向量</returns>
float3 IonDirMap_NrmPosOs(float3 nrmOs, float3 posOs)
{
    // 约束向量大小为1，去除物体尺寸改变的影响，让向量固定。
    posOs = normalize(posOs);
    float3  mixDirWs = nrmOs + posOs;
    mixDirWs.x = -mixDirWs.x;
    return mixDirWs;
}

/// <summary>
/// 法线映射到物体表面（加平面混合） - 跟随物体移动但不旋转 
/// </summary>
/// <param name="nrmWs">世界法线</param>
/// <param name="posOs">物体坐标</param>
/// <returns>世界混合向量</returns>
float3 IonDirMap_NrmPosWs(float3 nrmWs,float3 posOs)
{
    float3 dirWs = IonMatrix_DirOsToWs(posOs);
    // 约束向量大小为1，去除物体尺寸改变的影响，让向量固定。
    dirWs = normalize(dirWs);
    // 将法线和物体表面方向混合，得到最终的混合映射。
    float3  mixDirWs =  nrmWs + dirWs;
    mixDirWs.x = -mixDirWs.x;
    return mixDirWs;
}

/// <summary>
/// 法线映射到物体表面（加平面混合）- 跟随相机角度旋转
/// </summary>
/// <param name="nrmWs">世界法线</param>
/// <param name="posOs">物体坐标</param>
/// <returns>观察混合向量</returns>
float3 IonDirMap_NrmPosVs(float3 nrmWs, float3 posOs)
{
    float3 dirVs = IonMatrix_DirWsToVs(nrmWs);
    // 球形中心扩散映射渲染，填补平面法线映射的空白区域
    // 将物体的点位，转为不带位置的向量，进行扰动计算，使得平面法线不会指向一个位置。
    float3 dirPosWs = IonMatrix_DirOsToWs(posOs);
    float3 dirPosVs = IonMatrix_DirWsToVs(dirPosWs);
    dirPosVs = normalize(dirPosVs);
    return dirVs + dirPosVs;
}

#endif