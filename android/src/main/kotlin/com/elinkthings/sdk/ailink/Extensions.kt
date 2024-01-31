package com.elinkthings.sdk.ailink

/**
 * @author suzy
 * @date 2024/1/30 11:50
 **/
fun ByteArray.toHexString(): String = joinToString(",") { "0x%02X".format(it) }