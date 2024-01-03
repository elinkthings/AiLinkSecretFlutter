package com.elinkthings.sdk.ailink

import android.util.Log
import androidx.annotation.NonNull
import cn.net.aicare.algorithmutil.AlgorithmUtil
import cn.net.aicare.algorithmutil.AlgorithmUtil.AlgorithmType
import com.elinkthings.ailinksecretlib.AiLinkBleCheckUtil
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import org.json.JSONException
import org.json.JSONObject

/** AilinkPlugin */
class AilinkPlugin : FlutterPlugin, MethodCallHandler {

    companion object {
        private const val TAG = "AilinkPlugin"
    }

    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "ailink")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        if (call.method == "getPlatformVersion") {
            result.success("Android ${android.os.Build.VERSION.RELEASE}")
        } else if (call.method == "decryptBroadcast") {
            if (call.arguments is ByteArray) {
                val payload = call.arguments as ByteArray
                val decryptPayload = decryptBroadcast(payload)
                Log.d(TAG, "onMethodCall payload: ${payload.toHexString()}")
                Log.d(TAG, "onMethodCall decryptPayload: ${decryptPayload.toHexString()}")
                result.success(decryptPayload)
            }
        } else if (call.method == "getBodyFatData") {
            Log.d(TAG, "getBodyFatData argument: ${call.arguments}")
            try {
                val jsonObject = JSONObject(call.arguments as String)
                val weight = jsonObject.getDouble("weight")
                val adc = jsonObject.getInt("adc")
                val sex = jsonObject.getInt("sex")
                val age = jsonObject.getInt("age")
                val height = jsonObject.getInt("height")
                val algNum = jsonObject.getInt("algNum")
                val type = if (algNum != 0) AlgorithmType.TYPE_ICOMON else AlgorithmType.TYPE_AICARE
                val sexI = if (sex == 0) 2 else sex
                val bodyFatData = AlgorithmUtil.getBodyFatData(type, sexI, age, weight, height, adc)
                result.success("{\"bmi\": ${bodyFatData.bmi}, \"bfr\": ${bodyFatData.bfr}, \"sfr\": ${bodyFatData.sfr}, \"uvi\": ${bodyFatData.uvi}, \"rom\": ${bodyFatData.rom}, \"bmr\": ${bodyFatData.bmr}, \"bm\": ${bodyFatData.bm}, \"vwc\": ${bodyFatData.vwc}, \"physicalAge\": ${bodyFatData.bodyAge}, \"pp\": ${bodyFatData.pp}}")
            } catch (e: JSONException) {
                e.printStackTrace()
                result.success(null)
            }
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    /**
     * Decrypt the broadcast data.
     *
     * @param payload byte[]
     * @return byte[]
     */
    private fun decryptBroadcast(payload: ByteArray): ByteArray {
        if (payload.size >= 20) {
            val cidB = ByteArray(1)
            val vidB = ByteArray(1)
            val pidB = ByteArray(1)
            var start = 0
            System.arraycopy(payload, start, cidB, 0, cidB.size)
            start += 1
            System.arraycopy(payload, start, vidB, 0, vidB.size)
            start += 1
            System.arraycopy(payload, start, pidB, 0, pidB.size)
            start += 1
            //特殊广播,包含是否可以绑定的标志
            val cid = cidB[0].toInt() and 0xff
            val vid = vidB[0].toInt() and 0xff
            val pid = pidB[0].toInt() and 0xff
            val sum = payload[9]
            val decryptData = ByteArray(10) //根据协议取出需要解密的广播数据
            System.arraycopy(payload, 10, decryptData, 0, decryptData.size)
            val newSum: Byte = cmdSum(decryptData)
            if (sum == newSum) {
                return AiLinkBleCheckUtil.decryptBroadcast(cid, vid, pid, decryptData)
            }
        }
        return payload
    }

    /**
     * Check cumulation, starting from 1 and adding consecutively.
     */
    private fun cmdSum(data: ByteArray): Byte {
        var sum = 0
        for (datum in data) {
            sum += datum
        }
        return sum.toByte()
    }
}

fun ByteArray.toHexString(): String = joinToString(",") { "0x%02X".format(it) }