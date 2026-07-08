#if Def(IonPassMainSimple)
#define Def_IonPassMainSimple

//===[必要参数声明]====================================================
// 主贴图：启用颜色系统时作灰度细节图（.r 通道），否则全彩贴图
sampler2D IonArg_MainTex;
float4 IonArg_MainTex_ST;

// ColorMask：RGBA 四通道权重分别对应 Color1 ~ Color4 区域
sampler2D IonArg_ColorMask;
sampler2D IonArg_ColorMask1;
sampler2D IonArg_ColorMask2;
sampler2D IonArg_ColorMask3;
sampler2D IonArg_ColorMask4;

float4 IonArg_Color1;// 主色（R 通道区域）
float4 IonArg_Color2;// 次色（G 通道区域）
float4 IonArg_Color3;// 附加色（B 通道区域）
float4 IonArg_Color4;// 高亮色（A 通道区域）

float IonArg_LightInfluence;
float IonArg_LightMax;
float IonArg_LightMin;

// EmissiveTex：自发光遮罩灰度图（.r 通道，黑=不发光 白=全发光，默认 black=无自发光）
sampler2D IonArg_EmissiveTex;
float IonArg_EmissiveIntensity;// 自发光强度倍率（与灰度图相乘，0=关闭）

// BaseRamp 光照（固定参考方向，提供不随光源变化的结构性阴影）
float IonArg_BaseRampToggle;// BaseRamp 混合权重（0=不启用，1=完全启用）
float4 IonArg_BaseRampDir;// 固定参考方向（世界空间，默认 (0,1,0) 向上）

float4 IonArg_BaseRampColor1;
float4 IonArg_BaseRampColor2;
float4 IonArg_BaseRampColor3;
float4 IonArg_BaseRampColor4;
float4 IonArg_BaseRampColor5;

float IonArg_BaseRampThreshold1;
float IonArg_BaseRampThreshold2;
float IonArg_BaseRampThreshold3;
float IonArg_BaseRampThreshold4;

float IonArg_BaseRampSoftness1;
float IonArg_BaseRampSoftness2;
float IonArg_BaseRampSoftness3;
float IonArg_BaseRampSoftness4;

// Ramp 动态光照（灰度，只控制阴影边界，颜色由光源颜色和 BaseRamp 提供）
float IonArg_LightRampThreshold;// 阴影边界位置（NdotL 轴 0~1）
float IonArg_LightRampSoftness;// 边界过渡宽度（0=硬切卡通）


// 菲涅耳边缘光
float IonArg_RimPower;// 边缘集中度（高=细窄，低=宽泛，建议 2~8）
float IonArg_RimIntensity;// 边缘光强度（0=关闭）

// 背光边缘光（逆光轮廓光，跟随光源方向）
float4 IonArg_BackRimColor;// 背光颜色
float IonArg_BackRimPower;// 边缘集中度（建议 2~8）
float IonArg_BackRimIntensity;// 背光强度（0=关闭）

float IonArg_Metallic;
sampler2D IonArg_MetalMask;
float IonArg_MetalSpecularPower;
float IonArg_MetalSpecularIntensity;
float IonArg_MetalReflectIntensity;
float IonArg_MetalRoughness;
sampler2D IonArg_MetalMatCap;
float IonArg_MetalProbeInfluence;
float IonArg_MetalDiffuseScale;


int IonArg_StarNestToggle;
float IonArg_StarNestlens;

//===[定义宏]====================================================
#define IonKey_Instancing
#define IonKey_Fog
#define IonKey_ForwardBase // 生成 multi_compile_fwdbase，驱动 SHADOWS_DEPTH 等阴影变体编译
#define IonKey_MainLightShadows
#define IonKey_MainLightShadowsCascade
#define IonKey_ShadowsSoft
// #define IonSet_ShadowScreen
// IonSet_ShadowScreen 不启用：
// 屏幕空间阴影依赖不透明物体的深度缓冲，透明物体（ZWrite Off）不写深度，
// 导致采样到身后物体的阴影数据，在透明表面产生矩形投影。
// 改用 light-space 深度图采样，基于顶点世界坐标，不依赖屏幕深度，透明兼容。

//===[引入核心库]====================================================
#define Link_IonBase
#define Link_IonLight
#define Link_IonMatrix
#define Link_IonMath
#define Link_IonVertex
#define Link_IonCoord
#include "../../Core/IonCore.hlsl"


struct VertData
{
    IonVar_PositionOs
    IonVar_Normal
    IonVar_T0(float2, UV)
};

struct FragData
{
    IonVar_PositionCs
    IonVar_T0(float2, UV)
    IonVar_T1(float3, Normal)
    IonVar_T2(float3, PositionOs)
    IonVar_T3(float3, NormalWs)
    IonVar_T4(float3, PositionWs)
    IonVar_T5(float4, ShadowCoord)
};

#pragma vertex vert
FragData vert(VertData vertData)
{
    FragData fragData;

    fragData.UV = IonMath_Transform2D(vertData.UV.xy, IonArg_MainTex_ST.xy, IonArg_MainTex_ST.zw);
    fragData.PositionCs = IonMatrix_ObjectToClip(vertData.PositionOs);
    fragData.Normal = vertData.Normal;
    fragData.PositionOs = vertData.PositionOs;
    fragData.NormalWs = IonMatrix_ObjectToWorldNormal(vertData.Normal);
    fragData.PositionWs = IonMatrix_ObjectToWorld(vertData.PositionOs);
    // light-space shadow coord：基于顶点世界坐标变换，不依赖屏幕深度缓冲
    fragData.ShadowCoord = IonLight_ShadowCoord(vertData.PositionOs, fragData.PositionCs, fragData.PositionWs);
    return fragData;
}





#pragma fragment frag
half4 frag(FragData fragData) : SV_Target
{

    half4 mainTex = tex2D(IonArg_MainTex, fragData.UV);

    // 世界相机到世界坐标的向量
    float3 dirCameraWsToPosWs = IonCoord_LookTo(IonParam_CameraPosWs, fragData.PositionWs);
    // 世界坐标到世界相机的向量
    float3 dirPosWsToCameraWs = - dirCameraWsToPosWs;

    //===[自发光]===================================================
    float emissiveMask = tex2D(IonArg_EmissiveTex, fragData.UV).r;
    float emissiveWeight = saturate(emissiveMask * IonArg_EmissiveIntensity);

    //===[场景光照]================================================
    float3 normalWs = normalize(fragData.NormalWs);
    //环境光球谐光照，晚上没有球谐光照。
    float3 ambient = ShadeSH9(float4(normalWs, 1));
    IonStruct_Light light = IonLight_MainLight(fragData.ShadowCoord);
    // 光向下=1，光向上(夜晚)=0
    float sunUp = saturate(light.Direction.y);
    // 光向下=1，光向上(夜晚)=0

    // 光照钳制，避免发光过亮导致溢出
    float3 lightBaseColor = clamp(light.Color * sunUp, emissiveWeight, IonArg_LightMax);
    // 综合距离衰减和阴影衰减，得到最终光照颜色
    float3 lightColor = lightBaseColor * light.DistanceAttenuation * light.ShadowAttenuation;
    lightColor = lightColor + ambient;

    // 计算光照亮度（灰度）
    float lightLuma = saturate(dot(lightColor, float3(0.299, 0.587, 0.114)));
    // 主体光照色影响度，防止过度受光源颜色调制
    float3 mainLightColor = lerp(lightLuma, saturate(lightColor), IonArg_LightInfluence);
    // 当光线消失时，保持固定方向以维持 BaseRamp 的结构性阴影效果
    half3 lightDirection = lerp(IonArg_BaseRampDir, light.Direction, ceil(lightLuma));


    //===[4 色混合]=================================================
    // ColorMask RGBA 权重混合 Color1~4，未覆盖区域透出 MainTex 原色
    // MainTex.r 作为灰度细节叠加到最终颜色
    //half4 colorMask = tex2D(IonArg_ColorMask, fragData.UV);
    half4 colorMask1 = tex2D(IonArg_ColorMask1, fragData.UV);
    half4 colorMask2 = tex2D(IonArg_ColorMask2, fragData.UV);
    half4 colorMask3 = tex2D(IonArg_ColorMask3, fragData.UV);
    half4 colorMask4 = tex2D(IonArg_ColorMask4, fragData.UV);

    // 计算每个颜色区域的 alpha 权重
    float baseAlpha1 = colorMask1.r * IonArg_Color1.a;
    float baseAlpha2 = colorMask2.r * IonArg_Color2.a;
    float baseAlpha3 = colorMask3.r * IonArg_Color3.a;
    float baseAlpha4 = colorMask4.r * IonArg_Color4.a;
    float baseAlpha = baseAlpha1 + baseAlpha2 + baseAlpha3 + baseAlpha4;

    // 计算每个颜色区域的 RGB 值
    float3 baseColor1 = IonArg_Color1.rgb * baseAlpha1;
    float3 baseColor2 = IonArg_Color2.rgb * baseAlpha2;
    float3 baseColor3 = IonArg_Color3.rgb * baseAlpha3;
    float3 baseColor4 = IonArg_Color4.rgb * baseAlpha4;
    float3 baseColor = baseColor1 + baseColor2 + baseColor3 + baseColor4;
    baseColor = baseColor / baseAlpha;


    // BaseRamp：固定方向结构性阴影（定义颜色区间，受光源强度/阴影调制，不自发光）
    // 将固定方向转换到世界空间
    float3 baseRampDirWs = IonMatrix_ObjectToWorld(IonArg_BaseRampDir).xyz;
    // 从观察空间转换到世界空间
    //float3 baseRampDirWs = IonMatrix_ViewToWorld(IonArg_BaseRampDir).xyz;
    float NdotBase = saturate(dot(normalWs, baseRampDirWs) * 0.5 + 0.5);

    // 计算法线与固定方向的夹角，映射到 0~1 作为 BaseRamp 权重
    float3 N = normalize(normalWs);
    float3 D = normalize(baseRampDirWs);
    float cosTheta = clamp(dot(N, D), -1.0, 1.0);
    float angle = acos(cosTheta) * (180.0 / UNITY_PI);
    // 0 ~ 180（角度）
    float NdotBaseLine = 1 - angle / 180.0;


    float3 offsetColor1 = (IonArg_BaseRampColor1 - IonArg_BaseRampColor3).rgb;
    float3 offsetColor2 = (IonArg_BaseRampColor2 - IonArg_BaseRampColor3).rgb;
    float3 offsetColor4 = (IonArg_BaseRampColor4 - IonArg_BaseRampColor3).rgb;
    float3 offsetColor5 = (IonArg_BaseRampColor5 - IonArg_BaseRampColor3).rgb;

    float3 baseRampColor = IonLight_Ramp(NdotBaseLine, baseColor + offsetColor1, IonArg_BaseRampThreshold1, IonArg_BaseRampSoftness1, baseColor + offsetColor2, IonArg_BaseRampThreshold2, IonArg_BaseRampSoftness2, baseColor, IonArg_BaseRampThreshold3, IonArg_BaseRampSoftness3, baseColor + offsetColor4, IonArg_BaseRampThreshold4, IonArg_BaseRampSoftness4, baseColor + offsetColor5);

    // 混合NdotBase 是为了让BaseRampColor 随法线方向变化而变化
    //baseRampColor = (baseRampColor * (NdotBase * 0.5 + 0.5));
    baseColor = lerp(baseColor, baseRampColor, IonArg_BaseRampToggle);

    // Ramp：动态光照（灰度，跟随光源方向）
    float NdotL = saturate(dot(normalWs, lightDirection) * 0.5 + 0.5);
    float rampGray = IonLight_RampGray(NdotL, IonArg_LightRampThreshold, IonArg_LightRampSoftness);
    // 光照强度映射到指定范围，避免过暗或过亮
    rampGray = rampGray * (IonArg_LightMax - IonArg_LightMin) + IonArg_LightMin;



    // 菲涅耳边缘光（始终存在，不依赖光源）
    float fresnel = IonLight_Fresnel(normalWs, dirPosWsToCameraWs, (IonArg_RimPower + lightLuma) * 0.5);
    IonArg_RimIntensity = IonArg_RimIntensity * (IonArg_LightMax + lightLuma);
    half3 rimLight = baseColor * lightColor * fresnel * IonArg_RimIntensity;

    // 背光边缘光（逆光时才亮，颜色受光源颜色调制）
    float backRim = IonLight_BackRim(normalWs, dirPosWsToCameraWs, lightDirection, (IonArg_BackRimPower + lightLuma) * 0.5);
    IonArg_BackRimIntensity = IonArg_BackRimIntensity * (IonArg_LightMax + lightLuma);
    half3 backRimLight = baseColor * lightColor * backRim * IonArg_BackRimIntensity;


    float3 dynamicShading = mainLightColor * rampGray + rimLight + backRimLight;
    // 合并：颜色 + 动态光照（随光源）
    //half3 finalColor = baseColor * dynamicShading;


    // ===星旋效果

    //       float iTime = IonParam_Time.y;
    //   //float2 uv = (fragData.UV / iResolution.xy) - .5;
    //   float2 uv = fragData.UV*0.5;
    //float t = iTime * .1 + ((.25 + .05 * sin(iTime * .1))/(length(uv.xy) + .07)) * 2.2;
    //float si = sin(t);
    //float co = cos(t);
    //float2x2 ma = float2x2(co, -si, si, co);

    //float v1, v2, v3;
    //v1 = v2 = v3 = 0.0;

    //float s = 0.0;
    //for (int i = 0; i < 100; i++)
    //{
    //	float3 p = s * float3(uv, 0.0);
    //	p.xy = mul(p.xy, ma);
    //	p += float3(.22, .3, s - 1.5 - sin(iTime * .13) * .1);
    //	for (int i = 0; i < 10; i++)	p = abs(p) / dot(p,p) - 0.659;
    //	v1 += dot(p,p) * .0015 * (1.8 + sin(length(uv.xy * 13.0) + .5  - iTime * .2));
    //	v2 += dot(p,p) * .0013 * (1.5 + sin(length(uv.xy * 14.5) + 1.2 - iTime * .3));
    //	v3 += length(p.xy*10.) * .0003;
    //	s  += .035;
    //}

    //float len = length(uv);
    //v1 *= smoothstep(.7, .0, len);
    //v2 *= smoothstep(.5, .0, len);
    //v3 *= smoothstep(.9, .0, len);

    //float3 col = float3( v3 * (1.5 + sin(iTime * .2) * .4),(v1 + v3) * .3,v2) + smoothstep(0.2, .0, len) * .85 + smoothstep(.0, .6, v3) * .3;
    //   float4 col001 = float4(min(pow(abs(col), float3(1.2, 1.2, 1.2)), 1.0), 1.0); // ✅ HLSL
    //===


    //get coords and direction
    //跟随物体移动和旋转的法线渲染
    //float3 normalVs1 = mul((float3x3)IonParam_Matrix_I_M, fragData.NormalWs);
    //跟随物体移动但反向旋转的法线渲染
     //float3 normalVs1 = mul((float3x3)IonParam_Matrix_M, fragData.NormalWs);
     //跟随物体移动但不旋转的法线渲染
    //float3 normalVs1 =  fragData.NormalWs;

   
    // 1. 世界空间视线方向（无限远天空盒，角度跟世界）
    float3 worldDir1 = IonCoord_SkyBox(IonParam_CameraPosWs, fragData.PositionWs);
    float3 posOs1 = IonCoord_PositionToNormalAsWorld(fragData.PositionOs);
    worldDir1 = lerp(worldDir1,posOs1, IonArg_StarNestlens);

    //2.镜面反射效果
    float3 worldDir2 = IonCoord_Reflect(dirCameraWsToPosWs, normalWs);
    // 3.法线映射到物体表面，跟随物体移动和旋转
    float3 worldDir3 = IonCoord_ObjectSpace(fragData.Normal,fragData.PositionOs);

    // 4. 跟随视角同步旋转的法线渲染 
    float3 worldDir4 = IonCoord_ViewSpace(dirCameraWsToPosWs);
    // 透镜凹凸效果。
    float3 normalVs4 = IonCoord_ObjectView(normalWs, fragData.PositionOs);
    worldDir4 = lerp(worldDir4,normalVs4, IonArg_StarNestlens);

    float3 worldDir = float3(0,0,0);
    worldDir += worldDir1 * colorMask1.r;
    worldDir += worldDir2 * colorMask2.r;
    worldDir += worldDir3 * colorMask3.r;
    worldDir += worldDir4 * colorMask4.r;
    
    worldDir = worldDir4;
    float3 starNestRGB = 0;
    if (IonArg_StarNestToggle)
        starNestRGB = IonLight_StarNest(worldDir, IonParam_Time.z, float2(1, 1), 0.0003);

 // 投影到平面（类似相机投影视差）
//float2 tileUV = worldDir.xy / max(abs(worldDir.z), 1e-3);
// 投影到球面（类似天空盒映射）
float3 D1 = normalize(worldDir);
float2 tileUV;
tileUV.x = atan2(D1.x, D1.z) / (2.0 * 3.14159265) + 0.5;
tileUV.y = asin(clamp(D1.y, -1.0, 1.0)) / 3.14159265 + 0.5;

starNestRGB = tex2D(IonArg_MetalMatCap, tileUV).rgb;

    //===[金属]=====================================================
    float metalMask = saturate(IonArg_Metallic * tex2D(IonArg_MetalMask, fragData.UV).r);
    // 金属 tint（金/银/铜来自 baseColor / Color1）
    float3 metalTint = baseColor;
    float3 F0 = metalTint;
    // 金属 F0 ≈ 自身颜色
    // 1. 弱漫反射 + 环境底色
    float3 metalDiffuse = metalTint * ambient * IonArg_MetalDiffuseScale;
    metalDiffuse += metalTint * mainLightColor * rampGray * IonArg_MetalDiffuseScale;
    // 2. 方向高光（Blinn-Phong）
    float3 H = normalize(lightDirection + dirPosWsToCameraWs);
    float NdotH = saturate(dot(normalWs, H));
    float specPower = lerp(256.0, 16.0, IonArg_MetalRoughness);
    float spec = pow(NdotH, specPower) * rampGray * light.ShadowAttenuation;
    float3 specular = F0 * spec * mainLightColor * IonArg_MetalSpecularIntensity;
    // 3. 环境反射：MatCap 保底 + SpecCube 增色
    float3 R = reflect(-dirPosWsToCameraWs, normalWs);
    // MatCap（VRChat 稳定）
    float2 matcapUV = normalWs.xy * 0.5 + 0.5;
    // 或改用 view-space normal 更稳

    float3 matcapReflect = tex2D(IonArg_MetalMatCap, matcapUV).rgb;
    //float3 matcapReflect = tex2D(col001.rgb, matcapUV).rgb;
    // BRP 反射探针（可选）
    float mip = IonArg_MetalRoughness * 6.0;
    float4 envRaw = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, R, mip);
    float3 probeReflect = DecodeHDR(envRaw, unity_SpecCube0_HDR);
    float3 envReflect = lerp(matcapReflect, probeReflect, IonArg_MetalProbeInfluence);
    // 菲涅耳增强边缘反射
    float fresnelMetal = IonLight_Fresnel(envReflect, dirPosWsToCameraWs, IonArg_RimPower);
    envReflect *= lerp(1.0, 1.5, fresnelMetal);
    float3 metalReflect = envReflect * F0 * IonArg_MetalReflectIntensity;
    // 4. 金属合成
    half3 metalColor = metalDiffuse + specular + metalReflect;
    // 可选：金属上保留弱 Rim
    metalColor += rimLight * metalMask * 0.5;
    //===[最终混合]=================================================
    half3 dielectric = baseColor * dynamicShading;
    half3 finalColor = lerp(dielectric, metalColor, metalMask);

    return half4(starNestRGB, mainTex.a);
     //return half4(finalColor, mainTex.a);

    //   float3 c;
    //float l;
    //   float z = IonParam_Time.y;
    //   float2 uv = fragData.UV;
    //   float2 p = float2(0,0);
    //   float2 r = float2(1,1);
    //for(int i=0;i<3;i++) {
    //	p=fragData.UV/r;
    //	p-=.5;
    //	p.x*=r.x/r.y;
    //	z+=.07;
    //	l=length(p);
    //	uv+=p/l*(sin(z)+1.)*abs(sin(l*9.-z-z));
    //	c[i]=.01/length(fmod(uv.y,1.)-.5);
    //}
    //return half4(c/l,1);


    //return vec4(min(pow(abs(col), float3(1.2)), 1.0), 1.0);


}

#endif// Def(IonPassMainSimple)