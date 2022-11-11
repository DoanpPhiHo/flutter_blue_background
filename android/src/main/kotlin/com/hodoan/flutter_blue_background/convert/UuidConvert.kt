package com.hodoan.flutter_blue_background.convert

import java.nio.ByteBuffer
import java.util.*

class UuidConvert {
    @Suppress("Detekt.MagicNumber")
    public fun convert16BitToUuid(bytes: ByteArray): UUID {
        val uuidConstruct = byteArrayOf(0x00, 0x00, bytes[0], bytes[1], 0x00, 0x00, 0x10, 0x00,
            0x80.toByte(), 0x00, 0x00, 0x80.toByte(), 0x5F, 0x9B.toByte(), 0x34, 0xFB.toByte())

        return convert128BitNotationToUuid(uuidConstruct)
    }

    private fun convert128BitNotationToUuid(bytes: ByteArray): UUID {
        val bb = ByteBuffer.wrap(bytes)
        val most = bb.long
        val least = bb.long
        return UUID(most, least)
    }
}