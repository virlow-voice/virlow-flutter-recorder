// import 'dart:async';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:sound_stream/sound_stream.dart';
// ignore: depend_on_referenced_packages
// import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'data/group_names.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_quill/flutter_quill.dart';
// ignore: implementation_imports
import 'package:flutter/src/widgets/text.dart' as dart_text;
import 'package:socket_io_client/socket_io_client.dart' as IO;
// ignore: depend_on_referenced_packages
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';
import 'globals.dart';

Map itemData = {};
AudioSource theSource = AudioSource.microphone;

// ignore: must_be_immutable
class AddRecording extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  var hiveValue;
  double footerBoxHeight = 20.0;
  AddRecording({Key? key, this.hiveValue}) : super(key: key);
  @override
  // ignore: library_private_types_in_public_api
  _AddRecordingState createState() => _AddRecordingState();
}

class _AddRecordingState extends State<AddRecording>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final _recordingBox = Hive.box('recordings');
  TextEditingController controllerRecordingName = TextEditingController();
  TextEditingController controllerGroup =
      TextEditingController(text: "Personal");
  final TextEditingController _typeAheadController = TextEditingController();

  late String virlowUuid;

  // Recording Animation
  late AnimationController _animationController;
  late Animation _animation;
  late Animation _animationPause;

  String completePath = "";
  String directoryPath = "";
  String recorderStatus = "";
  bool recordingStarted = false;

  // Virlow API
  IO.Socket? socket;

  // flutter_sound
  final Codec _codec = Codec.pcm16WAV;
  FlutterSoundRecorder? _mRecorder = FlutterSoundRecorder();

  // sound_stream
  final RecorderStream _recorder = RecorderStream();

  bool _isRecording = false;

  late StreamSubscription _recorderStatus;
  StreamSubscription? _audioStream;

  bool isRecordingNameValidate = true;

  QuillController? _controller;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    var uuid = Uuid();
    setState(() {
      virlowUuid = uuid.v1();
    });

    _recorderStatus = _recorder.status.listen((status) {
      if (mounted) {
        setState(() {
          _isRecording = status == SoundStreamStatus.Playing;
        });
      }
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

    final doc = Document()
      ..insert(0,
          'Our AI Models will start working hard to transcribe your recording once you start recording.');

    setState(() {
      _controller = QuillController(
          document: doc, selection: const TextSelection.collapsed(offset: 0));
    });

    super.initState();

    _openRecorder();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    // _recorder.dispose();
    _recorderStatus.cancel();
    _audioStream?.cancel();
    _mRecorder!.closeRecorder();
    _mRecorder = null;
    _mRecorder?.stopRecorder();
    socket?.close();
    super.dispose();
  }

  String getDateTimeNow() {
    return DateFormat.yMMMEd().add_jm().format(DateTime.now());
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

  void pause() async {
    await _mRecorder!.pauseRecorder().then((value) {
      setState(() {});
    });

    _recorder.stop();

    recorderStatus = "Paused";
  }

  void stopRecorder() async {
    await _mRecorder?.stopRecorder().then((value) {
      setState(() {});
    });
  }

  Future<void> _openRecorder() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }
    await _mRecorder!.openRecorder();

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
  }

  void record() async {
    if (!_mRecorder!.isPaused) {
      var json = [
        {
          "insert": controllerRecordingName.value.text,
          "attributes": {"bold": true, "size": "large"},
        },
        {"insert": "\n"},
        {
          "insert": "\nTL;DR\n",
          "attributes": {"bold": true},
        },
        {"insert": "TL;DR will be completed after the recording is complete."},
        {"insert": "\n"},
        {
          "insert": "\nShort Hand Notes\n",
          "attributes": {"bold": true},
        },
        {
          "insert":
              "Short Hand Notes will be completed after the recording is complete."
        },
        {"insert": "\n"},
        {
          "insert": "\nTranscript\n",
          "attributes": {"bold": true},
        },
        {"insert": ""},
        {"insert": "\n"},
      ];

      await _recordingBox.put(virlowUuid, {
        "id": virlowUuid,
        "recording_name": controllerRecordingName.value.text,
        "recording_group": controllerRecordingName.value.text,
        "virlow_ai_processed": false,
        "file_location": "$virlowUuid.wav",
        "ai_processed": false,
        "results": {},
        "quill_data": json,
        "date_time": getDateTimeNow(),
      });

      initSocketStream(virlowUuid);
      _recorder.start();

      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      recordingStarted = true;
      if (!_mRecorder!.isPaused) {
        _mRecorder!
            .startRecorder(
          toFile: "$appDocPath/$virlowUuid.wav",
          codec: _codec,
          audioSource: theSource,
        )
            .then((value) {
          setState(() {});
        });
      }
    } else {
      _mRecorder!.resumeRecorder().then((value) {
        setState(() {});
      });
      _recorder.start();
    }
    recorderStatus = "Recording";
  }

  Future<Map<String, dynamic>> getHiveItems(key) async {
    Map<String, dynamic> item = await _recordingBox.get(key);
    return item;
  }

  void saveHiveItems(key, json, virlowUuid) async {
    await _recordingBox.put(virlowUuid, {
      "id": virlowUuid,
      "recording_name": controllerRecordingName.value.text,
      "recording_group": controllerRecordingName.value.text,
      "virlow_ai_processed": false,
      "file_location": "$virlowUuid.wav",
      "ai_processed": false,
      "results": {},
      "quill_data": json,
      "date_time": getDateTimeNow(),
    });
  }

  Future<void> initSocketStream(String key) async {
    await Future.wait([
      _recorder.initialize(),
    ]);

    String apiKey = await getApiKey();
    socket = IO.io(
        'https://api.voice.virlow.com/?x-api-key=$apiKey',
        OptionBuilder().setTransports(['websocket']) // for Flutter or Dart VM
            .build());

    _audioStream = _recorder.audioStream.listen((data) {
      socket?.emit("audio_in", data);
    });

    socket?.on("transcript", (data) async {
      if (data["is_final"]) {
        Map<String, dynamic> item = await getHiveItems(key);
        final quillStart = item["quill_data"].length - 2;

        if (item["quill_data"][quillStart]["insert"] == "") {
          item["quill_data"][quillStart]["insert"] = data["transcript"];
        } else {
          item["quill_data"][quillStart]["insert"] = item["quill_data"]
                  [quillStart]["insert"] +
              "" +
              data["transcript"];
        }
        var json = item["quill_data"];
        final doc = Document.fromJson(json);
        setState(() {
          _controller = QuillController(
              document: doc,
              selection: const TextSelection.collapsed(offset: 0));
        });
        saveHiveItems(key, json, virlowUuid);
      } else {
        Map<String, dynamic> item = await getHiveItems(key);
        final quillStart = item["quill_data"].length - 2;
        var json = [
          {
            "insert": controllerRecordingName.value.text,
            "attributes": {"bold": true, "size": "large"},
          },
          {"insert": "\n"},
          {
            "insert": "\nTL;DR\n",
            "attributes": {"bold": true},
          },
          {
            "insert": "TL;DR will be completed after the recording is complete."
          },
          {"insert": "\n"},
          {
            "insert": "\nShort Hand Notes\n",
            "attributes": {"bold": true},
          },
          {
            "insert":
                "Short Hand Notes will be completed after the recording is complete."
          },
          {"insert": "\n"},
          {
            "insert": "\nTranscript\n",
            "attributes": {"bold": true},
          },
          {
            "insert":
                item["quill_data"][quillStart]["insert"] + data["transcript"]
          },
          {"insert": "\n"},
        ];

        final doc = Document.fromJson(json);
        setState(() {
          _controller = QuillController(
              document: doc,
              selection: const TextSelection.collapsed(offset: 0));
        });
      }
    });
  }

  bool validateRecordingName() {
    if ((controllerRecordingName.value.text.length > 1) &&
        controllerRecordingName.value.text.isNotEmpty) {
      setState(() {
        isRecordingNameValidate = true;
      });
      return true;
    } else {
      setState(() {
        isRecordingNameValidate = false;
      });
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // iPhone Notch for Editor Toolbar
    if (MediaQuery.of(context).viewInsets.bottom > 0.0) {
      setState(() {
        widget.footerBoxHeight = 2;
      });
    } else {
      setState(() {
        widget.footerBoxHeight = 25;
      });
    }

    if (_controller == null) {
      return const Scaffold(body: Center(child: dart_text.Text('Loading...')));
    }

    var toolbar = QuillToolbar.basic(
      controller: _controller!,
      showCameraButton: false,
      showImageButton: false,
      showVideoButton: false,
      showAlignmentButtons: true,
      showCodeBlock: false,
      showColorButton: false,
      showQuote: false,
      showStrikeThrough: false,
      showBackgroundColorButton: false,
      showLink: false,
      showFontSize: false,
      showIndent: false,
      showInlineCode: false,
    );

    var quillEditor = QuillEditor(
      controller: _controller!,
      scrollController: ScrollController(),
      scrollable: true,
      autoFocus: false,
      readOnly: false,
      placeholder: 'Add content',
      expands: false,
      padding: const EdgeInsets.all(10),
      focusNode: FocusNode(),
    );
    return DefaultTabController(
      length: 2,
      child: SafeArea(
          bottom: false,
          top: false,
          child: Scaffold(
              appBar: AppBar(
                bottom: const TabBar(
                  // controller: tabController,
                  tabs: [
                    Tab(icon: Icon(Icons.mic)),
                    Tab(icon: Icon(Icons.notes_rounded)),
                  ],
                ),
                leading: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back_ios)),
                title: const dart_text.Text('Add Recording'),
              ),
              body: TabBarView(
                children: <Widget>[
                  SingleChildScrollView(
                    padding: const EdgeInsets.only(
                        left: 8.0, top: 20.0, right: 8.0, bottom: 50.0),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: controllerRecordingName,
                          validator: (value) => value!.isEmpty
                              ? 'Please select a Group Name'
                              : null,
                          decoration: InputDecoration(
                            labelText: 'Recording Name',
                            errorText: !isRecordingNameValidate
                                ? 'Please enter a Recording Name'
                                : null,
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
                              title: dart_text.Text(suggestion),
                            );
                          },
                          transitionBuilder:
                              (context, suggestionsBox, controller) {
                            return suggestionsBox;
                          },
                          onSuggestionSelected: (String suggestion) {
                            _typeAheadController.text = suggestion;
                          },
                          validator: (value) => value!.isEmpty
                              ? 'Please select a Group Name'
                              : null,
                          onSaved: (value) => print(value),
                        ),
                        const SizedBox(
                          height: 100,
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
                                width: 20,
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
                                    print(validateRecordingName());
                                    if (validateRecordingName()) {
                                      if (_mRecorder!.isRecording) {
                                        stopAnimation();
                                        startPauseAnimation();
                                        pause();
                                      } else {
                                        startAnimation();
                                        stopPauseAnimation();
                                        record();
                                      }
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(
                                width: 75,
                              ),
                            ]),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Expanded(
                        child: Container(child: quillEditor),
                      ),
                      Container(child: toolbar),
                      SizedBox(
                        height: widget.footerBoxHeight,
                      ),
                    ],
                  )
                ],
              ))),
    );
  }
}
