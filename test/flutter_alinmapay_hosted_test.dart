import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_alinmapay_hosted/flutter_alinmapay_hosted.dart';
import 'package:flutter_alinmapay_hosted/flutter_alinmapay_hosted_platform_interface.dart';
import 'package:flutter_alinmapay_hosted/flutter_alinmapay_hosted_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterAlinmapayHostedPluginPlatform
    with MockPlatformInterfaceMixin
    implements FlutterAlinmapayHostedPluginPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterAlinmapayHostedPluginPlatform initialPlatform = FlutterAlinmapayHostedPluginPlatform.instance;

  test('$MethodChannelFlutterAlinmapayHostedPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterAlinmapayHostedPlugin>());
  });

  test('getPlatformVersion', () async {
    FlutterAlinmapayHostedPlugin flutterAlinmapayHostedPlugin = FlutterAlinmapayHostedPlugin();
    MockFlutterAlinmapayHostedPluginPlatform fakePlatform = MockFlutterAlinmapayHostedPluginPlatform();
    FlutterAlinmapayHostedPluginPlatform.instance = fakePlatform;

    expect(await flutterAlinmapayHostedPlugin.getPlatformVersion(), '42');
  });
}
