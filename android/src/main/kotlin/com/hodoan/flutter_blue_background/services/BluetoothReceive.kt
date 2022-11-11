package com.hodoan.flutter_blue_background.services

import android.Manifest
import android.app.Activity
import android.bluetooth.*
import android.bluetooth.le.*
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.os.ParcelUuid
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.core.app.ActivityCompat
import androidx.core.app.ActivityCompat.startActivityForResult
import com.hodoan.flutter_blue_background.interfaces.IActionBlueLe
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import java.util.*


class BluetoothReceive(
    private val context: Context?,
    private val activity: Activity?,
    private val adapter: BluetoothAdapter?,
    binaryMessenger: BinaryMessenger,
    private val serviceUuids: List<UUID>?,
    private val baseUUID: String?,
    private val charUUID: String?,
) :
    BroadcastReceiver(),
    IActionBlueLe {
    private var scanner: BluetoothLeScanner? = null
    private val tag: String = "BluetoothReceive"

    private var eventChannel: EventChannel = EventChannel(
        binaryMessenger,
        "flutter_blue_background/write_data_status"
    )
    private var sink: EventSink? = null

    private var isNotScanCancel = true

    init {
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventSink?) {
                sink = events
            }

            override fun onCancel(arguments: Any?) {
                sink = null
            }
        })
    }

    @RequiresApi(Build.VERSION_CODES.S)
    @SuppressWarnings("MissingPermission")
    override fun onReceive(context: Context?, intent: Intent?) {
        val action: String? = intent?.action
        if (action.equals(BluetoothAdapter.ACTION_DISCOVERY_FINISHED)) {
            if (isNotScanCancel)
                startScan()
        } else if (action.equals(BluetoothAdapter.ACTION_STATE_CHANGED)) {
            when (intent?.getIntExtra(BluetoothAdapter.EXTRA_STATE, BluetoothAdapter.ERROR)) {
                BluetoothAdapter.STATE_OFF -> {
                    Log.d(tag, "onReceive: STATE_OFF ")
                }
                BluetoothAdapter.STATE_TURNING_OFF -> {
                    Log.d(tag, "onReceive: STATE_TURNING_OFF ")
                    settingsBlue()
                }
                BluetoothAdapter.STATE_ON -> {
                    Log.d(tag, "onReceive: STATE_ON ")
                    startScan()
                }
                BluetoothAdapter.STATE_TURNING_ON -> {
                    Log.d(tag, "onReceive: STATE_TURNING_ON ")
                    startScan()
                }
                else -> {
                    Log.d(tag, "onReceive: else ")
                }
            }

        } else {
            when (action) {
                BluetoothDevice.ACTION_ACL_CONNECTED -> {
                    Log.d(tag, "onReceive: ACTION_ACL_CONNECTED ")
                }
                BluetoothDevice.ACTION_ACL_DISCONNECTED -> {
                    Log.d(tag, "onReceive: ACTION_ACL_DISCONNECTED ")
                    isNotScanCancel = true
                    startScan()
                }
                else -> Log.d(tag, "onReceive: ACTION $action")
            }
        }
    }

    private fun settingsBlue() {
        val enableBtIntent = Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE)
        startActivityForResult(activity!!, enableBtIntent, 1, Bundle())
    }

    private var gatt: BluetoothGatt? = null

    private val mGattCallback: BluetoothGattCallback by lazy {
        @SuppressWarnings("MissingPermission")
        object : BluetoothGattCallback() {
            override fun onConnectionStateChange(gatt: BluetoothGatt, status: Int, newState: Int) {
                if (newState == BluetoothProfile.STATE_CONNECTED) {
                    gatt.discoverServices()
                } else {
                    Log.w(tag, "onConnectionStateChange received: $status")
                }
            }

            override fun onServicesDiscovered(gatt: BluetoothGatt, status: Int) {}

            override fun onCharacteristicRead(
                gatt: BluetoothGatt,
                characteristic: BluetoothGattCharacteristic,
                status: Int
            ) {
                if (status == BluetoothGatt.GATT_SUCCESS) {
                    broadcastUpdate(characteristic)
                }
            }

            override fun onCharacteristicChanged(
                gatt: BluetoothGatt,
                characteristic: BluetoothGattCharacteristic
            ) {
                broadcastUpdate(characteristic)
            }
        }
    }

    //Get the 'real' data out of characteristic
    private fun broadcastUpdate(characteristic: BluetoothGattCharacteristic) {
        if (UUID.fromString(charUUID) == characteristic.uuid) {
            val result = characteristic.value.asList().map {
                it.toInt()
            }
            activity?.runOnUiThread {
                sink?.success(result)
            }
        }
    }

    @SuppressWarnings("MissingPermission")
    override fun writeCharacteristic(bytes: ByteArray) {
        val service = gatt?.getService(UUID.fromString(this.baseUUID)) ?: return
        service.characteristics?.forEach { Log.d(tag, "writeCharacteristic: ${it.uuid}") }
        val characteristic = service.getCharacteristic(UUID.fromString(charUUID)) ?: return
        characteristic.value = bytes
        gatt?.setCharacteristicNotification(characteristic, true)
        gatt?.writeCharacteristic(characteristic)
    }

    override fun closeGatt() {
        if (ActivityCompat.checkSelfPermission(
                context!!,
                Manifest.permission.BLUETOOTH_CONNECT
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            return
        }
        gatt?.disconnect()
    }

    @SuppressWarnings("MissingPermission")
    private val scanCallback: ScanCallback = object : ScanCallback() {
        override fun onScanResult(callbackType: Int, result: ScanResult?) {
            super.onScanResult(callbackType, result)
            val device = result?.device ?: return
            Log.d(tag, "onScanResult: ${device.address} ${device.name}")
            if (context != null) {
                scanner?.stopScan(this)
                isNotScanCancel = false
                gatt = device.connectGatt(context, true, mGattCallback)
            }
        }

        override fun onScanFailed(errorCode: Int) {
            super.onScanFailed(errorCode)
            Log.d("ScanCallback", "onScanFailed: $errorCode")
        }
    }

    @SuppressWarnings("MissingPermission")
    override fun startScan() {
        if (adapter?.isEnabled == false) {
            settingsBlue()
            return
        }
        scanner = adapter?.bluetoothLeScanner
        val arrFilter: List<ScanFilter> = this.serviceUuids
            ?.map {
                ScanFilter.Builder().setServiceUuid(ParcelUuid(it)).build()
            }?.toList() ?: ArrayList()
        val scanSettings: ScanSettings =
            ScanSettings.Builder().setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY).build()
        scanner?.startScan(arrFilter, scanSettings, scanCallback)
    }
}