import 'dart:async';
import 'dart:math';
import 'package:hive/hive.dart';

class BackendService {
  static Future<List<Map<String, String>>> getSuggestions(String query) async {
    await Future<void>.delayed(const Duration(seconds: 1));

    return List.generate(3, (index) {
      return {
        'name': query + index.toString(),
        'price': Random().nextInt(100).toString()
      };
    });
  }
}

Future<List<String>> getGroupsNamesHive() async {
  final box = await Hive.openBox('recordings');
  final result = box.values.cast<Map>();
  List<String> groups = <String>[];

  for (Map element in result) {
    if (element["recording_group"].length != 0) {
      groups.add(element["recording_group"]);
    }
  }
  return groups;
}

class GroupNames {
  static final List<String> groups = ['Personal', 'School', 'Work'];

  static Future<List<String>> getGroups(String query) async {
    List<String> matches = <String>[];
    matches.addAll(groups);

    List<String> values = await getGroupsNamesHive();
    matches.addAll(values);
    matches.retainWhere((s) => s.toLowerCase().contains(query.toLowerCase()));
    matches.sort((a, b) => a.toString().compareTo(b.toString()));

    // Remove duplicates
    final ids = matches.map((e) => e).toSet();
    matches.retainWhere((x) => ids.remove(x));
    return matches;
  }
}
