# Changelog

All notable changes to this project will be documented in this file.

## 2.1.0-beta - 2022-06-11

### Bug Fix
- Removed ```await Hive.deleteBoxFromDisk('recordings');``` from main.dart which deleted Hive

## [2.0.0-beta] - 2022-06-11

We're super excited to announce version `2.0.0-beta`! In this release we have introduced real-time transcription, no more waiting for the transcription results. Using the Virlow Speech-to-Text API Real-Time Streaming Transcription you get your interim results and final results within hundred's of milliseconds.

### Major changes
- Added new Hive features
- Removed asynchronous transcription for real-time processing with the [Virlow API](https://www.virlow.com) and [sound_stream 0.3.0](https://pub.dev/packages/sound_stream).
- Added Forked [flutter-sound-stream](https://github.com/CasperPas/flutter-sound-stream) for [Virlow Forked flutter-sound-stream](https://github.com/virlow-voice/flutter-sound-stream)
- Added live view of interim results


## 1.1.0-beta - 2022-06-01

### Minor Features
- Added the ability to share recordings outside of the application


## 1.0.4-beta - 2022-06-01

### Bug Fixes
- Removed padding when Keyboard is displayed on the __view_recording.dart__ page.
- Added timestamp to Hive record
- Added formatted timestamp to ListView in the __main.dart__ page
- Changed audio file name from user provided name to uuid 


## 1.0.2-beta - 2022-05-31

## First Release

This is __version 1.0.2-beta__ of the Virlow Recorder which includes the following features:

- Voice recorder
- Transcription
- TL;DR
- Short Hand Notes
- Rich Text Editor
- Locally saved files
- Group your recordings

[2.0.0-beta]: https://github.com/standard/standard/compare/v16.0.2...v16.0.3
