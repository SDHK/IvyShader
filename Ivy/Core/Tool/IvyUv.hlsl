/****************************************

* 作者： 闪电黑客
* 日期： 2024/12/13 19:01

* 描述： 各种扭曲函数合集 

*/

#if DefPart(IvyUv, Tool) 
#define Def_IvyUv_Tool



// 2D坐标缩放偏移
// float2 uv : 输入的二维坐标
// float2 scale : 缩放值
// float2 offset : 偏移值
// float2 return : 变换后的二维坐标
float2 IvyUv_Transform2D(float2 uv, float2 scale, float2 offset)
{
    return uv * scale + offset;
}

/// <summary>
/// 将方向/法线映射到方图 MatCap UV（1:1，中间为金属球那种）
/// 输入应为视角空间（View Space）的方向或法线；用 xy 对应球正面圆盘
/// </summary>
/// <param name="dirVs">视角空间方向或法线</param>
/// <returns>MatCap 贴图 UV [0,1]</returns>
float2 IvyUv_DirToMatCap(float3 dirVs)
{
    dirVs = normalize(dirVs);
    // 可选：避免背面/极值撑出圆外（多数 MatCap 球在圆内）
    // float2 xy = dirVs.xy / (dirVs.z + 1.0); // 另一种球面投影，一般不用
    return dirVs.xy * 0.45 + 0.5;
}


/// <summary>
/// 将方向向量映射到平面贴图坐标 
/// </summary>
/// <param name="dir">方向</param>
/// <returns>平面贴图坐标</returns>
float2 IvyUv_DirToPlanar(float3 dir)
{
    dir = normalize(dir);
    return dir.xy / max(abs(dir.z), 1e-3);
    // 若要进 [0,1] 贴图，再 *0.5+0.5（按你贴图约定）
}

/// <summary>
/// 将方向向量映射到球面贴图坐标 
/// </summary>
/// <param name="dir">方向</param>
/// <returns>球面贴图坐标</returns>
float2 IvyUv_DirToSphere(float3 dir)
{
    dir = normalize(dir);
    return float2(
        atan2(dir.x, dir.z) * (0.5 / 3.14159265) + 0.5,
        asin(clamp(dir.y, -1.0, 1.0)) * (1.0 / 3.14159265) + 0.5
    );
}

/// <summary>
/// 根据角度计算半径为的圆上的点 0~1
/// </summary>
/// <param name="angle">角度值</param>
/// <returns>对应的二维坐标</returns>
float2 IvyUv_AngleToUV(float angle)
{
    angle %= 360;
    return frac(float2(cos(angle) + 1, sin(angle) + 1) * 0.5);
}

// 极坐标扭曲 
// float2 uv: 输入的UV坐标
// float distortAngle: 扭曲的角度
// float scale = 1: 扭曲的缩放比例
// float2 return: 扭曲后的UV坐标
float2 IvyUv_Polar(float2 uv, float distortAngle, float scale = 1)
{
    // 定义中心点坐标
    float2 center = (0.5, 0.5);
    
    // 计算 UV 坐标相对于中心点的偏移量,中心指向uv的向量
    float2 offset = uv - center;
    
    // 计算偏移量的距离（即从中心点到 UV 坐标的距离）
    float distance = sqrt(offset.x * offset.x + offset.y * offset.y) * (1 / scale);
    
    // 计算偏移量的角度（即从中心点到 UV 坐标的角度）
    float uvAngle = atan2(offset.y, offset.x);
    
    // 根据距离和时间对角度进行调整
    uvAngle = uvAngle + (distance * distortAngle);
    
    // 计算新的 UV 坐标
    float2 new_uv = float2(distance * cos(uvAngle), distance * sin(uvAngle)) + center;
    
    // 返回新的 UV 坐标
    return new_uv;
}


//旋涡扭曲
// float2 uv: 输入的UV坐标
// float distortAngle: 扭曲的角度
// float scale = 1: 扭曲的缩放比例
// float2 center = (0.5, 0.5): 扭曲的中心点
// float2 return: 扭曲后的UV坐标
float2 IvyUv_Vortex(float2 uv, float distortAngle, float scale = 1, float2 center = (0.5, 0.5))
{
    // 计算 UV 坐标相对于中心点的偏移量,中心指向uv的向量
    float2 offset = uv - center;
    
    // 计算偏移量的距离（即从中心点到 UV 坐标的距离）
    float distance = sqrt(offset.x * offset.x + offset.y * offset.y);
    
    // 计算偏移量的角度（即从中心点到 UV 坐标的角度）
    float uvAngle = atan2(offset.y, offset.x);
    
    // 计算 distance 大于 scale 时 a 变成 0，小于 scale 时 a 变成 1
    float IsDistort = step(distance, scale);

    // 根据距离和时间对角度进行调整
    uvAngle = uvAngle + ((scale - distance) * (distortAngle))  * IsDistort;
    
    // 计算新的 UV 坐标
    float2 new_uv = float2(distance * cos(uvAngle), distance * sin(uvAngle)) + center;
    
    // 返回新的 UV 坐标
    return new_uv;
}


// 球面扭曲
// float2 uv: 输入的UV坐标
// float radius: 扭曲的半径
// float2 center = (0.5, 0.5): 扭曲的中心点
// float2 return: 扭曲后的UV坐标
float2 IvyUv_Sphere(float2 uv, float radius, float2 center = (0.5, 0.5))
{
    // 计算 UV 坐标相对于中心点的偏移量
    float2 offset = uv - center;
    
    // 计算偏移量的距离
    float distance = length(offset);
    
    // 计算偏移量的角度
    float uvAngle = atan2(offset.y, offset.x);
    
    // 计算 distance 大于 scale 时 a 变成 0，小于 scale 时 a 变成 1
    float IsDistort = step(distance, radius);
    
    distance = ((distance * distance) / (radius * radius)) * (distance / radius) * radius * IsDistort;
    
    // 计算新的 UV 坐标
    float2 new_uv = float2(distance * cos(uvAngle), distance * sin(uvAngle)) + center;
    
    // 返回新的 UV 坐标
    return new_uv;
}


// 波浪扭曲
// float2 uv: 输入的UV坐标
// float amplitude: 波浪的振幅
// float frequency: 波浪的频率
// float phase: 波浪的相位
// float2 return: 扭曲后的UV坐标
float2 IvyUv_Wave(float2 uv, float amplitude, float frequency, float phase)
{
    uv.x += sin(uv.y * frequency + phase) * amplitude;
    uv.y += sin(uv.x * frequency + phase) * amplitude;
    return uv;
}

#endif
