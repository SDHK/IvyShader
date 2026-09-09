/****************************************
*
* 作者： 闪电黑客
* 日期： 2026/09/09
*
* 描述： 2D 特效：轴、覆盖、网点、线条、云雾、星巢
*        只出灰度，不采样
*
*/

#if DefPart(IvyEffect2D, Tool)
#define Def_IvyEffect2D_Tool

#include "IvyMath.hlsl"
#include "IvyField.hlsl"

/// <summary>
/// 二维映射收成 0~1 轴（方向角）
/// </summary>
half IvyEffect2D_Axis(float2 map)
{
    return frac(atan2(map.y, map.x) * 0.15915494);
}

/// <summary>
/// 视线轴：正面 hue0，掠射走 spread
/// </summary>
half IvyEffect2D_Axis(half ndotv, half hue0, half spread)
{
    return hue0 + (1.0 - saturate(ndotv)) * spread;
}

/// <summary>
/// 视角覆盖。同一根轴上切滑动条带，窗外露主色。
/// amount 0 全露，1 条带最实；档数大于 1 时条带跟色块对齐。
/// </summary>
half IvyEffect2D_Cover(half t, half amount, half bands)
{
    if (bands >= 2.0)
        t = IvyMath_Quantize(t, bands);
    half wave = sin(t * 6.2831853) * 0.5 + 0.5;
    return wave * saturate(amount);
}

/// <summary>
/// 斜线网屏。uv 由 Pass 填屏幕或自定义映射。
/// </summary>
half IvyEffect2D_Hatch(float2 uv, half scale, half angle, half fill = 0.5)
{
    float s, c;
    sincos(angle, s, c);
    float x = uv.x * c - uv.y * s;
    return step(1.0 - saturate(fill), frac(x * scale));
}

/// <summary>
/// 圆点网屏
/// </summary>
half IvyEffect2D_Dot(float2 uv, half scale, half radius = 0.35)
{
    float2 grid = frac(uv * scale) - 0.5;
    return 1.0 - step(radius, length(grid));
}

/// <summary>
/// 区域 × 覆盖 × 网点
/// </summary>
half IvyEffect2D_Mask(half region, half cover, half screen)
{
    return saturate(region) * saturate(cover) * saturate(screen);
}

/// <summary>
/// 分形线条。map 为二维映射。
/// </summary>
half IvyEffect2D_Line(float2 map, float time)
{
    float f = 3.0;
    float g = f;
    float2 r = float2(2.0, 2.0);
    float2 m = float2(
        sin(time * 0.3) * sin(time * 0.17) + sin(time * 0.3),
        (1.0 - cos(time * 0.632)) * sin(time * 0.131) + cos(time * 0.3)
    );
    m = (m + 1.0) * r;
    float2 p = (2.0 + m - r) / r.y;
    float2 u = map;
    for (int i = 0; i < 20; i++)
    {
        u = float2(u.x, -u.y) / dot(u, u) + p;
        u.x = abs(u.x);
        f = max(f, dot(u - p, u - p));
        g = min(g, sin(dot(u + p, u + p)) + 1.0);
    }
    g = abs(-log(g) / 8.0);
    return 1.0 - saturate(g);
}

/// <summary>
/// 云雾。map 为二维映射。
/// </summary>
half IvyEffect2D_Cloud(float2 map, float time)
{
    float3 o = 0.0;
    float j = 0.8;
    float k = 1.5;
    float2 n = float2(1.0, 1.0);
    float2 p = map;
    float2x2 rot = float2x2(j, -1.0, 1.0, j);
    for (o.z = k + p.y / 4.0; j < 1e2; j *= k)
    {
        p = mul((k * p - 0.2 * time - j), rot);
        n = mul(n, rot);
        n += sin(p + n);
        o += dot(cos(p + n), p / p) / 9.0 / j;
    }
    return length(1.0 - exp(-4.0 * o * o)) * 0.5;
}

/// <summary>
/// 2D 星巢。沿映射方向假步进，出灰度。彩色由染色层处理。
/// </summary>
half IvyEffect2D_StarNest(float3 map, float time, float2 dir)
{
    const float stepsize = 0.1;
    const float zoom = 0.85;
    float3 tile = 0.85;
    const float brightness = 0.0015;
    const float darkmatter = 0.300;
    const float distfading = 0.730;
    float3 aniDir = normalize(map) * zoom;
    float3 from = float3(1.5, 0.5, 0.5);
    from += float3(time * dir.x, time * dir.y, 0.0);

    float s = 0.1;
    float fade = 1.0;
    float gray = 0.0;
    for (int r = 0; r < 20; r++)
    {
        float3 pos = from + s * aniDir * 0.5;
        pos = abs(tile - fmod(pos, tile * 2.0));
        float w = IvyField_Star(pos, float2(0.5, 0.5));
        w *= 100.0;
        float dm = max(0.0, darkmatter - w * w);
        w *= w * w;
        if (r > 6)
            fade *= 1.0 - dm;
        gray += fade;
        gray += s * w * brightness * fade;
        fade *= distfading;
        s += stepsize;
    }
    return gray * 0.01;
}

#endif
