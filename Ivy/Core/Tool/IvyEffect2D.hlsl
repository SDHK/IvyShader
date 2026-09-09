/****************************************
*
* 作者： 闪电黑客
* 日期： 2026/09/09
*
* 描述： 2D 特效：轴、覆盖、网点、线条、云雾、星巢、闪粉
*        只出灰度，不采样
*
*/

#if DefPart(IvyEffect2D, Tool)
#define Def_IvyEffect2D_Tool

#include "IvyMath.hlsl"
#include "IvyField.hlsl"
#include "IvyNoise.hlsl"

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
/// 三平面混合。坐标用位置，权重用 abs(法线)，平坦处不会被球面投影拉开。
/// </summary>
half IvyEffect2D_TriplanarBlend(float3 nrm, half fieldX, half fieldY, half fieldZ)
{
    float3 w = abs(nrm);
    w /= max(w.x + w.y + w.z, 1e-5);
    return fieldX * w.x + fieldY * w.y + fieldZ * w.z;
}

/// <summary>
/// 分形线条（单平面）。
/// </summary>
half IvyEffect2D_LinePlane(float2 map, float time)
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
        u = float2(u.x, -u.y) / max(dot(u, u), 1e-5) + p;
        u.x = abs(u.x);
        f = max(f, dot(u - p, u - p));
        g = min(g, sin(dot(u + p, u + p)) + 1.0);
    }
    g = abs(-log(g) / 8.0);
    return 1.0 - saturate(g);
}

/// <summary>
/// 分形线条。PosOs 采样，NrmOs 混合。
/// </summary>
half IvyEffect2D_Line(float3 pos, float3 nrm, float time)
{
    return IvyEffect2D_TriplanarBlend(
        nrm,
        IvyEffect2D_LinePlane(pos.yz, time),
        IvyEffect2D_LinePlane(pos.zx, time),
        IvyEffect2D_LinePlane(pos.xy, time)
    );
}

/// <summary>
/// 云雾。PosOs 采样，NrmOs 混合。
/// </summary>
half IvyEffect2D_Cloud(float3 pos, float3 nrm, float time)
{
    return IvyEffect2D_TriplanarBlend(
        nrm,
        IvyNoise_Smoke(pos.yz, time),
        IvyNoise_Smoke(pos.zx, time),
        IvyNoise_Smoke(pos.xy, time)
    );
}

/// <summary>
/// 各向异性闪光（单层、双半程）。同一根切向扫主光半程和视线，哈希只采一次。
/// x 主光，y 视线（给环境贴图亮部用）。
/// </summary>
half2 IvyEffect2D_GlintLayer(float3 coord, float3 nrm, float3 dirHalfLit, float3 dirHalfView, float scale, half anisotropy, half concentration, half streak)
{
    float3 aniso = IvyNoise_White3(coord * scale) * 2.0 - 1.0;
    aniso -= nrm * dot(aniso, nrm); //投到切平面，只留表面内的朝向
    aniso = normalize(aniso + 1e-5);

    half sharpness = exp2((1.1 - anisotropy) * 3.5);
    half nhLit = pow(abs(dot(nrm, dirHalfLit)), sharpness * concentration);
    half nhView = pow(abs(dot(nrm, dirHalfView)), sharpness * concentration);
    half gLit = nhLit * pow(1.0 - abs(dot(dirHalfLit, aniso)) * anisotropy, streak);
    half gView = nhView * pow(1.0 - abs(dot(dirHalfView, aniso)) * anisotropy, streak);
    return half2(gLit, gView);
}

/// <summary>
/// 随机闪粉：两层各向异性闪光。x 跟主光，y 跟视线。
/// coord 用 PosOs，向量用世界空间；pixel 为 fwidth(PosOs)，由 Pass 填。
/// </summary>
half2 IvyEffect2D_Glitter(float3 pos, float3 pixel, float3 nrm, float3 viewDir, float3 lightDir)
{
    float3 dirHalfLit = normalize(lightDir + viewDir);
    float3 dirHalfView = viewDir;

    // 转 45°，否则颗粒会顺着物体 XYZ 排成行
    float3 coord = pos * 0.5;
    coord.xy = (coord.xy + coord.yx * float2(1.0, -1.0)) * 0.7071;
    coord.xz = (coord.xz + coord.zx * float2(1.0, -1.0)) * 0.7071;
    float3 coord2 = coord;

    // 采样点按像素足迹被半程向量推开，视角或光一动颗粒才闪灭；两层灵敏度不同
    coord.xy -= dirHalfLit.xz * 20.0 * pixel.xy;
    coord.xz -= dirHalfLit.xy * 20.0 * pixel.xz;
    coord2.xy -= dirHalfLit.xy * 5.0 * pixel.xy;
    coord2.xz -= dirHalfLit.xz * 5.0 * pixel.xz;

    half2 g0 = IvyEffect2D_GlintLayer(coord, nrm, dirHalfLit, dirHalfView, 6000.0, 0.55, 12.0, 10.0) * 1.8;
    half2 g1 = IvyEffect2D_GlintLayer(coord2, nrm, dirHalfLit, dirHalfView, 14000.0, 0.60, 6.0, 150.0) * 2.0;
    return g0 + g1;
}

/// <summary>
/// 各向异性闪光（单层）。覆盖由传入灰度决定，半程向量只负责闪灭。
/// </summary>
half IvyEffect2D_GlintLayer(float3 coord, float3 nrm, float3 dirHalf, half cover, float scale, half anisotropy, half streak)
{
    float3 aniso = IvyNoise_White3(coord * scale) * 2.0 - 1.0;
    aniso -= nrm * dot(aniso, nrm);
    aniso = normalize(aniso + 1e-5);
    half spark = pow(1.0 - abs(dot(dirHalf, aniso)) * anisotropy, streak);
    return saturate(cover) * spark;
}

/// <summary>
/// 随机闪粉：覆盖用灰度，闪灭仍走主光半程。
/// </summary>
half IvyEffect2D_Glitter(float3 pos, float3 pixel, float3 nrm, float3 viewDir, float3 lightDir, half cover)
{
    float3 dirHalf = normalize(lightDir + viewDir);

    float3 coord = pos * 0.5;
    coord.xy = (coord.xy + coord.yx * float2(1.0, -1.0)) * 0.7071;
    coord.xz = (coord.xz + coord.zx * float2(1.0, -1.0)) * 0.7071;
    float3 coord2 = coord;

    coord.xy -= dirHalf.xz * 20.0 * pixel.xy;
    coord.xz -= dirHalf.xy * 20.0 * pixel.xz;
    coord2.xy -= dirHalf.xy * 5.0 * pixel.xy;
    coord2.xz -= dirHalf.xz * 5.0 * pixel.xz;

    half g0 = IvyEffect2D_GlintLayer(coord, nrm, dirHalf, cover, 4000.0, 0.55, 10.0) * 1.8;
    half g1 = IvyEffect2D_GlintLayer(coord2, nrm, dirHalf, cover, 8000.0, 0.60, 150.0) * 2.0;
    return g0 + g1;
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
