# Virlow Flutter Recorder

__Version 2.0.0-beta__

The __Virlow Flutter Recorder__ is an open-source Flutter application that can transcribe recorded audio, plus it includes TL;DR and Short Hand Notes for your transcription. It also consists of a rich text editor that allows you to edit the transcription plus add any additional notes you require.

## __Virlow Flutter Recorder__ has been tested for iOS.

![](virlow.gif)

## Features
* Voice recorder
* __Transcribe__ your recordings
* __TL;DR__ which helps you summarize your transcribed audio file into concise, easy-to-digest content so you can free yourself from information overload.
* With __Short Hand Notes__, you can turn your transcribed audio file into concise notes for an easy-to-read summary.
* Rich Text Editor
* Locally saved files
* Group your recordings

The __Virlow Flutter Recorder__ leverages the [Virlow Speech-to-Text API](https://www.virlow.com) for transcription as well as TL;DR and Short Hand Notes. The Virlow API can automatically convert audio/video files and live audio streams to text with Virlow’s Speech-to-Text APIs. Powered by cutting edge AI models.

## Getting Started with the OSS

1. Find instructions for setting up your development machine with the Flutter framework on Flutter’s [Get started](https://flutter.dev/docs/get-started/install) page. The specific steps vary by platform

1. This project uses the [Virlow Speech-to-Text API](https://www.virlow.com). You will need to register and generate an API key to use this within your own project.

1. To run your project, you’ll need to use one of the following options:
    * Run either iOS Simulator or an Android emulator.
    * Have an iOS or Android device set up for development

1. Clone this repository.

1. Update the `assets/cfg/app_settings.json` with your Virlow API key.

1. Run `flutter pub get`.

1. In VS Code select a platform — for example, the Pixel mobile emulator — and wait while the emulator launches.

1. Once the emulator is ready, build and run by pressing F5, by selecting Debug ▸ Start Debugging from the menu or by clicking the triangular Play icon in the top right.


## [Change Log](https://github.com/virlow-voice/virlow-flutter-recorder/blob/main/CHANGELOG.md)