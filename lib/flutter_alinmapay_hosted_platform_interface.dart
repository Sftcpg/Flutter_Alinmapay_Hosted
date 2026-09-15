import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_alinmapay_hosted_method_channel.dart';

abstract class FlutterAlinmapayHostedPluginPlatform extends PlatformInterface {
  /// Constructs a FlutterAlinmapayHostedPluginPlatform.
  FlutterAlinmapayHostedPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterAlinmapayHostedPluginPlatform _instance = MethodChannelFlutterAlinmapayHostedPlugin();

  /// The default instance of [FlutterAlinmapayHostedPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterAlinmapayHostedPlugin].
  static FlutterAlinmapayHostedPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterAlinmapayHostedPluginPlatform] when
  /// they register themselves.
  static set instance(FlutterAlinmapayHostedPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
