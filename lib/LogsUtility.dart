import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yaml/yaml.dart';

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
        final version = sdks?['flutter'] as String?;
        debugPrint('Flutter version: $version');
      }
    } catch (_) {
      // debugPrint('Error fetching Flutter version: $e');
    }
  }


  static Future<void> getAppLogs(BuildContext context) async
  {
    final projectRoot = Directory.current.path;
    debugPrint('Project projectRoot: $projectRoot');

    final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
    debugPrint('Project Root Directory: ${appDocumentsDir.path}');
    String text = await DefaultAssetBundle.of(context).loadString(
        'assets/appconfig.json');

    final jsonResponse = json.decode(text);
    var projectpath = jsonResponse["projectpath"] as String;
    debugPrint('Flutter path: $projectpath');


    // getGradleVersion();
    getFlutterVersion();
  }
}
