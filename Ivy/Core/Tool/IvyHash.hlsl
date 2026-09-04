/****************************************

* 作者： 闪电黑客
* 日期： 2024/12/12 20:27

* 描述： 各种哈希函数合集 

*/

#if DefPart(IvyHash, Tool) 
#define Def_IvyHash_Tool

/// <summary>
/// 哈希：输入1维，返回1维
/// </summary>
float IvyHash_11(float p)
{
    p = frac(p * .1031);
    p *= p + 33.33;
    p *= p + p;
    return frac(p);
}
/// <summary>
/// 哈希：输入1维，返回2维
/// </summary>
float2 IvyHash_12(float p)
{
    float3 p3 = frac(float3(p, p, p) * float3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yzx + 33.33);
    return frac((p3.xx + p3.yz) * p3.zy);
}
/// <summary>
/// 哈希：输入1维，返回3维
/// </summary>
float3 IvyHash_13(float p)
{
    float3 p3 = frac(float3(p, p, p) * float3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yzx + 33.33);
    return frac((p3.xxy + p3.yzz) * p3.zyx);
}
/// <summary>
/// 哈希：输入1维，返回4维
/// </summary>
float4 IvyHash_14(float p)
{
    float4 p4 = frac(float4(p, p, p, p) * float4(.1031, .1030, .0973, .1099));
    p4 += dot(p4, p4.wzxy + 33.33);
    return frac((p4.xxyz + p4.yzzw) * p4.zywx);
}

/// <summary>
/// 哈希：输入2维，返回1维
/// </summary>
float IvyHash_21(float2 p2)
{
    float3 p3 = frac(float3(p2.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return frac((p3.x + p3.y) * p3.z);
}
/// <summary>
/// 哈希：输入2维，返回2维
/// </summary>
float2 IvyHash_22(float2 p2)
{
    float3 p3 = frac(float3(p2.xyx) * float3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yzx + 33.33);
    return frac((p3.xx + p3.yz) * p3.zy);
}
/// <summary>
/// 哈希：输入2维，返回3维
/// </summary>
float3 IvyHash_23(float2 p2)
{
    float3 p3 = frac(float3(p2.xyx) * float3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yxz + 33.33);
    return frac((p3.xxy + p3.yzz) * p3.zyx);
}
/// <summary>
/// 哈希：输入2维，返回4维
/// </summary>
float4 IvyHash_24(float2 p2)
{
    float4 p4 = frac(float4(p2.xyxy) * float4(.1031, .1030, .0973, .1099));
    p4 += dot(p4, p4.wzxy + 33.33);
    return frac((p4.xxyz + p4.yzzw) * p4.zywx);
}
/// <summary>
/// 哈希：输入3维，返回1维
/// </summary>
float IvyHash_31(float3 p3)
{
    p3 = frac(p3 * .1031);
    p3 += dot(p3, p3.zyx + 31.32);
    return frac((p3.x + p3.y) * p3.z);
}
/// <summary>
/// 哈希：输入3维，返回2维
/// </summary>
float2 IvyHash_32(float3 p3)
{
    p3 = frac(p3 * float3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yzx + 33.33);
    return frac((p3.xx + p3.yz) * p3.zy);
}
/// <summary>
/// 哈希：输入3维，返回3维
/// </summary>
float3 IvyHash_33(float3 p3)
{
    p3 = frac(p3 * float3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yxz + 33.33);
    return frac((p3.xxy + p3.yxx) * p3.zyx);
}
/// <summary>
/// 哈希：输入3维，返回4维
/// </summary>
float4 IvyHash_34(float3 p3)
{
    float4 p4 = frac(float4(p3.xyzx) * float4(.1031, .1030, .0973, .1099));
    p4 += dot(p4, p4.wzxy + 33.33);
    return frac((p4.xxyz + p4.yzzw) * p4.zywx);
}

/// <summary>
/// 哈希：输入4维，返回4维
/// </summary>
float4 IvyHash_44(float4 p4)
{
    p4 = frac(p4 * float4(.1031, .1030, .0973, .1099));
    p4 += dot(p4, p4.wzxy + 33.33);
    return frac((p4.xxyz + p4.yzzw) * p4.zywx);
}

//float2 IvyHash_22(float2 uv)
//{
//    const float2 k = float2(0.3183099, 0.3678794);
//    uv = uv * k + k.yx;
//    return -1.0 + 2.0 * frac(16.0 * k * frac(uv.x * uv.y * (uv.x + uv.y)));
//}

#endif