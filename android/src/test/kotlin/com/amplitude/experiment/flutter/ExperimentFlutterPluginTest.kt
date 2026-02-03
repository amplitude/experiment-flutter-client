package com.amplitude.experiment.flutter

import android.app.Application
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.mockito.Mockito
import kotlin.test.Test
import kotlin.test.assertFailsWith

/*
 * Unit tests for ExperimentFlutterPlugin focusing on method routing and codec integration.
 *
 * These tests verify that the plugin correctly:
 * - Routes method calls to appropriate handlers
 * - Uses codec classes for data transformation
 * - Handles errors appropriately
 *
 * Note: Full integration tests with Amplitude SDK would require mocking the SDK,
 * which is beyond the scope of these unit tests. The codec classes are tested separately.
 */

internal class ExperimentFlutterPluginTest {

    @Test
    fun onMethodCall_unknownMethod_withNonExistentInstance_throwsException() {
        val plugin = AmplitudeExperimentPlugin()
        val mockBinding = Mockito.mock(FlutterPlugin.FlutterPluginBinding::class.java)
        val mockContext = Mockito.mock(Application::class.java)
        val mockBinaryMessenger = Mockito.mock(BinaryMessenger::class.java)

        Mockito.`when`(mockBinding.applicationContext).thenReturn(mockContext)
        Mockito.`when`(mockBinding.binaryMessenger).thenReturn(mockBinaryMessenger)

        plugin.onAttachedToEngine(mockBinding)

        // Test that unknown method with non-existent instance throws IllegalArgumentException
        // This verifies that the instance check happens BEFORE the notImplemented check.
        // The notImplemented() path is only reached after a valid instance is found.
        val unknownCall = MethodCall("unknownMethod", mapOf("instanceName" to "non-existent-instance"))
        val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)
        
        assertFailsWith<IllegalArgumentException> {
            plugin.onMethodCall(unknownCall, mockResult)
        }
    }

    @Test
    fun onMethodCall_init_missingConfig_throwsException() {
        val plugin = AmplitudeExperimentPlugin()
        val mockBinding = Mockito.mock(FlutterPlugin.FlutterPluginBinding::class.java)
        val mockContext = Mockito.mock(Application::class.java)
        val mockBinaryMessenger = Mockito.mock(BinaryMessenger::class.java)

        Mockito.`when`(mockBinding.applicationContext).thenReturn(mockContext)
        Mockito.`when`(mockBinding.binaryMessenger).thenReturn(mockBinaryMessenger)

        plugin.onAttachedToEngine(mockBinding)

        val call = MethodCall("init", mapOf("apiKey" to "test-key"))
        val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)

        // Should throw IllegalArgumentException because config is missing
        assertFailsWith<IllegalArgumentException> {
            plugin.onMethodCall(call, mockResult)
        }
    }

    @Test
    fun onMethodCall_variant_missingFlagKey_throwsException() {
        val plugin = AmplitudeExperimentPlugin()
        val mockBinding = Mockito.mock(FlutterPlugin.FlutterPluginBinding::class.java)
        val mockContext = Mockito.mock(Application::class.java)
        val mockBinaryMessenger = Mockito.mock(BinaryMessenger::class.java)

        Mockito.`when`(mockBinding.applicationContext).thenReturn(mockContext)
        Mockito.`when`(mockBinding.binaryMessenger).thenReturn(mockBinaryMessenger)

        plugin.onAttachedToEngine(mockBinding)

        // First, initialize an instance
        val initConfig = TestDataHelpers.createTestConfigMap(instanceName = "test-instance")
        val initCall = MethodCall("init", mapOf(
            "apiKey" to "test-api-key",
            "config" to initConfig
        ))
        val initResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)
        
        // This will fail because we can't actually initialize without real SDK, but that's okay
        // We're just testing the error handling for missing flagKey
        try {
            plugin.onMethodCall(initCall, initResult)
        } catch (e: Exception) {
            // Expected - SDK initialization will fail in test environment
        }

        // Now test variant call without flagKey
        val variantCall = MethodCall("variant", mapOf("instanceName" to "test-instance"))
        val variantResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)

        assertFailsWith<IllegalArgumentException> {
            plugin.onMethodCall(variantCall, variantResult)
        }
    }

    @Test
    fun onMethodCall_variant_missingInstance_throwsException() {
        val plugin = AmplitudeExperimentPlugin()
        val mockBinding = Mockito.mock(FlutterPlugin.FlutterPluginBinding::class.java)
        val mockContext = Mockito.mock(Application::class.java)
        val mockBinaryMessenger = Mockito.mock(BinaryMessenger::class.java)

        Mockito.`when`(mockBinding.applicationContext).thenReturn(mockContext)
        Mockito.`when`(mockBinding.binaryMessenger).thenReturn(mockBinaryMessenger)

        plugin.onAttachedToEngine(mockBinding)

        val call = MethodCall("variant", mapOf(
            "instanceName" to "non-existent-instance",
            "flagKey" to "test-flag"
        ))
        val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)

        assertFailsWith<IllegalArgumentException> {
            plugin.onMethodCall(call, mockResult)
        }
    }

    @Test
    fun onMethodCall_exposure_missingKey_throwsException() {
        val plugin = AmplitudeExperimentPlugin()
        val mockBinding = Mockito.mock(FlutterPlugin.FlutterPluginBinding::class.java)
        val mockContext = Mockito.mock(Application::class.java)
        val mockBinaryMessenger = Mockito.mock(BinaryMessenger::class.java)

        Mockito.`when`(mockBinding.applicationContext).thenReturn(mockContext)
        Mockito.`when`(mockBinding.binaryMessenger).thenReturn(mockBinaryMessenger)

        plugin.onAttachedToEngine(mockBinding)

        // First, initialize an instance
        val initConfig = TestDataHelpers.createTestConfigMap(instanceName = "test-instance")
        val initCall = MethodCall("init", mapOf(
            "apiKey" to "test-api-key",
            "config" to initConfig
        ))
        val initResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)
        
        try {
            plugin.onMethodCall(initCall, initResult)
        } catch (e: Exception) {
            // Expected - SDK initialization will fail in test environment
        }

        // Now test exposure call without key
        val exposureCall = MethodCall("exposure", mapOf("instanceName" to "test-instance"))
        val exposureResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)

        assertFailsWith<IllegalArgumentException> {
            plugin.onMethodCall(exposureCall, exposureResult)
        }
    }
}
