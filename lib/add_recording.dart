import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'data/group_names.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:http/http.dart' as http;

DateTime now = DateTime.now();
typedef _Fn = void Function();
const theSource = AudioSource.microphone;

String recordingName =
    "${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}-${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}";

class AddRecording extends StatefulWidget {
  const AddRecording({Key? key}) : super(key: key);
  @override
  _AddRecordingState createState() => _AddRecordingState();
}

class _AddRecordingState extends State<AddRecording>
    with SingleTickerProviderStateMixin {
  final _recordingBox = Hive.box('recordings');
  TextEditingController controllerRecordingName =
      TextEditingController(text: recordingName);
  TextEditingController controllerGroup =
      TextEditingController(text: "Personal");
  final TextEditingController _typeAheadController = TextEditingController();
  Codec _codec = Codec.pcm16WAV;
  final FlutterSoundPlayer? _mPlayer = FlutterSoundPlayer();
  FlutterSoundRecorder? _mRecorder = FlutterSoundRecorder();
  bool _mRecorderIsInited = false;

  // Recording Animation
  late AnimationController _animationController;
  late Animation _animation;
  late Animation _animationPause;

  String completePath = "";
  String directoryPath = "";
  String recorderStatus = "";
  bool recordingStarted = false;

  @override
  void initState() {
    openTheRecorder().then((value) {
      setState(() {
        _mRecorderIsInited = true;
      });
    });

    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _animationController.repeat(reverse: true);
    _animation = Tween(begin: 0.0, end: 0.0).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });

    _animationPause = Tween(begin: 0.0, end: 0.0).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });

    super.initState();
  }

  @override
  void dispose() {
    _mRecorder!.closeRecorder();
    _mRecorder = null;
    _animationController.dispose();
    super.dispose();
  }

  void startAnimation() {
    _animation = Tween(begin: 2.0, end: 12.0).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });
  }

  void stopAnimation() {
    _animation = Tween(begin: 0.0, end: 0.0).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });
  }

  void startPauseAnimation() {
    _animationPause = Tween(begin: 2.0, end: 12.0).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });
  }

  void stopPauseAnimation() {
    _animationPause = Tween(begin: 0.0, end: 0.0).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });
  }

  Future<void> openTheRecorder() async {
    if (!kIsWeb) {
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        throw RecordingPermissionException('Microphone permission not granted');
      }
    }
    await _mRecorder!.openRecorder();
    if (!await _mRecorder!.isEncoderSupported(_codec) && kIsWeb) {
      _codec = Codec.opusWebM;
      // _mPath = recordingName;
      if (!await _mRecorder!.isEncoderSupported(_codec) && kIsWeb) {
        _mRecorderIsInited = true;
        return;
      }
    }
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.allowBluetooth |
              AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));

    _mRecorderIsInited = true;
  }

  void record() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    recordingStarted = true;
    if (!_mRecorder!.isPaused) {
      _mRecorder!
          .startRecorder(
        toFile:
            "$appDocPath/${controllerRecordingName.value.text.replaceAll(' ', '')}.wav",
        codec: _codec,
        audioSource: theSource,
      )
          .then((value) {
        setState(() {});
      });
    } else {
      _mRecorder!.resumeRecorder().then((value) {
        setState(() {});
      });
    }
    recorderStatus = "Recording";
  }

  void pause() async {
    await _mRecorder!.pauseRecorder().then((value) {
      setState(() {});
    });
    recorderStatus = "Paused";
  }

  void stopRecorder() async {
    await _mRecorder!.stopRecorder().then((value) {
      setState(() {});
    });
  }

  Future<void> _createItem(String name, String group) async {
    await _mRecorder!.stopRecorder().then((value) {
      setState(() {});
    });

    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    final contents = await rootBundle.loadString(
      'assets/cfg/app_settings.json',
    );
    final json = jsonDecode(contents);
    final apiKey = json["VIRLOW_API_KEY"];
    var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.voice.virlow.com/v1-beta/transcript?x-api-key=' +
            apiKey));
    request.fields.addAll({
      'dual_channel': 'false',
      'punctuate': 'true',
      'webhook_url': '',
      'speaker_diarization': 'false',
      'language': 'enUs',
      'short_hand_notes': 'true',
      'tldr': 'true',
      'custom': 'VIRLOW_RECODER'
    });

    request.files.add(await http.MultipartFile.fromPath("audio",
        "$appDocPath/${controllerRecordingName.value.text.replaceAll(' ', '')}.wav"));

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    final result = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      await _recordingBox.add({
        "name": name,
        "group": group,
        "results_processed": false,
        "file_location":
            "${controllerRecordingName.value.text.replaceAll(' ', '')}.wav",
        "job_id": result["id"],
        "quill_edit": false,
        "results": {"data": "data"},
        "quill_data": [],
      });
    } else {}

    Navigator.pop(context);
  }

  void _save() {
    _createItem(
        controllerRecordingName.value.text, _typeAheadController.value.text);
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_ios)),
          title: const Text('Add Recording'),
        ),
        body: ProgressHUD(
            barrierEnabled: true,
            barrierColor: Colors.black54,
            backgroundRadius: const Radius.circular(8.0),
            padding: const EdgeInsets.all(50.0),
            backgroundColor: Color.fromARGB(0, 255, 255, 255),
            borderColor: Color.fromARGB(0, 255, 255, 255),
            child: Builder(
              builder: (context) => Padding(
                padding: const EdgeInsets.only(
                    left: 8.0, top: 20.0, right: 8.0, bottom: 8.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: controllerRecordingName,
                      decoration: InputDecoration(
                        labelText: 'Recording Name',
                        // errorText: 'Error message',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          onPressed: () {
                            controllerRecordingName.clear();
                          },
                          icon: const Icon(Icons.clear),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TypeAheadFormField(
                      hideOnEmpty: true,
                      textFieldConfiguration: TextFieldConfiguration(
                        decoration: InputDecoration(
                          labelText: 'Group Name',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            onPressed: () {
                              _typeAheadController.clear();
                            },
                            icon: const Icon(Icons.clear),
                          ),
                        ),
                        controller: _typeAheadController,
                      ),
                      suggestionsCallback: (pattern) {
                        return GroupNames.getGroups(pattern);
                        // GroupsService.getSuggestions(pattern);
                      },
                      itemBuilder: (context, String suggestion) {
                        return ListTile(
                          title: Text(suggestion),
                        );
                      },
                      transitionBuilder: (context, suggestionsBox, controller) {
                        return suggestionsBox;
                      },
                      onSuggestionSelected: (String suggestion) {
                        _typeAheadController.text = suggestion;
                      },
                      validator: (value) =>
                          value!.isEmpty ? 'Please select a Group Name' : null,
                      onSaved: (value) => print(value),
                    ),
                    const SizedBox(
                      height: 130,
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue,
                                boxShadow: [
                                  BoxShadow(
                                      color: const Color.fromARGB(
                                          150, 237, 125, 58),
                                      blurRadius: _animationPause.value,
                                      spreadRadius: _animationPause.value)
                                ]),
                            child: IconButton(
                              icon: const Icon(Icons.pause),
                              color: Colors.white,
                              onPressed: () {
                                stopAnimation();
                                startPauseAnimation();
                                pause();
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 30,
                          ),
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue,
                                boxShadow: [
                                  BoxShadow(
                                      color: const Color.fromARGB(
                                          150, 237, 125, 58),
                                      blurRadius: _animation.value,
                                      spreadRadius: _animation.value)
                                ]),
                            child: IconButton(
                              icon: const Icon(Icons.mic),
                              iconSize: 45,
                              color: Colors.white,
                              onPressed: () {
                                if (_mRecorder!.isRecording) {
                                  stopAnimation();
                                  startPauseAnimation();
                                  pause();
                                } else {
                                  startAnimation();
                                  stopPauseAnimation();
                                  record();
                                }
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 30,
                          ),
                          Container(
                            width: 50,
                            height: 50,
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue,
                                boxShadow: [
                                  BoxShadow(
                                      color: Color.fromARGB(130, 237, 125, 58),
                                      blurRadius: 0,
                                      spreadRadius: 0)
                                ]),
                            child: IconButton(
                              icon: const Icon(Icons.save_alt),
                              color: Colors.white,
                              onPressed: () {
                                stopAnimation();
                                final progress = ProgressHUD.of(context);
                                progress?.show();
                                _save();
                              },
                            ),
                          ),
                        ]),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(recorderStatus), //last one
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )));
  }
}
