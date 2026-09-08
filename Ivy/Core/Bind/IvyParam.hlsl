/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/4 19:42
*
* 说明： Ivy Shader环境参数接口规范/模板
* 
* 设计理念：
* - 本文件定义了统一的参数接口规范
* - 不同引擎需要按照此规范实现对应的参数映射文件
* - 所有环境参数使用 IvyParam_ 前缀，保持命名空间统一
* 
* 实现要求：
* 1. 每个 #define 必须映射到对应引擎的内置变量
* 2. 变量类型必须匹配（float3/float4/float4x4等）
* 3. 参数语义需保持一致
*
*/

#if DefPart(IvyBase, Param)
#define Def_IvyBase_Param
   
//===[相机]===

//float3 世界空间中的相机位置。
#define IvyParam_CameraPosWs IvyConst_Float3_Zero
//float4 投影参数
#define IvyParam_ProjectionParams IvyConst_Float4_Zero
//float4 屏幕参数
#define IvyParam_ScreenParams IvyConst_Float4_Zero
//float4 Z缓存参数
#define IvyParam_ZBufferParams IvyConst_Float4_Zero
//float4 正交参数
#define IvyParam_OrthoParams IvyConst_Float4_Zero
//float4 相机投影参数
#define IvyParam_CameraProjectionParams IvyConst_Float4_Zero 

//===[矩阵]===


//float4x4 模型矩阵
#define IvyParam_Matrix_M IvyConst_Float4x4_Identity
//float4x4 视图矩阵
#define IvyParam_Matrix_V IvyConst_Float4x4_Identity
//float4x4 投影矩阵
#define IvyParam_Matrix_P IvyConst_Float4x4_Identity

//float4x4 模型矩阵的逆矩阵
#define IvyParam_Matrix_I_M IvyConst_Float4x4_Identity
//float4x4 视图矩阵的逆矩阵
#define IvyParam_Matrix_I_V IvyConst_Float4x4_Identity
//float4x4 投影矩阵的逆矩阵
#define IvyParam_Matrix_I_P IvyConst_Float4x4_Identity

//float4x4 模型视图矩阵
#define IvyParam_Matrix_MV   mul(IvyParam_Matrix_V, IvyParam_Matrix_M)
//float4x4 视图投影矩阵
#define IvyParam_Matrix_VP   mul(IvyParam_Matrix_P, IvyParam_Matrix_V)
//float4x4 模型视图投影矩阵
#define IvyParam_Matrix_MVP  mul(IvyParam_Matrix_VP, IvyParam_Matrix_M)

//float4x4 模型视图矩阵的逆矩阵
#define IvyParam_Matrix_I_MV  mul(IvyParam_Matrix_I_M, IvyParam_Matrix_I_V)
//float4x4 视图投影矩阵的逆矩阵
#define IvyParam_Matrix_I_VP  mul(IvyParam_Matrix_I_V, IvyParam_Matrix_I_P)
//float4x4 模型视图投影矩阵的逆矩阵
#define IvyParam_Matrix_I_MVP mul(IvyParam_Matrix_I_M, IvyParam_Matrix_I_VP)

//===[时间]===

//float4 当前时间。x:时间/20，y:时间，z:时间x2，w:时间x3
#define IvyParam_Time IvyConst_Float4_Zero 
//float4 正弦时间。x:sin(时间)，y:sin(时间/20)，z:sin(时间/200)，w:sin(时间x2)
#define IvyParam_SinTime IvyConst_Float4_Zero
//float4 余弦时间。x:cos(时间)，y:cos(时间/20)，z:cos(时间/200)，w:cos(时间x2)
#define IvyParam_CosTime IvyConst_Float4_Zero
//float4 上一帧的时间间隔。x:帧间隔时间，y:帧间隔时间/20，z:帧间隔时间/200，w:帧间隔时间x2
#define IvyParam_DeltaTime IvyConst_Float4_Zero



//以下不可通用，删除
//===[光照]===

//float4 天空环境光颜色（RGB）和强度（A）
#define IvyParam_AmbientSky IvyConst_Float4_Zero
//float4 赤道环境光颜色（RGB）和强度（A）
#define IvyParam_AmbientEquator IvyConst_Float4_Zero
//float4 地面环境光颜色（RGB）和强度（A）
#define IvyParam_AmbientGround IvyConst_Float4_Zero
//float4 主光源位置/方向（世界空间）。xyz:位置/方向，w:0=方向光，1=点光源
#define IvyParam_WorldSpaceLightPos IvyConst_Float4_Zero
//float4 主光源颜色（RGB）和强度（A）
#define IvyParam_LightColor IvyConst_Float4_Zero


//===[球谐光照]===

//float4 球谐函数 R 通道系数（常数项）
#define IvyParam_SHAr IvyConst_Float4_Zero
//float4 球谐函数 G 通道系数（常数项）
#define IvyParam_SHAg IvyConst_Float4_Zero
//float4 球谐函数 B 通道系数（常数项）
#define IvyParam_SHAb IvyConst_Float4_Zero
//float4 球谐函数 R 通道系数（线性项）
#define IvyParam_SHBr IvyConst_Float4_Zero
//float4 球谐函数 G 通道系数（线性项）
#define IvyParam_SHBg IvyConst_Float4_Zero
//float4 球谐函数 B 通道系数（线性项）
#define IvyParam_SHBb IvyConst_Float4_Zero
//float4 球谐函数系数（二次项）
#define IvyParam_SHC IvyConst_Float4_Zero

//===[阴影]===

//float4 级联阴影分割半径的平方
#define IvyParam_ShadowSplitSqRadii IvyConst_Float4_Zero
//float4 光源阴影偏移
#define IvyParam_LightShadowBias IvyConst_Float4_Zero

//===[雾效]===

//float4 雾的颜色（RGB）和强度（A）
#define IvyParam_FogColor IvyConst_Float4_Zero
//float4 雾的参数。x:密度，y:起始距离，z:结束距离，w:其他参数
#define IvyParam_FogParams IvyConst_Float4_Zero


#endif // DefPart(IvyBase, Param)

