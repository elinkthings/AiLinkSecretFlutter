package com.elinkthings.sdk.ailink

import com.elinkthings.ailinksecretlib.AiLinkBleCheckUtil
import com.elinkthings.ailinksecretlib.CmdConfig
import java.util.*

/**
 * 握手加解密工具类
 * Handshake encryption and decryption tools
 *
 * @author suzy
 * @date 2024/1/30 11:29
 **/
object ElinkHandShakeUtils {

    private var handShakeData: ByteArray? = null

    fun initHandShakeArr(): ByteArray {
        handShakeData = AiLinkBleCheckUtil.getRandomKey(16)
        return AiLinkBleCheckUtil.sendHandshakeFormat(handShakeData, CmdConfig.SET_HANDSHAKE)
    }

    fun getHandShakeEncryptArr(hex: ByteArray): ByteArray? {
        val bleDataHandshake = AiLinkBleCheckUtil.returnHandshakeDataFormat(hex)
        val appDataHandShake = AiLinkBleCheckUtil.bleEncrypt(bleDataHandshake)
        return appDataHandShake?.let {
            AiLinkBleCheckUtil.sendHandshakeFormat(it, CmdConfig.GET_HANDSHAKE)
        }
    }

    fun checkHandShakeStatus(hex: ByteArray): Boolean {
        if (handShakeData == null) return false
        //得到加密后的Payload
        val bleDataHandShake = AiLinkBleCheckUtil.returnHandshakeDataFormat(hex)
        //加密自己发送的数据
        //加密后会改变传入的byte数据,如需要保留请先copy
        val appDataHandShake = AiLinkBleCheckUtil.bleEncrypt(handShakeData!!.copyOf())
        //校验两次加密是否一致
        return Arrays.equals(appDataHandShake, bleDataHandShake)
    }
}