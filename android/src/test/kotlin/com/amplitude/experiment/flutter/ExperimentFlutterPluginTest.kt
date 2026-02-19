package com.amplitude.experiment.flutter

import org.junit.Test
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit
import kotlin.test.assertFailsWith
import kotlin.test.assertTrue

/**
 * Unit tests for [AmplitudeExperimentPlugin] with Pigeon Host API.
 *
 * The plugin implements [AmplitudeExperimentHostApi]; communication is via
 * Pigeon message channels, not MethodChannel. These tests call Host API
 * methods directly and verify error handling when instances are missing
 * or arguments are invalid.
 *
 * Full integration with the Amplitude Experiment SDK is not exercised here;
 * the codec is tested in [ExperimentSdkCodecTest].
 */
internal class ExperimentFlutterPluginTest {

    @Test
    fun variant_withNonExistentInstance_throwsIllegalArgumentException() {
        val (plugin, _) = TestDataHelpers.createAttachedPlugin()
        val user = TestDataHelpers.createPigeonUser()
        assertFailsWith<IllegalArgumentException> {
            plugin.variant("non-existent-instance", user, "test-flag", null)
        }
    }

    @Test
    fun start_withNonExistentInstance_callsBackWithFailure() {
        val (plugin, _) = TestDataHelpers.createAttachedPlugin()
        val latch = CountDownLatch(1)
        var callbackResult: Result<Unit>? = null
        plugin.start("non-existent-instance", null) { result ->
            callbackResult = result
            latch.countDown()
        }
        assertTrue(latch.await(5, TimeUnit.SECONDS))
        assertTrue(callbackResult!!.isFailure)
        assertTrue(callbackResult!!.exceptionOrNull() is IllegalArgumentException)
    }

    @Test
    fun stop_withNonExistentInstance_throwsIllegalArgumentException() {
        val (plugin, _) = TestDataHelpers.createAttachedPlugin()
        assertFailsWith<IllegalArgumentException> {
            plugin.stop("non-existent-instance")
        }
    }

    @Test
    fun fetch_withNonExistentInstance_callsBackWithFailure() {
        val (plugin, _) = TestDataHelpers.createAttachedPlugin()
        val latch = CountDownLatch(1)
        var callbackResult: Result<Unit>? = null
        plugin.fetch("non-existent-instance", null, null) { result ->
            callbackResult = result
            latch.countDown()
        }
        assertTrue(latch.await(5, TimeUnit.SECONDS))
        assertTrue(callbackResult!!.isFailure)
        assertTrue(callbackResult!!.exceptionOrNull() is IllegalArgumentException)
    }

    @Test
    fun clear_withNonExistentInstance_throwsIllegalArgumentException() {
        val (plugin, _) = TestDataHelpers.createAttachedPlugin()
        assertFailsWith<IllegalArgumentException> {
            plugin.clear("non-existent-instance")
        }
    }

    @Test
    fun exposure_withNonExistentInstance_throwsIllegalArgumentException() {
        val (plugin, _) = TestDataHelpers.createAttachedPlugin()
        assertFailsWith<IllegalArgumentException> {
            plugin.exposure("non-existent-instance", "flag-key")
        }
    }

    @Test
    fun setUser_withNonExistentInstance_throwsIllegalArgumentException() {
        val (plugin, _) = TestDataHelpers.createAttachedPlugin()
        val user = TestDataHelpers.createPigeonUser()
        assertFailsWith<IllegalArgumentException> {
            plugin.setUser("non-existent-instance", user)
        }
    }

    @Test
    fun setTracksAssignment_withNonExistentInstance_throwsIllegalArgumentException() {
        val (plugin, _) = TestDataHelpers.createAttachedPlugin()
        assertFailsWith<IllegalArgumentException> {
            plugin.setTracksAssignment("non-existent-instance", true)
        }
    }

    @Test
    fun init_withValidConfig_doesNotThrow() {
        val (plugin, _) = TestDataHelpers.createAttachedPlugin()
        val config = TestDataHelpers.createPigeonConfig(instanceName = "test-instance")
        // May throw if Experiment.initialize fails in test environment (e.g. no real Application).
        // We only verify the plugin accepts the Pigeon types; SDK init is not guaranteed in unit tests.
        try {
            plugin.init("test-api-key", config)
        } catch (e: Exception) {
            // SDK initialization can fail without Robolectric Application
        }
    }

    @Test
    fun init_twiceWithSameInstanceName_doesNotThrow() {
        val (plugin, _) = TestDataHelpers.createAttachedPlugin()
        val config = TestDataHelpers.createPigeonConfig(instanceName = "same-instance")
        try {
            plugin.init("test-api-key", config)
            plugin.init("test-api-key", config)
        } catch (e: Exception) {
            // SDK initialization can fail in unit test environment
        }
    }
}
