import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_payment_plugin/flutter_payment_plugin.dart';
import 'package:flutter_payment_plugin/flutter_payment_plugin_platform_interface.dart';
import 'package:flutter_payment_plugin/flutter_payment_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterPaymentPluginPlatform
    with MockPlatformInterfaceMixin
    implements FlutterPaymentPluginPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterPaymentPluginPlatform initialPlatform = FlutterPaymentPluginPlatform.instance;

  test('$MethodChannelFlutterPaymentPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterPaymentPlugin>());
  });

  test('getPlatformVersion', () async {
    FlutterPaymentPlugin flutterPaymentPlugin = FlutterPaymentPlugin();
    MockFlutterPaymentPluginPlatform fakePlatform = MockFlutterPaymentPluginPlatform();
    FlutterPaymentPluginPlatform.instance = fakePlatform;

    expect(await flutterPaymentPlugin.getPlatformVersion(), '42');
  });
}
