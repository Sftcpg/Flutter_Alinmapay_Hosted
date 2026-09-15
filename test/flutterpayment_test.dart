

import 'dart:io';
import 'package:yaml/yaml.dart';

void main() {
  File f = new File("../pubspec.yaml");
  f.readAsString().then((String text) {
    Map yaml = loadYaml(text);
    print(yaml['name']);
    print(yaml['description']);
    print(yaml['version']);
    print(yaml['author']);
    print(yaml['homepage']);
    print(yaml['dependencies']);
  });
}
