package com.hodoan.flutter_blue_background.interfaces

interface IActionBlueLe {
    fun writeCharacteristic(bytes: ByteArray)
    fun closeGatt()
    fun startScan()
}