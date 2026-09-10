/****************************************

* 作者： 闪电黑客
* 日期： 2024/12/13 19:01

* 描述： UV 工具：变换、投影、分区、扭曲

*/

#if DefPart(IvyUv, Tool) 
#define Def_IvyUv_Tool

/// <summary>
/// 2D坐标缩放偏移
/// </summary>
/// <param name="uv">输入的二维坐标</param>
/// <param name="scale">缩放值</param>
/// <param name="offset">偏移值</param>
/// <returns>变换后的二维坐标</returns>
float2 IvyUv_Transform2D(float2 uv, float2 scale, float2 offset)
{
    return uv * scale + offset;
}

/// <summary>
/// 把 [0,1] UV 映射到格子坐标（压在最后一格内，避免 uv==1 越界）
/// </summary>
/// <param name="uv">输入的二维坐标</param>
/// <param name="cols">格子列数</param>
/// <param name="rows">格子行数</param>
/// <returns>格子坐标</returns>    
float2 IvyUv_GridCell(float2 uv, int cols, int rows)
{
    float2 grid = float2((float)cols, (float)rows);
    return min(uv * grid, grid - 1e-5);
}

/// <summary>
/// 格子 Id（左上为 0，行优先）
/// </summary>
/// <param name="uv">输入的二维坐标</param>
/// <param name="cols">格子列数</param>
/// <param name="rows">格子行数</param>   
/// <param name="flipY">1=数学 row0(下) 翻成上=0（贴图/九宫格习惯）</param>
/// <returns>格子 Id</returns> 
int IvyUv_GridId(float2 uv, int cols, int rows, int flipY = 1)
{
    float2 cell = IvyUv_GridCell(uv, cols, rows);
    int col = (int)floor(cell.x);
    int mathRow = (int)floor(cell.y);
    int row = flipY != 0 ? (rows - 1 - mathRow) : mathRow;
    return row * cols + col;
}

/// <summary>
/// 格内局部 UV [0,1)
/// </summary>
/// <param name="uv">输入的二维坐标</param>
/// <param name="cols">格子列数</param>
/// <param name="rows">格子行数</param>
/// <returns>格内局部 UV</returns>    
float2 IvyUv_GridLocal(float2 uv, int cols, int rows)
{
    return frac(IvyUv_GridCell(uv, cols, rows));
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

/// <summary>
/// 由位置、UV 的屏幕导数拼切线空间，把视线（点指向相机）转进去。
/// 须在片元、且无动态分支包住 ddx/ddy。
/// </summary>
float3 IvyUv_ViewToTangent(float3 posWs, float2 uv, float3 viewWs, float3 nrmWs)
{
    float3 dp1 = ddx(posWs);
    float3 dp2 = ddy(posWs);
    float2 du1 = ddx(uv);
    float2 du2 = ddy(uv);
    float3 dp2perp = cross(dp2, nrmWs);
    float3 dp1perp = cross(nrmWs, dp1);
    float3 tangent = dp2perp * du1.x + dp1perp * du2.x;
    float3 bitangent = dp2perp * du1.y + dp1perp * du2.y;
    float invMax = rsqrt(max(max(dot(tangent, tangent), dot(bitangent, bitangent)), 1e-8));
    tangent *= invMax;
    bitangent *= invMax;
    viewWs = normalize(viewWs);
    return float3(dot(viewWs, tangent), dot(viewWs, bitangent), dot(viewWs, nrmWs));
}

/// <summary>
/// 一次偏移浅视差。height 0.5 不挪，scale 为 UV 幅度。
/// </summary>
float2 IvyUv_Parallax(float2 uv, half height, float3 viewTs, half scale)
{
    half h = (height - 0.5) * scale;
    float3 v = normalize(viewTs);
    v.z += 0.42;
    return uv + h * (v.xy / max(v.z, 1e-4));
}

/// <summary>
/// 由高度场屏幕导数微扰法线。scale=0 退回原法线。
/// 须在片元、且无动态分支包住 ddx/ddy。
/// </summary>
float3 IvyUv_PerturbNrm(float3 nrmWs, float3 posWs, half height, half scale)
{
    nrmWs = normalize(nrmWs);
    float3 sigmaX = ddx(posWs);
    float3 sigmaY = ddy(posWs);
    half dhdx = ddx(height);
    half dhdy = ddy(height);
    float3 r1 = cross(sigmaY, nrmWs);
    float3 r2 = cross(nrmWs, sigmaX);
    float det = dot(sigmaX, r1);
    float3 grad = sign(det) * (dhdx * r1 + dhdy * r2);
    return normalize(max(abs(det), 1e-8) * nrmWs - grad * scale);
}

/// <summary>
/// 黑槽压暗、白脊略提。scale=0 为 1。
/// </summary>
half IvyUv_Cavity(half height, half scale)
{
    return clamp(1.0 + scale * (height * 2.0 - 1.0), 0.55, 1.15);
}

#endif
