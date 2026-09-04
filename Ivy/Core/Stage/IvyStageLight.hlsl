/****************************************
*
* 作者： 闪电黑客
* 日期： 2026/09/04 19:28
*
* 描述： 光照阶段集合
*
*/

#if Def(IvyStageLight)
#define Def_IvyStageLight

#include "../IvyEdit.hlsl"


struct IvyStageLight_DiffuseIn
{
    IvyStruct_Light Light;

    /// <summary>
    /// 光照强度最小值
    /// </summary>
    half LightMin;
    /// <summary>
    /// 光照强度最大值
    /// </summary>
    half LightMax;
}

struct IvyStageLight_DiffuseOut
{
    half3 LightRgb;
}

IvyStageLight_DiffuseOut IvyStageLight_Diffuse(IvyStepLight_DiffuseIn In)
{
    IvyStageLight_DiffuseOut Out;


}


#endif // Def(IvyStageLight)
