import 'dart:convert';
import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
// ignore: implementation_imports
import 'package:flutter/src/widgets/text.dart' as dart_text;
import 'common.dart';
// ignore: depend_on_referenced_packages
import 'package:rxdart/rxdart.dart';
import 'package:hive/hive.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:http/http.dart' as http;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:unicons/unicons.dart';
import 'package:unicons/unicons.dart';

Map itemData = {};

// ignore: must_be_immutable
class ViewRecording extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  var hiveValue;
  double footerBoxHeight = 20.0;
  ViewRecording({Key? key, this.hiveValue}) : super(key: key);
  @override
  _ViewRecordingState createState() => _ViewRecordingState();
}

class _ViewRecordingState extends State<ViewRecording>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  late TabController tabController;
  TextEditingController controllerRecordingName =
      TextEditingController(text: "Recording Name");
  TextEditingController controllerGroup =
      TextEditingController(text: "Group Name");

  final _player = AudioPlayer();
  final _recordingBox = Hive.box('recordings');

  QuillController? _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
    ));
    _readItem(widget.hiveValue);
    _init();
  }

  Future<Map> _readItem(String key) async {
    String? tldrValue;
    String? notesValue;
    final item = _recordingBox.get(key);
    itemData = item;
    controllerRecordingName.text = item["recording_name"];
    controllerGroup.text = item["recording_group"];

    final doc = Document()
      ..insert(0,
          'Our machines are hard at work transcribing your recording. The transcription process might take a few minutes.');

    setState(() {
      _controller = QuillController(
          document: doc, selection: const TextSelection.collapsed(offset: 0));
    });

    if (!item["ai_processed"]) {
      final contents = await rootBundle.loadString(
        'assets/cfg/app_settings.json',
      );
      final json = jsonDecode(contents);
      final apiKey = json["VIRLOW_API_KEY"];
      var headers = {'Content-Type': 'application/json'};

      // Get TLDR from Virlow Audio Intelligence
      var tldrRequest = http.Request(
          'PUT',
          Uri.parse(
              "https://api.voice.virlow.com/v1-beta/ai/tldr?x-api-key=$apiKey"));

      tldrRequest.body =
          jsonEncode({"text": "\n\n Tl;dr ${item["quill_data"][9]["insert"]}"});

      tldrRequest.headers.addAll(headers);

      http.StreamedResponse tldrResponse = await tldrRequest.send();

      if (tldrResponse.statusCode == 200) {
        tldrValue = await tldrResponse.stream.bytesToString();
      }

      // Get Short Hand Notes from Virlow Audio Intelligence
      var notesRequest = http.Request(
          'PUT',
          Uri.parse(
              "https://api.voice.virlow.com/v1-beta/ai/tldr?x-api-key=$apiKey"));

      notesRequest.body = jsonEncode({
        "text":
            "Convert my short hand into a first-hand account of the meeting:\n\n ${item["quill_data"][9]["insert"]}"
      });

      notesRequest.headers.addAll(headers);

      http.StreamedResponse notesResponse = await notesRequest.send();

      if (notesResponse.statusCode == 200) {
        notesValue = await notesResponse.stream.bytesToString();
      }

      // Set TLDR Response
      var decodedTldr = jsonDecode(tldrValue!);
      item["quill_data"][3]["insert"] =
          decodedTldr["response"].replaceAll("\n", "");

      // Set Notes Response
      var decodedNotes = jsonDecode(notesValue!);
      item["quill_data"][6]["insert"] =
          decodedNotes["response"].replaceAll("\n", "");

      item["ai_processed"] = true;

      if (item["quill_data"].length == 11) {
        final doc = Document.fromJson(item["quill_data"]);
        setState(() {
          _controller = QuillController(
              document: doc,
              selection: const TextSelection.collapsed(offset: 0));
        });
      } else {
        var myJSON = jsonDecode(item["quill_data"]);
        final doc = Document.fromJson(myJSON);
        setState(() {
          _controller = QuillController(
              document: doc,
              selection: const TextSelection.collapsed(offset: 0));
        });
      }

      await _recordingBox.put(key, item);
    } else {
      if (item["quill_data"].length == 11) {
        final doc = Document.fromJson(item["quill_data"]);
        setState(() {
          _controller = QuillController(
              document: doc,
              selection: const TextSelection.collapsed(offset: 0));
        });
      } else {
        var myJSON = jsonDecode(item["quill_data"]);
        final doc = Document.fromJson(myJSON);
        setState(() {
          _controller = QuillController(
              document: doc,
              selection: const TextSelection.collapsed(offset: 0));
        });
      }
    }
    return item;
  }

  Future<void> _init() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());

    // Listen to errors during playback.
    _player.playbackEventStream
        .listen((event) {}, onError: (Object e, StackTrace stackTrace) {});

    // Try to load audio from a source and catch any errors.
    try {
      await _player.setAsset(appDocPath + "/" + itemData["file_location"]);
    } catch (e) {}
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Release decoders and buffers back to the operating system making them
    // available for other apps to use.
    _controller?.dispose();
    _player.dispose();

    super.dispose();
  }

  Future<void> _saveItem(json) async {
    final item = _recordingBox.get(widget.hiveValue);
    itemData = item;
    if (item["ai_processed"]) {
      await _recordingBox.put(widget.hiveValue, {
        "recording_name": item["recording_name"],
        "recording_group": item["recording_group"],
        "ai_processed": item["ai_processed"],
        "file_location": item["file_location"],
        "job_id": item["job_id"],
        "quill_edit": true,
        "date_time": item["date_time"],
        "results": item["results"],
        "quill_data": json,
      });
      showTopSnackBar(
        context,
        const CustomSnackBar.success(
          message: "Document Saved Successfully",
        ),
      );
    }
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget cancelButton = TextButton(
      child: const dart_text.Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: const dart_text.Text("Yes"),
      onPressed: () {
        _deleteItem(context);
        WidgetsBinding.instance.removeObserver(this);
        // Release decoders and buffers back to the operating system making them
        // available for other apps to use.
        _player.dispose();
        Navigator.pop(context);
        Navigator.of(context).pop();
        Navigator.pop(context);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const dart_text.Text("Alert"),
      content: const dart_text.Text("Would you like to delete this recording?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> _deleteItem(context) async {
    await _recordingBox.delete(widget.hiveValue);
    // _refreshItems(); // update the UI
  }

  Future<void> shareFile() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;

    await FlutterShare.shareFile(
      title: 'Virlow Recording',
      text: itemData["file_location"],
      filePath: appDocPath + "/" + itemData["file_location"],
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Release the player's resources when not in use. We use "stop" so that
      // if the app resumes later, it will still remember what position to
      // resume from.
      _player.stop();
    }
  }

  /// Collects the data useful for displaying in a seek bar, using a handy
  /// feature of rx_dart to combine the 3 streams of interest into one.

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
              _player.positionStream,
              _player.bufferedPositionStream,
              _player.durationStream,
              (position, bufferedPosition, duration) => PositionData(
                  position, bufferedPosition, duration ?? Duration.zero))
          .asBroadcastStream();

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
        customIcons: [
          QuillCustomIcon(
              icon: Icons.save,
              onTap: () {
                //TODO: check if the job has been processed
                var json = jsonEncode(_controller?.document.toDelta().toJson());
                _saveItem(json);
              }),
        ]);

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
                    Tab(icon: Icon(UniconsLine.play)),
                    Tab(icon: Icon(UniconsLine.align_left)),
                  ],
                ),
                leading: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back_ios)),
                title: const dart_text.Text('View Recording'),
                actions: <Widget>[
                  IconButton(
                    icon: const Icon(UniconsLine.ellipsis_h),
                    onPressed: () {
                      showMaterialModalBottomSheet(
                        expand: false,
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (context) => Material(
                            child: SafeArea(
                          top: false,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ListTile(
                                  title: const dart_text.Text('Save'),
                                  leading: const Icon(Icons.save_alt),
                                  onTap: () {
                                    var json = jsonEncode(_controller?.document
                                        .toDelta()
                                        .toJson());
                                    _saveItem(json);
                                  }),
                              ListTile(
                                  title: const dart_text.Text('Share'),
                                  leading: const Icon(Icons.share),
                                  onTap: () {
                                    shareFile();
                                  }),
                              ListTile(
                                title: const dart_text.Text('Delete'),
                                leading: const Icon(Icons.delete),
                                onTap: () {
                                  showAlertDialog(context);
                                  // Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        )),
                      );
                    },
                  )
                ],
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
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Recording Name',
                            // errorText: 'Error message',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: controllerGroup,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Group',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(
                          height: 100,
                        ),
                        // Display play/pause button and volume/speed sliders.
                        ControlButtons(_player),
                        // Display seek bar. Using StreamBuilder, this widget rebuilds
                        // each time the position, buffered position or duration changes.
                        StreamBuilder<PositionData>(
                          stream: _positionDataStream,
                          builder: (context, snapshot) {
                            final positionData = snapshot.data;
                            return SeekBar(
                              duration: positionData?.duration ?? Duration.zero,
                              position: positionData?.position ?? Duration.zero,
                              bufferedPosition:
                                  positionData?.bufferedPosition ??
                                      Duration.zero,
                              onChangeEnd: _player.seek,
                            );
                          },
                        ),
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

  @override
  bool get wantKeepAlive => true;
}

/// Displays the play/pause button and volume/speed sliders.
class ControlButtons extends StatelessWidget {
  final AudioPlayer player;

  const ControlButtons(this.player, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Opens volume slider dialog
        IconButton(
          icon: const Icon(Icons.volume_up),
          onPressed: () {
            showSliderDialog(
              context: context,
              title: "Adjust volume",
              divisions: 10,
              min: 0.0,
              max: 1.0,
              value: player.volume,
              stream: player.volumeStream,
              onChanged: player.setVolume,
            );
          },
        ),

        /// This StreamBuilder rebuilds whenever the player state changes, which
        /// includes the playing/paused state and also the
        /// loading/buffering/ready state. Depending on the state we show the
        /// appropriate button or loading indicator.
        StreamBuilder<PlayerState>(
          stream: player.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final processingState = playerState?.processingState;
            final playing = playerState?.playing;
            if (processingState == ProcessingState.loading ||
                processingState == ProcessingState.buffering) {
              return Container(
                margin: const EdgeInsets.all(8.0),
                width: 64.0,
                height: 64.0,
                child: const CircularProgressIndicator(),
              );
            } else if (playing != true) {
              return IconButton(
                icon: const Icon(Icons.play_arrow),
                iconSize: 64.0,
                onPressed: player.play,
              );
            } else if (processingState != ProcessingState.completed) {
              return IconButton(
                icon: const Icon(Icons.pause),
                iconSize: 64.0,
                onPressed: player.pause,
              );
            } else {
              return IconButton(
                icon: const Icon(Icons.replay),
                iconSize: 64.0,
                onPressed: () => player.seek(Duration.zero),
              );
            }
          },
        ),
        // Opens speed slider dialog
        StreamBuilder<double>(
          stream: player.speedStream,
          builder: (context, snapshot) => IconButton(
            icon: dart_text.Text("${snapshot.data?.toStringAsFixed(1)}x",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              showSliderDialog(
                context: context,
                title: "Adjust speed",
                divisions: 10,
                min: 0.5,
                max: 1.5,
                value: player.speed,
                stream: player.speedStream,
                onChanged: player.setSpeed,
              );
            },
          ),
        ),
      ],
    );
  }
}
