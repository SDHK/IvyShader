/****************************************
*
* 作者： 闪电黑客
* 日期： 2026/09/10
*
* 描述： BRP AudioLink 转接层
*        世界频谱图 → Ivy 可调用的频段脉冲
*
*/

#if DefPart(IvyAudioLink, Library)
#define Def_IvyAudioLink_Library

#include "Packages/com.llealloo.audiolink/Runtime/Shaders/AudioLink.cginc"

bool IvyAudioLink_Available()
{
    return AudioLinkIsAvailable();
}

/// <summary>
/// 当前帧频段幅度。band 0 低音 … 3 高音。世界没有 AudioLink 时为 0。
/// </summary>
half IvyAudioLink_Band(uint band)
{
    if (!AudioLinkIsAvailable()) return 0;
    band = min(band, 3u);
    return AudioLinkData(ALPASS_AUDIOLINK + uint2(0, band)).r;
}

#endif
