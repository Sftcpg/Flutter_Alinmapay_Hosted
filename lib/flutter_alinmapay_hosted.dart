library flutter_alinmapay_hosted;

export 'PaymentPage.dart';

export 'apple_pay_flutter.dart';
export 'ResponseConfig.dart';
export 'Constantvals.dart';
export 'TransactWebpage.dart';
export 'LogsUtility.dart';
export 'payment_request.dart';

import 'flutter_alinmapay_hosted_platform_interface.dart';

class FlutterAlinmapayHostedPlugin {
  Future<String?> getPlatformVersion() {
    return FlutterAlinmapayHostedPluginPlatform.instance.getPlatformVersion();
  }
}
