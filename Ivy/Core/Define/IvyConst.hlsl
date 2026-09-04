/****************************************

* 作者： 闪电黑客
* 日期： 2025/12/15 10:58

* 描述： 常量定义集

*/


#ifndef Def_IvyConst
#define Def_IvyConst

//=== [零值定义] ===

//浮点数零值
#define IvyConst_Float_Zero 0.0
// 各种向量零值
#define IvyConst_Float2_Zero float2(0.0,0.0)
#define IvyConst_Float3_Zero float3(0.0,0.0,0.0)
#define IvyConst_Float4_Zero float4(0.0,0.0,0.0,0.0)
// 各种矩阵零值和单位矩阵
#define IvyConst_Float4x4_Zero float4x4( 0.0, 0.0, 0.0, 0.0,  0.0, 0.0, 0.0, 0.0,  0.0, 0.0, 0.0, 0.0,  0.0, 0.0, 0.0, 0.0)
#define IvyConst_Float4x4_Identity float4x4( 1.0, 0.0, 0.0, 0.0,  0.0, 1.0, 0.0, 0.0,  0.0, 0.0, 1.0, 0.0,  0.0, 0.0, 0.0, 1.0)


//=== [极值定义] ===
//浮点数的最小正值
#define IvyConst_Float_Inf asfloat(0x7F800000)
//浮点数的最大值
#define IvyConst_Float_Max 3.402823466e+38
//浮点数的最小值
#define IvyConst_Float_Min 1.175494351e-38
//浮点数的最小精度值 Epsilon 表示在浮点数计算中可能出现的最小误差。
#define IvyConst_Float_Eps 5.960464478e-8

//半精度浮点数的最大值
#define IvyConst_Half_Max 65504.0
//半精度浮点数的最小值
#define IvyConst_Half_Min 6.103515625e-5
//半精度浮点数的最小正值
#define IvyConst_Half_Inf asfloat(0x7C00)
//半精度浮点数的最小精度值 Epsilon 表示在半精度浮点数计算中可能出现的最小误差。
#define IvyConst_Half_Eps 4.8828125e-4
//半精度浮点数的最小平方根值, 2^-7 == sqrt(HALF_MIN), 此公式可用于确保在计算 x 的平方后得到正确的 HALF_MIN 值。
#define IvyConst_Half_Min_SQRT 0.0078125

//UINT的最大值
#define IvyConst_Uint_Max 0xFFFFFFFFu
//INT的最大值
#define IvyConst_Int_Max  0x7FFFFFFF


// === [数学常量] ===
//π的常量值
#define IvyConst_Pi 3.14159265358979323846
//π的倍数常量
#define IvyConst_Pi2 6.28318530717958647693
//π的四倍常量
#define IvyConst_Pi4 12.5663706143591729538
//π的倒数常量1/π
#define IvyConst_PiInv 0.31830988618379067154
//π的二倍倒数常量1/(2π)
#define IvyConst_Pi2Inv 0.15915494309189533577
//π的四倍倒数常量1/(4π)
#define IvyConst_Pi4Inv 0.07957747154594766788
//π的半值常量
#define IvyConst_PiD2 1.57079632679489661923
//π的半值倒数常量1/(π/2)
#define IvyConst_PiD2Inv 0.63661977236758134308
//π除以4的常量值
#define IvyConst_PiD4 0.78539816339744830961

//自然对数e的常量值log2(e) = 1/ln(2)
#define IvyConst_Log2_E 1.44269504088896340736
//开平方根2的常量值倒数 1/√2
#define IvyConst_Sqrt2Inv 0.70710678118654752440



#endif