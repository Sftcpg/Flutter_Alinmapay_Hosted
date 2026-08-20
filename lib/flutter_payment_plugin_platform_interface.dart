import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_payment_plugin_method_channel.dart';

abstract class FlutterPaymentPluginPlatform extends PlatformInterface {
  /// Constructs a FlutterPaymentPluginPlatform.
  FlutterPaymentPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterPaymentPluginPlatform _instance = MethodChannelFlutterPaymentPlugin();

  /// The default instance of [FlutterPaymentPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterPaymentPlugin].
  static FlutterPaymentPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterPaymentPluginPlatform] when
  /// they register themselves.
  static set instance(FlutterPaymentPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
