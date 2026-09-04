/****************************************
*
* 作者： 闪电黑客
* 日期： 2026/09/04 19:28
*
* 描述： 光照阶段集合
*
*/

#if Def(IonStageLight)
#define Def_IonStageLight

#include "../IonEdit.hlsl"


struct IonStageLight_DiffuseIn
{
    IonStruct_Light Light;

    /// <summary>
    /// 光照强度最小值
    /// </summary>
    half LightMin;
    /// <summary>
    /// 光照强度最大值
    /// </summary>
    half LightMax;
}

struct IonStageLight_DiffuseOut
{
    half3 LightRgb;
}

IonStageLight_DiffuseOut IonStageLight_Diffuse(IonStepLight_DiffuseIn In)
{
    IonStageLight_DiffuseOut Out;


}


#endif // Def(IonStageLight)
