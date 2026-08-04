package com.raaghav.uniremote.ir

import android.content.Context
import android.hardware.ConsumerIrManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class IrPlugin : FlutterPlugin, MethodCallHandler {

    private lateinit var channel: MethodChannel
    private var irManager: ConsumerIrManager? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "com.raaghav.uniremote/ir")
        channel.setMethodCallHandler(this)

        irManager = binding.applicationContext
            .getSystemService(Context.CONSUMER_IR_SERVICE) as? ConsumerIrManager
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        irManager = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "hasIrBlaster" -> {
                val has = irManager?.hasIrEmitter() ?: false
                result.success(has)
            }
            "transmit" -> {
                val mgr = irManager
                if (mgr == null || !mgr.hasIrEmitter()) {
                    result.success(false)
                    return
                }
                try {
                    val freqHz = call.argument<Int>("freqHz")
                        ?: return result.error("BAD_ARGS", "freqHz missing", null)
                    val patternList = call.argument<List<Int>>("pattern")
                        ?: return result.error("BAD_ARGS", "pattern missing", null)
                    val pattern = patternList.toIntArray()
                    mgr.transmit(freqHz, pattern)
                    result.success(true)
                } catch (e: Exception) {
                    result.error("TRANSMIT_ERROR", e.message, null)
                }
            }
            else -> result.notImplemented()
        }
    }
}
