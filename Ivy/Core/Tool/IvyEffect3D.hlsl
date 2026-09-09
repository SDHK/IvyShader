/****************************************

* 作者： 闪电黑客
* 日期： 2026/8/3 14:53

* 描述： 3D 体积特效：沿视线积分采样场

*/

#if DefPart(IvyEffect3D, Tool)
#define Def_IvyEffect3D_Tool

//===[水面]===
float3 IvyEffect3D_Water(float2 map, float time)
{
    float ga = IvyHash_11(time);
    return float3(ga, ga, ga);
}

/// <summary>
/// 星空特效
/// </summary>
float3 IvyEffect3D_StarNest(float3 map, float3 camOs, float near, float far, float2 dir, float2 time2)
{
    float3 skyOsDirMap = normalize(map);
    float3 tile = float3(1, 1, 1);
    float step = 0.05;
    float brightness = 1;
    float3 from = float3(dir.x, dir.y, 0);

    float fade = 1.0;
    float3 color = float3(0, 0, 0);
    float w = 0;
    for (int r = 0; r < 20; r++)
    {
        near += step * exp(-2. * w);
        if (near > far) break;
        float3 pos = camOs + from + near * skyOsDirMap;
        pos = IvyMath_PingPong(pos, float3(0, 0, 0), tile * 2.0);

        w = IvyField_Star(pos, time2);
        float n = far - near;
        color += float3(w * w * w * w * n, w * w * n * n, w * n * n * n * n) * w * brightness;
    }
    color = 1 * (log2(1 + color));
    return color;
}

/// <summary>
/// 体积纹理特效
/// </summary>
float3 IvyEffect3D_VolumeStar(float3 skyOsDirMap, float3 camOs, float near, float far, float2 dir, float2 time = 0)
{
    skyOsDirMap = normalize(skyOsDirMap);
    float3 tile = float3(1, 1, 1);
    float step = 0.01;
    float3 color = float3(0, 0, 0);
    float weight = 0;
    float3 from = float3(dir.x, dir.y, 0);
    for (int i = 0; i < 20; i++)
    {
        near += step * exp(-2. * weight);
        if (near > far) break;
        float3 pos = camOs + from + near * skyOsDirMap;
        pos = IvyMath_PingPong(pos, float3(0, 0, 0), tile * 2.0);
        weight = IvyField_Star(pos, time);
        float w = weight;
        color += 5 * w * w * w;
    }
    color = 1 * (log2(1 + color));
    return color;
}

/// <summary>
/// 体积纹理特效
/// </summary>
float3 IvyEffect3D_VolumeCrystal(float3 skyOsDirMap, float3 camOs, float near, float far, float2 dir, float2 time = 0)
{
    float3 pos;
    skyOsDirMap = normalize(skyOsDirMap);
    float3 tile = float3(1, 1, 1);
    float step = 0.01;
    float3 color = float3(0, 0, 0);
    float weight = 0;
    float3 from = float3(dir.x, dir.y, 0);
    for (int i = 0; i < 20; i++)
    {
        near += step * exp(-2. * weight);
        if (near > far) break;
        pos = camOs + from + near * skyOsDirMap;
        pos = IvyMath_PingPong(pos, float3(0, 0, 0), tile * 2.0);
        weight = IvyField_Crystal(pos, time);
        float w = weight;
        color += 0.5 * w * w * w * w;
    }

    color = 1 * (log2(1 + color));
    return color;
}

#endif
