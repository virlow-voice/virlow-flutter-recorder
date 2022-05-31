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

#import "FlutterSound.h"
#import "FlutterSoundManager.h"
#import "FlutterSoundPlayer.h"
#import "FlutterSoundPlayerManager.h"
#import "FlutterSoundRecorder.h"
#import "FlutterSoundRecorderManager.h"

FOUNDATION_EXPORT double flutter_soundVersionNumber;
FOUNDATION_EXPORT const unsigned char flutter_soundVersionString[];

