# Changelog

All notable changes to this project will be documented in this file.

## [2.2.0-beta] - 2022-06-25

### Minor changes

- Graphical changes to include new icons and a settings page.

- Introducing sync to cloud which will include, available in 2.3.0:
    - AWS Cognito authentication
    - DynamoDB for record metadata and transcription
    - S3 for audio file storage

#### AWS Cognito authentication

## 2.1.1-beta - 2022-06-12

### Bug Fix
- Fixed - [Bluetooth Recording #2](https://github.com/virlow-voice/virlow-flutter-recorder/issues/2)

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

[2.2.0-beta]: https://github.com/virlow-voice/virlow-flutter-recorder/commit/2be9597f82c1801c527e4c7dc08cab0dfd8bfceb
[2.0.0-beta]: https://github.com/virlow-voice/virlow-flutter-recorder/commit/905c5f468a94f32d1de98cef9884680d41f84f9a