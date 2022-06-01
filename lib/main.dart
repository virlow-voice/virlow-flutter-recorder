import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'add_recording.dart';
import 'view_recording.dart';
import 'settings.dart';

void main() async {
  await Hive.initFlutter();

  // ** Dangerous ** Deletes all the files locally on the device
  // await Hive.deleteBoxFromDisk('recordings');

  await Hive.openBox('recordings');
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DismissKeyboard(
      child: MaterialApp(
        title: 'Virlow Recorder',
        theme: ThemeData(
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
          primaryColor: Colors.blue,
          accentColor: Colors.white,
          /* dark theme settings */
        ), // standard dark theme

        home: const MyHomePage(title: 'Virlow Recorder'),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    _refreshItems(); // Load data when app starts
  }

  List<Map<String, dynamic>> _items = [];
  final _recordingBox = Hive.box('recordings');

  // Get all items from the database
  void _refreshItems() {
    final data = _recordingBox.keys.map((key) {
      final value = _recordingBox.get(key);
      return {
        "key": key,
        "name": value["name"],
        "group": value["group"],
        "date_time": value["date_time"],
        "results": value['results'],
        "file_processed": value["file_processed"],
        "results_processed": value["results_processed"]
      };
    }).toList();

    setState(() {
      _items = data.reversed.toList();
    });
  }

  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        primaryColor: Colors.blue,
        accentColor: Colors.white,
        /* dark theme settings */
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.settings,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Settings()),
                ).then((value) => setState(() {
                      _refreshItems();
                    }));
              },
            )
          ],
        ),
        body: GroupedListView<dynamic, String>(
          elements: _items,
          groupBy: (element) => element['group'],
          groupComparator: (value1, value2) => value2.compareTo(value1),
          itemComparator: (item1, item2) =>
              item1['name'].compareTo(item2['name']),
          order: GroupedListOrder.DESC,
          useStickyGroupSeparators: false,
          groupSeparatorBuilder: (String value) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          itemBuilder: (c, element) {
            return Card(
              elevation: 8.0,
              margin:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                leading: const Icon(Icons.audio_file_outlined),
                title: Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(element['name']),
                ),
                subtitle: Text(element['date_time']),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ViewRecording(
                              hiveValue: element["key"],
                            )),
                  ).then((value) => setState(() {
                        _refreshItems();
                      }));
                },
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddRecording()),
          ).then((value) => setState(() {
                _refreshItems();
              })),
          tooltip: 'Add Recording',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class DismissKeyboard extends StatelessWidget {
  final Widget child;
  const DismissKeyboard({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: child,
    );
  }
}
