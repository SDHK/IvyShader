/****************************************
*
* 作者： 闪电黑客
* 日期： 2025/12/19
*
* 描述： Ion Shader 框架核心宏定义
*
* 功能：定义框架使用的核心宏系统
*       - Def 宏：模块包装宏，用于防止重复定义
*       - Link 宏：模块链接宏，用于控制模块加载
* 
*       - 通用方法：全局辅助方法。
*       
* 设计理念：
* - 统一管理框架的核心宏定义，避免重复定义
* - 所有需要 Def/Link 宏的文件都应包含本文件
* - 通过宏系统实现按需加载和防止重复包含
*
*/

#ifndef Def_IonMacro
#define Def_IonMacro


// 模块包装宏（单参数版本 - 完整模块）
// 用于判断是否应该定义某个完整模块，防止重复定义
// 使用场景：Pass 文件、Tool 文件等完整模块
#define Def(name) (defined(Link_##name) && !defined(Def_##name) || !defined(IonShader))

// 模块包装宏（双参数版本 - 部分模块）
// 用于判断是否应该定义某个模块的特定部分，防止重复定义
// 使用场景：统一链接文件中控制不同部分的加载
// part 可以是：Library, Bind, Tool 等
#define DefPart(name, part) (defined(Link_##name) && !defined(Def_##name##_##part) || !defined(IonShader))

// 模块链接宏（单行版本）
// 用于判断是否应该链接某个模块，控制按需加载
#define Link(name) (defined(Link_##name) || !defined(IonShader))

// 定义循环展开
#define FE_1(ACT, x1) ACT(x1)
#define FE_2(ACT, x1, x2) ACT(x1) FE_1(ACT, x2)
#define FE_3(ACT, x1, x2, x3) ACT(x1) FE_2(ACT, x2, x3)
#define FE_4(ACT, x1, x2, x3, x4) ACT(x1) FE_3(ACT, x2, x3, x4)
#define FE_5(ACT, x1, x2, x3, x4, x5) ACT(x1) FE_4(ACT, x2, x3, x4, x5)
#define FE_6(ACT, x1, x2, x3, x4, x5, x6) ACT(x1) FE_5(ACT, x2, x3, x4, x5, x6)
#define FE_7(ACT, x1, x2, x3, x4, x5, x6, x7) ACT(x1) FE_6(ACT, x2, x3, x4, x5, x6, x7)
#define FE_8(ACT, x1, x2, x3, x4, x5, x6, x7, x8) ACT(x1) FE_7(ACT, x2, x3, x4, x5, x6, x7, x8)
#define FE_9(ACT, x1, x2, x3, x4, x5, x6, x7, x8, x9) ACT(x1) FE_8(ACT, x2, x3, x4, x5, x6, x7, x8, x9)
#define FE_10(ACT, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10) ACT(x1) FE_9(ACT, x2, x3, x4, x5, x6, x7, x8, x9, x10)

// 定义变量检查宏
#define PassCheck(name) !defined(name)

#define PassNul(name) #define name  

#define PassVar(name) (!defined(PassVar_##name))


/// <summary>
/// 根据 switchValue 选择对应的 float3 值
/// </summary>
float3 IonSwitch_Float3(int switchValue, float3 arg0=0, float3 arg1=0,float3 arg2 = 0,float3 arg3 = 0,float3 arg4 = 0,float3 arg5 = 0,float3 arg6 = 0,float3 arg7 = 0)
{
    float3 result;
    switch (switchValue)
    {
        case 0:result = arg0; break;
        case 1:result = arg1; break;
        case 2:result = arg2; break;
        case 3:result = arg3; break;
        case 4:result = arg4; break;
        case 5:result = arg5; break;
        case 6:result = arg6; break;
        case 7:result = arg7; break;
        default:result = 0; break;
    }
    return result;
}

#endif