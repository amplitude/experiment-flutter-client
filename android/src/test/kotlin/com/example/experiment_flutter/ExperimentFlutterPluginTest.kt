package com.example.experiment_flutter

import android.content.Context
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import org.mockito.Mockito
import kotlin.test.Test

/*
 * This demonstrates a simple unit test of the Kotlin portion of this plugin's implementation.
 *
 * Once you have built the plugin's example app, you can run these tests from the command
 * line by running `./gradlew testDebugUnitTest` in the `example/android/` directory, or
 * you can run them directly from IDEs that support JUnit such as Android Studio.
 */

internal class ExperimentFlutterPluginTest {

    @Test
    fun onMethodCall_getPlatformVersion_returnsExpectedValue() {
        val plugin = ExperimentFlutterPlugin()

        val call = MethodCall("getPlatformVersion", null)
        val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)
        plugin.onMethodCall(call, mockResult)

        Mockito.verify(mockResult).success("Android " + android.os.Build.VERSION.RELEASE)
    }

    @Test
    fun onMethod_test() {
        val plugin = ExperimentFlutterPlugin()

        val call = MethodCall("test", JSONObject(mapOf("apiKey" to "DEPLOY_KEY")))
        val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)
        plugin.onMethodCall(call, mockResult)

        Mockito.verify(mockResult).success("{\n" +
                "    \"cta\": {\n" +
                "        \"key\": \"Please Login.\",\n" +
                "        \"metadata\": {\n" +
                "            \"evaluationId\": \"1388907677979_1766085182784_2718\",\n" +
                "            \"experimentKey\": \"exp-1\"\n" +
                "        },\n" +
                "        \"value\": \"Please Login.\"\n" +
                "    }\n" +
                "}")
    }
}
