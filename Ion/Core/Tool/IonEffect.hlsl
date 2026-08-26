/****************************************

* 作者： 闪电黑客
* 日期： 2026/8/3 14:53

* 描述： 各种特效工具函数合集

*/



#if DefPart(IonEffect, Tool)
#define Def_IonEffect_Tool

#define Link_IonHash
#define Link_IonMath
#define Link_IonField
#include "../IonEdit.hlsl"

//===[宝石云]===

//===[水面]===
float3 IonEffect_Water(float2 map, float time)
{
    float ga = IonHash_11(time);
    //四角Hash向量

    return float3(ga, ga, ga);
}


/// <summary>
/// 分形线条特效
/// </summary>
/// <param name="map">映射</param>
/// <param name="time">时间</param>
/// <returns>返回计算后的颜色值</returns>
float3 IonEffect_Line(float2 map, float time)
{
    float3 col1 = float3(0.0, 0.21, 0.35);
    float3 col2 = float3(1, 1, 1);

    float f = 3.0, g = f, d;
    float2 r = float2(2, 2), m = float2(0, 0), p, u = map;

    m = (float2(sin(time * .3) * sin(time * .17) + sin(time * .3), (1. - cos(time * .632)) * sin(time * .131) * 1. + cos(time * .3)) + 1.) * r;

    p = (2. + m - r) / r.y;
    for (int i = 0; i < 20; i++)
u = float2( u.x, -u.y ) / dot(u,u) + p,  
		u.x =  abs(u.x),  
		f = max( f, dot(u-p,u-p) ),  
		g = min( g, sin(dot(u+p,u+p))+1.);
    f = abs(-log(f) / 3.5);
    g = abs(-log(g) / 8.);
    g = clamp(g, 0.0, 1.0);
    //return min(float3(g, g, g), 1.0);
    return lerp(col1, col2, 1 - g);
}

/// <summary>
/// 云雾特效
/// </summary>
/// <param name="map">映射</param>
/// <param name="time">时间</param>
/// <returns>返回计算后的颜色值</returns>
float3 IonEffect_Cloud(float2 map, float time)
{
    float3 col1 = float3(0.0, 0.21, 0.35);
    float3 col2 = float3(1, 1, 1);

    float3 o = float3(0, 0, 0);
    float j = .8, k = 1.5;

    float2 n = float2(1, 1);
    float2 p = map;
    o = 0. * o + j;
    float2x2 m = float2x2(j, -1, 1, j);

    for (o.z = k + p.y / 4.; j < 1e2; j *= k)
p =mul ((k*p - .2*time - j) , m),
        n = mul(n,m),
        n += sin(p + n),
        o +=  dot(cos(p + n), p/p)/9./j;
    float a = length(1.0 - exp(-4 * o * o)) * 0.5;
    return a;
    //return a;
}

/// <summary>
/// 星空特效
/// </summary>
/// <param name="map">映射</param>
/// <param name="time">时间</param>
/// <param name="dir">方向</param>
/// <returns>返回计算后的颜色值</returns>
float3 IonEffect_StarNest(float3 map, float time, float2 dir)
{
    float formuparam = 0.53;
    float stepsize = 0.1;
    float zoom = 0.85;
    float3 tile = float3(1, 1, 1) * 0.85;
    //亮度
    float brightness = 0.0015;
    //暗物质
    float darkmatter = 0.300;
    //衰减
    float distfading = 0.730;
    //饱和度
    float saturation = 0.85;
    float3 aniDir = normalize(map) * zoom;

    //观察视角旋转，让星云看起来来没那么重复
    float3 from = float3(1.5, 0.5, 0.5);
    from += float3(time * dir.x, time * dir.y, 0);

    //volumetric rendering
    float s = 0.1, fade = 1.0;
    float3 v = float3(0, 0, 0);
    for (int r = 0; r < 20; r++)
    {
        float3 p = from + s * aniDir * 0.5;
        p = abs(float3(tile) - fmod(p, float3(tile * 2.0)));
        // tiling fold
        float pa, a = pa = 0.0;
        a = IonField_Star(p);
        //dark matter
        a *= 100;
        float dm = max(0.0, darkmatter - a * a );
        // add contrast
        a *= a * a;
        if (r > 6)
            fade *= 1.0 - dm;        // 黑暗噪音，让远处星星有覆盖闪烁感。
        //v+=float3(dm,dm*.5,0.);//太空变蓝
        v += fade;
        v += float3(s, s * s, s * s * s * s) * a * brightness * fade;
        // coloring based on distance
        fade *= distfading;
        // distance fading
        s += stepsize;
    }
    v = lerp(float3(length(v), length(v), length(v)), v, saturation);
    //color adjust
    return v * 0.01;
}

/// <summary>
/// 体积纹理特效
/// </summary>
/// <param name="skyOsDirMap">天空方向映射</param>
/// <param name="camOs">物体相机</param>
/// <param name="depth">深度</param>
/// <returns>返回计算后的颜色值</returns>
float3 IonEffect_VolumeCrystal(float3 skyOsDirMap, float3 camOs, float near, float far,float2 time = 0)
{
    float3 samplePos;
    // 归一化方向向量
    skyOsDirMap = normalize(skyOsDirMap);
    // 步进
    float step = 0.05;
    float3 color = float3(0, 0, 0);
    float3 colorR = float3(0, 0, 0);
    float weight = 0;
    for (int i = 0; i < 20; i++)
    {
        near += step * exp(-2. * weight);
        if (near > far) break;
        samplePos = camOs + near * skyOsDirMap;
        weight = IonField_Crystal(samplePos,time);

        float w = weight;
        //color +=0.05 * float3(w*w*w,w*w,w);

        color += 0.05 *float3(w,w,w)*w*w*w;
    }

    color = 1 * (log2(1 + color));
    return color;
}

/// <summary>
/// 体积纹理特效
/// </summary>
/// <param name="skyOsDirMap">天空方向映射</param>
/// <param name="camOs">物体相机</param>
/// <param name="depth">深度</param>
/// <returns>返回计算后的颜色值</returns>
float3 IonEffect_VolumeStar(float3 skyOsDirMap, float3 camOs, float near, float far,float2 time = 0)
{
    // 归一化方向向量
    skyOsDirMap = normalize(skyOsDirMap);
    // 步进
    float step = 0.05;
    float3 color = float3(0, 0, 0);
    float weight = 0;
    for (int i = 0; i < 20; i++)
    {
        near += step * exp(-2. * weight);
        if (near > far) break;
        //weight = IonSDField_Box(camOs + near * skyOsDirMap);
        //color = weight;

        weight = IonField_Star(camOs + near * skyOsDirMap,time);
        //color = .99 * color + .08 * float3(weight * weight * weight, weight * weight, weight);//blue
        //color = .99 * color + .08 * float3(weight * weight * weight,weight, weight * weight);//blue
        float w = weight;
        color +=5*float3(w,w,w)*w*w;
    }

    color = 1 * (log2(1 + color));
    return color;
}

// 云，液体，酒杯，汽水糖浆

#endif// DefPart(IonEffect, Tool)