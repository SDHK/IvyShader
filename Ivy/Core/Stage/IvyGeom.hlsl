/****************************************
*
* 作者： 闪电黑客
* 日期： 2026/09/04 19:28
*
* 描述： 光照阶段集合
*
*/

#if DefPart(IvyGeom,Stage)
#define Def_IvyGeom_Stage

#include "../Tool/IvyMatrix.hlsl"
#include "../Tool/IvyVecMap.hlsl"

struct IvyGeom_BuildIn
{
    float2 Uv;
    float3 PosOs;
    float3 NrmOs;
    float3 CamWs;
    bool   IsFront;
    float4 OrthoParams;

};

struct IvyGeom_BuildOut
{
    float2 Uv;

    float3 PosOs;
    float3 PosWs;
    float3 PosVs;
    float4 PosCs;

    float3 NrmOs;
    float3 NrmWs;
    float3 NrmVs;

    float3 CamOs;
    float3 CamWs;
    float3 CamVs;
  
    bool IsOrtho;
    bool IsFront;


    float3 NrmOsFront;
    float3 NrmWsFront;
    float3 NrmVsFront;

};

IvyGeom_BuildOut IvyGeom_Build(IvyGeom_BuildIn dataIn)
{
    IvyGeom_BuildOut dataOut;

    dataOut.Uv = dataIn.Uv;
    dataOut.NrmOs = dataIn.NrmOs;
    dataOut.NrmWs = IvyMatrix_NrmOsToWs(dataIn.NrmOs);
    dataOut.NrmVs = IvyMatrix_NrmOsToVs(dataIn.NrmOs);

    dataOut.PosOs = dataIn.PosOs;
    dataOut.PosWs = IvyMatrix_PosOsToWs(dataIn.PosOs);
    dataOut.PosVs = IvyMatrix_PosOsToVs(dataIn.PosOs);
    dataOut.PosCs = IvyMatrix_PosOsToCs(dataIn.PosOs);

    dataOut.CamOs = IvyMatrix_PosWsToOs(dataIn.CamWs);
    dataOut.CamWs = dataIn.CamWs;
    dataOut.CamVs = IvyMatrix_PosWsToVs(dataIn.CamWs);

    dataOut.IsOrtho = dataIn.OrthoParams.w > 0.5;

    dataOut.IsFront = dataIn.IsFront;
    if(dataIn.IsFront)
    {
        dataOut.NrmOsFront = dataOut.NrmOs;
        dataOut.NrmWsFront = dataOut.NrmWs;
        dataOut.NrmVsFront = dataOut.NrmVs;
    }
    else
    {
        dataOut.NrmOsFront = -dataOut.NrmOs;
        dataOut.NrmWsFront = -dataOut.NrmWs;
        dataOut.NrmVsFront = -dataOut.NrmVs;
    }
    return dataOut;
}


struct IvyGeom_VecMapOut
{
    float3 VecPosToCamOs;
    float3 VecCamToPosOs;
    float3 VecPosToCamWs;
    float3 VecCamToPosWs;

    float3 VecPosToCamOsRaw;
    float3 VecCamToPosOsRaw;
    float3 VecPosToCamWsRaw;
    float3 VecCamToPosWsRaw;

    /// <summary>
    /// 摄像机前方向量（观察空间） 
    /// </summary>
    float3 VecMapCamVs;
    /// <summary>
    /// 镜面反射向量（世界空间） 
    /// </summary>
    float3 VecMapReflect;
    /// <summary>
    /// 镜面反射向量（物体空间） 
    /// </summary>
    float3 VecMapReflectOs;
    /// <summary>
    /// 法线转为模型空间（仅翻转X轴） - 跟随物体移动和旋转 
    /// </summary>
    float3 VecMapNrmOs;
    /// <summary>
    /// 法线转为世界空间（仅翻转X轴) - 跟随物体移动但不旋转 
    /// </summary>
    float3 VecMapNrmWs;
    /// <summary>
    /// 法线转为观察空间 - 跟随相机角度旋转 
    /// </summary>
    float3 VecMapNrmVs;
    /// <summary>
    /// 法线+位置转为模型空间（仅翻转X轴） - 跟随物体移动和旋转 
    /// </summary>
    float3 VecMapNrmPosOs;
    /// <summary>
    /// 法线+位置转为世界空间（仅翻转X轴) - 跟随物体移动但不旋转 
    /// </summary>
    float3 VecMapNrmPosWs;
    /// <summary>
    /// 法线+位置转为观察空间 - 跟随相机角度旋转 
    /// </summary>
    float3 VecMapNrmPosVs;
    /// <summary>
    /// 旋转矩阵：将世界法线旋转到摄像机前方的旋转矩阵 
    /// </summary>
    float3 VecMapRotateFrame;
};

IvyGeom_VecMapOut IvyGeom_VecMap(IvyGeom_BuildOut dataIn)
{
    IvyGeom_VecMapOut dataOut;

    if (dataIn.IsOrtho)
    {
        dataOut.VecPosToCamWs = IvyParam_Matrix_V[2].xyz;
    }
    else
    {
        dataOut.VecPosToCamWs = dataIn.CamWs - dataIn.PosWs;
    }

    dataOut.VecCamToPosWs = -dataOut.VecPosToCamWs;
    dataOut.VecPosToCamOs = IvyMatrix_VecWsToOs(dataOut.VecPosToCamWs);
    dataOut.VecCamToPosOs = -dataOut.VecPosToCamOs;

    dataOut.VecPosToCamOsRaw = dataIn.CamOs - dataIn.PosOs;
    dataOut.VecCamToPosOsRaw = -dataOut.VecPosToCamOsRaw;
    dataOut.VecPosToCamWsRaw = dataIn.CamWs - dataIn.PosWs;
    dataOut.VecCamToPosWsRaw = -dataOut.VecPosToCamWsRaw;

    dataOut.VecMapCamVs    = IvyVecMap_CamVs(dataOut.VecCamToPosWs);
    dataOut.VecMapReflect  = IvyVecMap_Reflect(dataOut.VecCamToPosWs, dataIn.NrmWsFront);
    dataOut.VecMapReflectOs = IvyVecMap_Reflect(dataOut.VecCamToPosOs, dataIn.NrmOsFront);
    dataOut.VecMapNrmOs    = IvyVecMap_NrmOs(dataIn.NrmOs);
    dataOut.VecMapNrmWs    = IvyVecMap_NrmWs(dataIn.NrmWs);
    dataOut.VecMapNrmVs    = IvyVecMap_NrmVs(dataIn.NrmVs);
    dataOut.VecMapNrmPosOs = IvyVecMap_NrmPosOs(dataIn.NrmOs, dataIn.PosOs);
    dataOut.VecMapNrmPosWs = IvyVecMap_NrmPosWs(dataIn.NrmWs, dataIn.PosOs);
    dataOut.VecMapNrmPosVs = IvyVecMap_NrmPosVs(dataIn.NrmVs, dataIn.PosOs);

    dataOut.VecMapRotateFrame = IvyVecMap_RotateFrame(dataIn.NrmWsFront, dataOut.VecPosToCamWs);
    return dataOut;
}

#endif// DefPart(IvyGeom,Stage)