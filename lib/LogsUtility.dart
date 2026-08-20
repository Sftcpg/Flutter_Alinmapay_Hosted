import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yaml/yaml.dart';
// import 'package:path/path.dart' as path;

class LogsUtility {


  static Future<void> getFlutterVersion() async {
    try {
      // Read the pubspec.lock file
      final file = File('pubspec.lock');
      if (await file.exists()) {
        final content = await file.readAsString();
        final yaml = jsonDecode(jsonEncode(loadYaml(content)));

        // Access the Flutter version under 'sdks'
        final sdks = yaml['sdks'];
        return sdks?['flutter'];
      }
    } catch (e) {
      print('Error fetching Flutter version: $e');
    }
  }


  static Future<void> getAppLogs(BuildContext context) async
  {
    final projectRoot = Directory.current.path;
    print('Project projectRoot: $projectRoot');

    final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
    print('Project Root Directory: $appDocumentsDir');
    String text = await DefaultAssetBundle.of(context).loadString(
        'assets/appconfig.json');

    final jsonResponse = json.decode(text);
    var projectpath = jsonResponse["projectpath"] as String;
    print('Flutter path: $projectpath');


    // getGradleVersion();
    getFlutterVersion();
  }
}

