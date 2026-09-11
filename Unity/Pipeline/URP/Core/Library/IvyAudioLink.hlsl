/****************************************
*
* 描述： URP AudioLink 转接层
*
****************************************/

#if DefPart(IvyAudioLink, Library)
#define Def_IvyAudioLink_Library

#include "Packages/com.llealloo.audiolink/Runtime/Shaders/AudioLink.cginc"

bool IvyAudioLink_Available()
{
    return AudioLinkIsAvailable();
}

half IvyAudioLink_Band(uint band)
{
    if (!AudioLinkIsAvailable()) return 1;
    band = min(band, 3u);
    return AudioLinkData(ALPASS_AUDIOLINK + uint2(0, band)).r;
}

#endif
