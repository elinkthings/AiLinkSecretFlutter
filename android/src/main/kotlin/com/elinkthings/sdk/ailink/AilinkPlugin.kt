package com.elinkthings.sdk.ailink

import android.util.Log
import androidx.annotation.NonNull
import cn.net.aicare.algorithmutil.AlgorithmUtil
import cn.net.aicare.algorithmutil.AlgorithmUtil.AlgorithmType
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
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            "decryptBroadcast" -> {
                if (call.arguments is ByteArray) {
                    val payload = call.arguments as ByteArray
                    val decryptPayload = ElinkBroadDataUtils.decryptBroadcast(payload)
                    LogUtils.d(TAG, "onMethodCall payload: ${payload.toHexString()}")
                    LogUtils.d(TAG, "onMethodCall decryptPayload: ${decryptPayload.toHexString()}")
                    result.success(decryptPayload)
                } else {
                    result.success(null)
                }
            }
            "getBodyFatData" -> {
                LogUtils.d(TAG, "getBodyFatData argument: ${call.arguments}")
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
            }
            "initHandShake" -> {
                val handShakeArr = ElinkHandShakeUtils.initHandShakeArr()
                LogUtils.d(TAG, "onMethodCall initHandShake: ${handShakeArr.toHexString()}")
                result.success(handShakeArr)
            }
            "getHandShakeEncryptData" -> {
                if (call.arguments is ByteArray) {
                    val data = call.arguments as ByteArray
                    val encryptData = ElinkHandShakeUtils.getHandShakeEncryptArr(data)
                    LogUtils.d(TAG, "onMethodCall getHandShakeEncryptData data: ${data.toHexString()}")
                    LogUtils.d(TAG, "onMethodCall getHandShakeEncryptData encryptData: ${encryptData?.toHexString()}")
                    result.success(encryptData)
                }
            }
            "checkHandShakeStatus" -> {
                if (call.arguments is ByteArray) {
                    val data = call.arguments as ByteArray
                    val status = ElinkHandShakeUtils.checkHandShakeStatus(data)
                    LogUtils.d(TAG, "onMethodCall checkHandShakeStatus: ${data.toHexString()}")
                    LogUtils.d(TAG, "onMethodCall checkHandShakeStatus: $status")
                    result.success(status)
                } else {
                    result.success(false)
                }
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}