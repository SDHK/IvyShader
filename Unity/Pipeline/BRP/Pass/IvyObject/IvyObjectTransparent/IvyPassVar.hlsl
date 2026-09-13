/****************************************
*
* 作者： 闪电黑客
* 日期： 2026/9/14
*
* 描述： IvyObjectTransparent Pass 语义尾巴。必须在 IvyCore 前引入
*
*/

#ifndef Def_IvyPassVar
#define Def_IvyPassVar

#define IvyVarIn_PosOs : POSITION
#define IvyVarIn_NrmOs : NORMAL
#define IvyVarIn_Uv : TEXCOORD0
#define IvyVarIn_ViewFace : VFACE

#define IvyVarOut_PosCs : SV_POSITION
#define IvyVarOut_Uv : TEXCOORD0
#define IvyVarOut_NrmOs : TEXCOORD1
#define IvyVarOut_PosOs : TEXCOORD2
#define IvyVarOut_NrmWs : TEXCOORD3
#define IvyVarOut_PosWs : TEXCOORD4
#define IvyVarOut_LightVec : TEXCOORD0
#define IvyVarOut_Target : SV_Target

#endif
