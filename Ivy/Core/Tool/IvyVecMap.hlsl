/****************************************
*
* 作者： 闪电黑客
* 日期： 2026/07/08
*
* 描述： Ivy 方向映射工具
*
* 功能：提供方向映射工具函数
*
*/

#if DefPart(IvyVecMap, Tool)
#define Def_IvyVecMap_Tool

#define Link_IvyMatrix
#include "../IvyEdit.hlsl"


/// <summary>
/// 向量：指向目标
/// </summary>
/// <param name="origin">原点</param>
/// <param name="target">目标</param>
/// <returns>指向向量</returns>
float3 IvyVecMap_LookTo(float3 origin,float3 target)
{
    return (target - origin);
}

/// <summary>
/// 天空盒效果
/// </summary>
/// <param name="camWs">世界相机</param>
/// <param name="posWs">世界坐标</param>
/// <returns>天空盒效果向量</returns>
float3 IvyVecMap_SkyWs(float3 camWs,float3 posWs)
{
    return IvyVecMap_LookTo(camWs, posWs);
}

/// <summary>
/// 天空盒效果，跟随物体旋转
/// </summary>
/// <param name="camOs">物体相机</param>
/// <param name="posOs">物体坐标</param>
/// <returns>天空盒效果向量</returns>
float3 IvyVecMap_SkyOs(float3 camOs,float3 posOs)
{
    return IvyVecMap_LookTo(camOs, posOs);
}



/// <summary>
/// 贴图固定到摄像机前方计算
/// </summary>
/// <param name="vecCamWsToPosWs">世界相机到世界坐标的向量</param>
/// <returns>摄像机前方向量</returns>
float3 IvyVecMap_CamVs(float3 vecCamWsToPosWs)
{
    float3 vec = IvyMatrix_VecWsToVs(vecCamWsToPosWs);
    vec.x = - vec.x;
    return vec;
}

/// <summary>
/// 镜面反射效果
/// </summary>
/// <param name="vecCamWsToPosWs">世界相机到世界坐标的向量</param>
/// <param name="nrmWs">世界法线</param>
/// <returns>镜面反射向量</returns>
float3 IvyVecMap_Reflect(float3 vecCamWsToPosWs, float3 nrmWs)
{
    return reflect(vecCamWsToPosWs, nrmWs);
}

/// <summary>
/// 法线转为模型空间（仅翻转X轴） - 跟随物体移动和旋转
/// </summary>
/// <param name="nrmOs">物体法线</param>
/// <returns>物体法线</returns>
float3 IvyVecMap_NrmOs(float3 nrmOs)
{
    nrmOs.x = - nrmOs.x;
    return nrmOs;
}

/// <summary>
/// 法线转为世界空间（仅翻转X轴) - 跟随物体移动但不旋转
/// </summary>
/// <param name="nrmWs">世界法线</param>
/// <returns>世界法线</returns>
float3 IvyVecMap_NrmWs(float3 nrmWs)
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
float3 IvyVecMap_NrmVs(float3 nrmWs)
{
    return IvyMatrix_VecWsToVs(nrmWs);
}

/// <summary>
/// 法线映射到物体表面（加平面混合） - 跟随物体移动和旋转
/// </summary>
/// <param name="nrmOs">物体法线</param>
/// <param name="posOs">物体坐标</param>
/// <returns>物体混合向量</returns>
float3 IvyVecMap_NrmPosOs(float3 nrmOs, float3 posOs)
{
    // 约束向量大小为1，去除物体尺寸改变的影响，让向量固定。
    posOs = normalize(posOs);
    float3  mixVecWs = nrmOs + posOs;
    mixVecWs.x = -mixVecWs.x;
    return mixVecWs;
}

/// <summary>
/// 法线映射到物体表面（加平面混合） - 跟随物体移动但不旋转 
/// </summary>
/// <param name="nrmWs">世界法线</param>
/// <param name="posOs">物体坐标</param>
/// <returns>世界混合向量</returns>
float3 IvyVecMap_NrmPosWs(float3 nrmWs,float3 posOs)
{
    float3 vecWs = IvyMatrix_VecOsToWs(posOs);
    // 约束向量大小为1，去除物体尺寸改变的影响，让向量固定。
    vecWs = normalize(vecWs);
    // 将法线和物体表面方向混合，得到最终的混合映射。
    float3  mixVecWs =  nrmWs + vecWs;
    mixVecWs.x = -mixVecWs.x;
    return mixVecWs;
}

/// <summary>
/// 法线映射到物体表面（加平面混合）- 跟随相机角度旋转
/// </summary>
/// <param name="nrmWs">世界法线</param>
/// <param name="posOs">物体坐标</param>
/// <returns>观察混合向量</returns>
float3 IvyVecMap_NrmPosVs(float3 nrmWs, float3 posOs)
{
    float3 vecVs = IvyMatrix_VecWsToVs(nrmWs);
    // 球形中心扩散映射渲染，填补平面法线映射的空白区域
    // 将物体的点位，转为不带位置的向量，进行扰动计算，使得平面法线不会指向一个位置。
    float3 vecPosWs = IvyMatrix_VecOsToWs(posOs);
    float3 vecPosVs = IvyMatrix_VecWsToVs(vecPosWs);
    vecPosVs = normalize(vecPosVs);
    return vecVs + vecPosVs;
}


/// <summary>
/// 将世界空间向量转到以 dirFrontWs 为前方的 look-at 坐标系
/// （世界上为参考，无镜头 roll；MatCap 时 dirFrontWs 传点→相机）
/// </summary>
/// <param name="vecWs">世界空间向量（法线等；调用方宜先归一化）</param>
/// <param name="dirFrontWs">新坐标系前方（建议归一化，建正交基需要）</param>
/// <returns>look-at 空间向量，xy 可直接做 MatCap</returns>
float3 IvyVecMap_VecLookAt(float3 vecWs, float3 dirFrontWs)
{
    float3 v = vecWs;
    float3 front = normalize(dirFrontWs);

    float3 up = float3(0.0, 1.0, 0.0);
    float3 right = cross(up, front);
    float rightLen = length(right);
    // 前方几乎平行世界 up（正上/正下）时换一个 up
    if (rightLen < 1e-5)
    {
        up = float3(0.0, 0.0, 1.0);
        right = cross(up, front);
        rightLen = length(right);
    }
    right /= rightLen;
    float3 upOrtho = cross(front, right);

    return float3(
        dot(v, right),
        dot(v, upOrtho),
        dot(v, front)
    );
}

/// <summary>
/// 用欧拉角旋转世界空间向量
/// 约定：R = Rz * Ry * Rx（先 X 后 Y 后 Z）
/// </summary>
/// <param name="vecWs">被旋转的向量</param>
/// <param name="eulerAngle">欧拉角（角度°），xyz = 绕 X/Y/Z 的转角</param>
float3 IvyVecMap_VecRotateEuler(float3 vecWs, float3 eulerAngle)
{
    float3 eulerRad = -eulerAngle * (3.14159265 / 180.0);
    float cx = cos(eulerRad.x), sx = sin(eulerRad.x);
    float cy = cos(eulerRad.y), sy = sin(eulerRad.y);
    float cz = cos(eulerRad.z), sz = sin(eulerRad.z);


    // R = Rz * Ry * Rx（先 X 后 Y 后 Z）
    float3x3 Rx = float3x3(
        1, 0, 0,
        0, cx, -sx,
        0, sx,  cx
    );
    float3x3 Ry = float3x3(
         cy, 0, sy,
          0, 1, 0,
        -sy, 0, cy
    );
    float3x3 Rz = float3x3(
        cz, -sz, 0,
        sz,  cz, 0,
         0,   0, 1
    );

    float3x3 R = mul(Rz, mul(Ry, Rx));
    return mul(R, vecWs);
}

#endif