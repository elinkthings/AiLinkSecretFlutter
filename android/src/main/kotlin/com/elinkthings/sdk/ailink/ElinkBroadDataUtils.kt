package com.elinkthings.sdk.ailink

import com.elinkthings.ailinksecretlib.AiLinkBleCheckUtil

/**
 * 广播数据处理工具类
 * Broadcast data processing tools
 *
 * @author suzy
 * @date 2024/1/30 11:48
 **/
object ElinkBroadDataUtils {

    /**
     * Decrypt the broadcast data.
     *
     * @param payload byte[]
     * @return byte[]
     */
    fun decryptBroadcast(payload: ByteArray): ByteArray {
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