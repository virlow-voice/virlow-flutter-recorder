#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "Flauto.h"
#import "FlautoPlayer.h"
#import "FlautoPlayerEngine.h"
#import "FlautoRecorder.h"
#import "FlautoRecorderEngine.h"

FOUNDATION_EXPORT double flutter_sound_coreVersionNumber;
FOUNDATION_EXPORT const unsigned char flutter_sound_coreVersionString[];

