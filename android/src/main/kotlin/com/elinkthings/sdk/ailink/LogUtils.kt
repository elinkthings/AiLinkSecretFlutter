package com.elinkthings.sdk.ailink

import android.util.Log

/**
 * @author suzy
 * @date 2024/1/31 11:16
 **/
object LogUtils {

    private const val OPEN_LOG = false

    fun d(tag: String, msg: String) {
        if (OPEN_LOG) {
            Log.d(tag, msg)
        }
    }
}