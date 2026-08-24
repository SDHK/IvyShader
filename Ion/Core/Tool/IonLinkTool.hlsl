/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/16
*
* 描述： Ion 工具函数统一入口
* 
* 功能：统一包含所有工具函数文件
*       根据 Link_IonXXX 宏控制是否链接
*
* 注意：文件包含顺序考虑了依赖关系
*       - IonHash 是基础库，先包含
*       - IonNoise 依赖 IonHash，后包含
*
*/

//===[基础工具]===
#if Link(IonHash)
#include "IonHash.hlsl"      // 哈希函数（基础库，其他库可能依赖）
#endif

//===[数学工具]===
#if Link(IonMath)
#include "IonMath.hlsl"      // 数学函数
#endif
#if Link(IonMatrix)
#include "IonMatrix.hlsl"   // 矩阵计算
#endif

//===[高级工具]===

#if Link(IonNoise)
#include "IonNoise.hlsl"     // 噪声函数（依赖 IonHash）
#endif
#if Link(IonDistort)
#include "IonDistort.hlsl"   // 扭曲函数
#endif
#if Link(IonVertex)
#include "IonVertex.hlsl"   // 顶点工具
#endif
#if Link(IonDirMap)
#include "IonDirMap.hlsl"     // 坐标扭曲工具
#endif
#if Link(IonField)
#include "IonField.hlsl"     // 采样场工具
#endif


#if Link(IonRamp)
#include "IonRamp.hlsl"     // 渐变计算工具（Lambert 等）
#endif

#if Link(IonEffect)
#include "IonEffect.hlsl"     // 特效工具
#endif


