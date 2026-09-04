/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/16 11:19
*
* 描述： Unity引擎核心方法实现集
* 
*/

#if DefPart(IvyBase, Bind)
#define Def_IvyBase_Bind

//===[定义Unity的方法宏]===

// 纹理坐标缩放偏移 float2  2d纹理 => float2 :TRANSFORM_TEX(uv,tex)
//#define Ivy_Transform_TEX(uv,texST)  ((uv.xy) * texST.xy + texST.zw)

#define IvyBase_GrabScreenPos(posCs)  (ComputeGrabScreenPos(posCs))
#endif