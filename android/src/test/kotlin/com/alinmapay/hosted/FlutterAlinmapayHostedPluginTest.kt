package com.alinmapay.hosted

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlin.test.Test
import org.mockito.Mockito

/*
 * This demonstrates a simple unit test of the Kotlin portion of this plugin's implementation.
 *
 * Once you have built the plugin's Android part, you can run this test from the command line by running:
 *   ./gradlew testDebugUnitTest
 *
 * In Android Studio, you can run this test by right-clicking on this file and selecting "Run 'FlutterAlinmapayHostedPluginTest'".
 */
internal class FlutterAlinmapayHostedPluginTest {
  @Test
  fun onMethodCall_getPlatformVersion_returnsExpectedValue() {
    val plugin = FlutterAlinmapayHostedPlugin()

    val call = MethodCall("getPlatformVersion", null)
    val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)
    plugin.onMethodCall(call, mockResult)

    Mockito.verify(mockResult).success("Android " + android.os.Build.VERSION.RELEASE)
  }
}
