import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_alinmapay_hosted_platform_interface.dart';

/// An implementation of [FlutterAlinmapayHostedPluginPlatform] that uses method channels.
class MethodChannelFlutterAlinmapayHostedPlugin extends FlutterAlinmapayHostedPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_alinmapay_hosted');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
