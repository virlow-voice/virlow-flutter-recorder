import 'dart:convert';
import 'package:flutter/services.dart';

Future<String> getApiKey() async {
  final contents = await rootBundle.loadString(
    'assets/cfg/app_settings.json',
  );
  final json = jsonDecode(contents);
  final apiKey = json["VIRLOW_API_KEY"];

  print(apiKey);

  return apiKey;
}
