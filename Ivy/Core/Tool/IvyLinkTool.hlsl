/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/16
*
* 描述： Ivy 工具函数统一入口
* 
* 功能：统一包含所有工具函数文件
*       根据 Link_IvyXXX 宏控制是否链接
*
* 注意：文件包含顺序考虑了依赖关系
*       - IvyHash 是基础库，先包含
*       - IvyNoise 依赖 IvyHash，后包含
*
*/

//===[基础工具]===
#if Link(IvyHash)
#include "IvyHash.hlsl"      // 哈希函数（基础库，其他库可能依赖）
#endif

//===[数学工具]===
#if Link(IvyMath)
#include "IvyMath.hlsl"      // 数学函数
#endif
#if Link(IvyMatrix)
#include "IvyMatrix.hlsl"   // 矩阵计算
#endif
//===[高级工具]===

#if Link(IvyNoise)
#include "IvyNoise.hlsl"     // 噪声函数（依赖 IvyHash）
#endif
#if Link(IvyUv)
#include "IvyUv.hlsl"   // UV 工具
#endif
#if Link(IvyVertex)
#include "IvyVertex.hlsl"   // 顶点工具
#endif
#if Link(IvyVecMap)
#include "IvyVecMap.hlsl"     // 坐标扭曲工具
#endif
#if Link(IvyField)
#include "IvyField.hlsl"     // 采样场工具
#endif


#if Link(IvyRamp)
#include "IvyRamp.hlsl"     // 渐变计算工具（Lambert 等）
#endif

#if Link(IvyEffect3D)
#include "IvyEffect3D.hlsl"     // 特效工具
#endif


