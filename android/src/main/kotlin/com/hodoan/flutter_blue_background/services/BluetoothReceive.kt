package com.hodoan.flutter_blue_background.services

import android.Manifest
import android.app.Activity
import android.bluetooth.*
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
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
) :
    BroadcastReceiver(),
    IActionBlueLe {
    private val tag: String = "BluetoothReceive"

    private var eventChannel: EventChannel = EventChannel(
        binaryMessenger,
        "flutter_blue_background/write_data_status"
    )
    private var sink: EventSink? = null

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
        Log.d(tag, "onReceive: ")
        val action: String? = intent?.action

        if (action.equals(BluetoothAdapter.ACTION_STATE_CHANGED)) {
            when (intent?.getIntExtra(BluetoothAdapter.EXTRA_STATE, BluetoothAdapter.ERROR)) {
                BluetoothAdapter.STATE_OFF -> {
                    Log.d(tag, "onReceive: STATE_OFF ")
                }
                BluetoothAdapter.STATE_TURNING_OFF -> {
                    Log.d(tag, "onReceive: STATE_TURNING_OFF ")
                    val enableBtIntent = Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE)
                    startActivityForResult(activity!!, enableBtIntent, 1, Bundle())
                }
                BluetoothAdapter.STATE_ON -> {
                    Log.d(tag, "onReceive: STATE_ON ")
                    adapter?.startDiscovery()
                }
                BluetoothAdapter.STATE_TURNING_ON -> {
                    Log.d(tag, "onReceive: STATE_TURNING_ON ")
                    adapter?.startDiscovery()
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
                }
                BluetoothDevice.ACTION_FOUND -> {
                    Log.d(tag, "onReceive: ACTION_FOUND ")
                    intent.getParcelableExtra<BluetoothDevice>(BluetoothDevice.EXTRA_DEVICE)
                        ?.let {
                            if (it.name != null) {
                                Log.d(tag, "onReceive: ${it.address} ${it.name}")
                            }
                            if (it.address == "C0:26:DA:18:FE:D0") {
                                if (context != null) {
                                    adapter?.cancelDiscovery()
                                    gatt = it.connectGatt(context, true, mGattCallback)
                                }
                            }
                        }
                }
                else -> Log.d(tag, "onReceive: ACTION $action")
            }
        }
    }

    private var gatt: BluetoothGatt? = null

    private val baseUUID: UUID = UUID.fromString("00001523-1212-efde-1523-785feabcd123")
    private val charUUID: UUID = UUID.fromString("00001524-1212-efde-1523-785feabcd123")

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
        if (charUUID == characteristic.uuid) {
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
        sink?.success("0")
        val service = gatt?.getService(baseUUID) ?: return
        service.characteristics?.forEach { Log.d(tag, "writeCharacteristic: ${it.uuid}") }
        val characteristic = service.getCharacteristic(charUUID) ?: return
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
    override fun startScan() {
        Log.d("TAG", "startScan: ")
        adapter?.startDiscovery()
    }
}