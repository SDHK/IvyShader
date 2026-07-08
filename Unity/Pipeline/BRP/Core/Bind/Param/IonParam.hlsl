/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/4 20:33
*
* 说明： Unity 引擎BRP的 Ion 环境参数映射实现
* 
*/

#if DefPart(IonBase, Param)
#define Def_IonBase_Param

//==={定义Unity的环境变量宏}===

//===[相机]===

//float3 世界空间中的相机位置。
#define IonParam_CameraPosWs _WorldSpaceCameraPos 
//float4 投影参数
#define IonParam_ProjectionParams _ProjectionParams
//float4 屏幕参数
#define IonParam_ScreenParams _ScreenParams
//float4 Z缓存参数
#define IonParam_ZBufferParams _ZBufferParams
//float4 正交参数
#define IonParam_OrthoParams unity_OrthoParams
//float4 相机投影参数
#define IonParam_CameraProjectionParams unity_CameraProjectionParams

//===[矩阵]===

//float4x4 模型矩阵
#define IonParam_Matrix_M unity_ObjectToWorld
//float4x4 模型矩阵的逆矩阵
#define IonParam_Matrix_I_M unity_WorldToObject
//float4x4 模型矩阵的逆转置（用于法线转换）
// BRP 中有 UNITY_MATRIX_IT_M
//#define IonParam_Matrix_IT_M UNITY_MATRIX_IT_M
#define IonParam_Matrix_IT_M transpose((float3x3)IonParam_Matrix_I_M)
//float4x4 视图矩阵
#define IonParam_Matrix_V UNITY_MATRIX_V
//float4x4 视图矩阵的逆矩阵
#define IonParam_Matrix_I_V UNITY_MATRIX_I_V
//float4x4 投影矩阵
#define IonParam_Matrix_P unity_CameraProjection
//float4x4 投影矩阵的逆矩阵
#define IonParam_Matrix_I_P unity_CameraInvProjection

//float4x4 视图投影矩阵
#define IonParam_Matrix_VP UNITY_MATRIX_VP
//float4x4 视图投影矩阵的逆矩阵
#define IonParam_Matrix_I_VP mul(IonParam_Matrix_I_V, IonParam_Matrix_I_P)
//float4x4 模型视图矩阵
#define IonParam_Matrix_MV UNITY_MATRIX_MV
//float4x4 模型视图矩阵的逆矩阵
#define IonParam_Matrix_I_MV mul(IonParam_Matrix_I_V, IonParam_Matrix_I_M)
//float4x4 模型视图投影矩阵
#define IonParam_Matrix_MVP UNITY_MATRIX_MVP
//float4x4 模型视图投影矩阵的逆矩阵
#define IonParam_Matrix_I_MVP mul(IonParam_Matrix_I_VP, IonParam_Matrix_I_M)

//float4x4 模型视图矩阵的转置
#define IonParam_Matrix_T_MV UNITY_MATRIX_T_MV
//float4x4 模型视图矩阵的逆转置
#define IonParam_Matrix_IT_MV UNITY_MATRIX_IT_MV

//===[时间]===

//float4 当前时间。x:时间/20，y:时间，z:时间x2，w:时间x3
#define IonParam_Time _Time
//float4 正弦时间。x:sin(时间)，y:sin(时间/20)，z:sin(时间/200)，w:sin(时间x2)
#define IonParam_SinTime _SinTime
//float4 余弦时间。x:cos(时间)，y:cos(时间/20)，z:cos(时间/200)，w:cos(时间x2)
#define IonParam_CosTime _CosTime
//float4 上一帧的时间间隔。x:帧间隔时间，y:帧间隔时间/20，z:帧间隔时间/200，w:帧间隔时间x2
#define IonParam_DeltaTime _DeltaTime

//===[光照]===

//float4 天空环境光颜色（RGB）和强度（A）
#define IonParam_AmbientSky unity_AmbientSky
//float4 赤道环境光颜色（RGB）和强度（A）
#define IonParam_AmbientEquator unity_AmbientEquator
//float4 地面环境光颜色（RGB）和强度（A）
#define IonParam_AmbientGround unity_AmbientGround
//float4 主光源位置/方向（世界空间）。xyz:位置/方向，w:0=方向光，1=点光源
#define IonParam_WorldSpaceLightPos _WorldSpaceLightPos0
//float4 主光源颜色（RGB）和强度（A）
#define IonParam_LightColor _LightColor0

//===[球谐光照]===

//float4 球谐函数 R 通道系数（常数项）
#define IonParam_SHAr unity_SHAr
//float4 球谐函数 G 通道系数（常数项）
#define IonParam_SHAg unity_SHAg
//float4 球谐函数 B 通道系数（常数项）
#define IonParam_SHAb unity_SHAb
//float4 球谐函数 R 通道系数（线性项）
#define IonParam_SHBr unity_SHBr
//float4 球谐函数 G 通道系数（线性项）
#define IonParam_SHBg unity_SHBg
//float4 球谐函数 B 通道系数（线性项）
#define IonParam_SHBb unity_SHBb
//float4 球谐函数系数（二次项）
#define IonParam_SHC unity_SHC

//===[阴影]===

//float4 级联阴影分割半径的平方
#define IonParam_ShadowSplitSqRadii unity_ShadowSplitSqRadii
//float4 光源阴影偏移
#define IonParam_LightShadowBias unity_LightShadowBias

//===[雾效]===

//float4 雾的颜色（RGB）和强度（A）
#define IonParam_FogColor unity_FogColor
//float4 雾的参数。x:密度，y:起始距离，z:结束距离，w:其他参数
#define IonParam_FogParams unity_FogParams

#endif // DefPart(IonBase, Param)
