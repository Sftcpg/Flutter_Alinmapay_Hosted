
import 'flutter_payment_plugin_platform_interface.dart';

class FlutterPaymentPlugin {
  Future<String?> getPlatformVersion() {
    return FlutterPaymentPluginPlatform.instance.getPlatformVersion();
  }
}
