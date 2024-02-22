package com.elinkthings.sdk.ailink

import com.elinkthings.ailinksecretlib.AiLinkBleCheckUtil
import java.util.*

/**
 * A7数据加解密
 * A7 data encryption and decryption
 *
 * @author suzy
 * @date 2024/2/19 15:05
 **/
object ElinkMcuDataUtils {

    /**
     * 解密A7数据
     * A7 data decryption
     *
     * @param mac ByteArray
     * @param hex ByteArray
     * @return [ByteArray]
     */
    fun mcuDecrypt(mac: ByteArray, hex: ByteArray): ByteArray? {
        var data = AiLinkBleCheckUtil.returnMcuDataFormat(hex)
        if (data != null && data.isNotEmpty()) {
            val cid = byteArrayOf(hex[1], hex[2])
            data = AiLinkBleCheckUtil.mcuEncrypt(cid, data, littleBytes2MacStr(mac))
        }
        return data
    }

    /**
     * 加密A7数据
     * A7 data encryption
     *
     * @param cid     ByteArray
     * @param mac     ByteArray
     * @param payload ByteArray
     * @return [ByteArray]
     */
    fun mcuEncrypt(cid: ByteArray, mac: ByteArray, payload: ByteArray?): ByteArray? {
        var data: ByteArray? = null
        if (payload != null && payload.isNotEmpty()) {
            data = AiLinkBleCheckUtil.mcuEncrypt(cid, payload, littleBytes2MacStr(mac))
        }
        return data
    }

    /**
     * 小端序字节数组转Mac地址
     *
     * @param bytes ByteArray
     * @return [String]
     */
    private fun littleBytes2MacStr(bytes: ByteArray): String {
        val macBuilder = StringBuilder()
        for (i in bytes.indices.reversed()) {
            val byteStr = String.format("%02X", bytes[i]).uppercase(Locale.getDefault())
            macBuilder.append(byteStr)
            if (i != 0) {
                macBuilder.append(":")
            }
        }
        return macBuilder.toString()
    }
}