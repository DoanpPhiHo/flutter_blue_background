package com.hodoan.flutter_blue_background.services

import android.Manifest
import android.app.Activity
import android.app.NotificationManager
import android.app.PendingIntent
import android.bluetooth.*
import android.bluetooth.le.*
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.os.ParcelUuid
import android.provider.ContactsContract
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.app.ActivityCompat.startActivityForResult
import androidx.core.app.NotificationCompat
import com.google.gson.Gson
import com.hodoan.flutter_blue_background.FlutterBlueBackgroundPlugin
import com.hodoan.flutter_blue_background.R
import com.hodoan.flutter_blue_background.ResultDataEvent
import com.hodoan.flutter_blue_background.async_data.FuncAsyncData
import com.hodoan.flutter_blue_background.db_helper.DbBLueAsyncSettingsHelper
import com.hodoan.flutter_blue_background.interfaces.IActionBlueLe
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.PluginRegistry
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
    IActionBlueLe, PluginRegistry.RequestPermissionsResultListener {
    private val dataCharacteristic:Int = 1
    private val dataDeviceBle:Int = 2
    private var scanner: BluetoothLeScanner? = null
    private val tag: String = "BluetoothReceive"

    private var eventChannel: EventChannel = EventChannel(
        binaryMessenger,
        "flutter_blue_background/write_data_status"
    )
    private var sink: EventSink? = null

    private var isNotScanCancel = true

    private val notificationId: Int = 1998
    private val contentTitle = "Blue Background Service"

    private var taskCount = -1

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

    private fun notification(text: String) {
        context?.let {
            val intent = Intent(it, ContactsContract.Profile::class.java)
            val pendingIntent =
                PendingIntent.getActivity(it, 0, intent, PendingIntent.FLAG_IMMUTABLE)
            val builder =
                NotificationCompat.Builder(it, FlutterBlueBackgroundPlugin::channelId.toString())
                    .setSmallIcon(R.drawable.ic_stat_name)
                    .setContentTitle(contentTitle)
                    .setContentText(text)
                    .setPriority(NotificationCompat.PRIORITY_MAX)
            builder.setContentIntent(pendingIntent).setAutoCancel(false)
            val manager =
                it.getSystemService(NotificationManager::class.java)
            with(manager) {
                notify(notificationId, builder.build())
            }
        }
    }

    override fun onReceive(context: Context?, intent: Intent?) {
        when (val action: String? = intent?.action) {
            BluetoothAdapter.ACTION_DISCOVERY_FINISHED -> {
                notification("Discovery Finished")
                if (isNotScanCancel)
                    startScan()
            }
            BluetoothAdapter.ACTION_STATE_CHANGED -> {
                when (intent.getIntExtra(BluetoothAdapter.EXTRA_STATE, BluetoothAdapter.ERROR)) {
                    BluetoothAdapter.STATE_OFF -> {
                        notification("State Off")
                        gatt = null
                        settingsBlue()
                    }
                    BluetoothAdapter.STATE_ON -> {
                        notification("State On")
                        gatt = null
                        startScan()
                    }
                    BluetoothAdapter.STATE_TURNING_ON -> {
                        notification("State T On")
                        gatt = null
                        startScan()
                    }
                    else -> {
                        notification("Undefine")
                    }
                }
            }
            else -> {
                when (action) {
                    BluetoothDevice.ACTION_ACL_CONNECTED -> {
                        notification("Connected")
                        isNotScanCancel = false
                    }
                    BluetoothDevice.ACTION_ACL_DISCONNECTED -> {
                        notification("Disconnected")
                        isNotScanCancel = true
                        gatt = null
                        startScan()
                    }
                    else -> notification("Undefine $action")
                }
            }
        }
    }

    private fun settingsBlue() {
        val enableBtIntent = Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE)
        startActivityForResult(activity!!, enableBtIntent, 1, Bundle())
    }

    private var gatt: BluetoothGatt? = null

    private val mGattCallback: BluetoothGattCallback by lazy {
        object : BluetoothGattCallback() {
            override fun onConnectionStateChange(gatt: BluetoothGatt, status: Int, newState: Int) {
                if (newState == BluetoothProfile.STATE_CONNECTED) {
                    val context = context ?: return
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        if (ActivityCompat.checkSelfPermission(
                                context,
                                Manifest.permission.BLUETOOTH_CONNECT
                            ) == PackageManager.PERMISSION_GRANTED
                        ) {
                            gatt.discoverServices()
                            Timer().schedule(object : TimerTask() {
                                override fun run() {
                                    autoWriteValue()
                                }
                            }, 2000)
                        }
                    } else {
                        gatt.discoverServices()
                        Timer().schedule(object : TimerTask() {
                            override fun run() {
                                autoWriteValue()
                            }
                        }, 2000)
                    }
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

    fun autoWriteValue() {
        Log.e(
            FuncAsyncData::class.simpleName,
            "autoWriteValue: ${context != null} ${gatt != null}",
        )
        context?.let {
            val db = DbBLueAsyncSettingsHelper(it, null)
            val resultDb = db.argsNoTurnOff()
            taskCount = resultDb.size
            for (item in resultDb) {
                val listInt: List<Byte> =
                    item.value.split(",").map { v -> v.trim().toInt() }.map { v -> v.toByte() }
                val data = byteArrayOf(
                    listInt[0],
                    listInt[1],
                    listInt[2],
                    listInt[3],
                    listInt[4],
                    listInt[5],
                    listInt[6],
                    listInt[7],
                )
                writeCharacteristic(data)
            }
        }
    }

    private fun broadcastUpdate(characteristic: BluetoothGattCharacteristic) {
        Log.d(BluetoothReceive::class.simpleName, "broadcastUpdate: ")
        if (UUID.fromString(charUUID) == characteristic.uuid) {
            val result = characteristic.value.map {
                java.lang.Byte.toUnsignedInt(it).toString(radix = 10).padStart(2, '0').toInt()
            }
            val gson = Gson()
            val resultEvent = ResultDataEvent(dataCharacteristic,result)
            activity?.runOnUiThread {
                sink?.success(gson.toJson(resultEvent))
            }
//            FuncAsyncData().savaDataDB(context, characteristic.value)
            taskCount -= 1
            if (taskCount == 0) {
                FuncAsyncData().turnOffBle(context, gatt, baseUUID, charUUID)
                taskCount = -1
            }
        }
    }

    override fun writeCharacteristic(bytes: ByteArray) {
        val service = gatt?.getService(UUID.fromString(this.baseUUID)) ?: return
        service.characteristics?.forEach { Log.d(tag, "writeCharacteristic: ${it.uuid}") }
        val characteristic = service.getCharacteristic(UUID.fromString(charUUID)) ?: return
        characteristic.value = bytes
        val context = context ?: return
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            if (ActivityCompat.checkSelfPermission(
                    context,
                    Manifest.permission.BLUETOOTH_CONNECT
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                gatt?.setCharacteristicNotification(characteristic, true)
                gatt?.writeCharacteristic(characteristic)
            }
        } else {
            gatt?.setCharacteristicNotification(characteristic, true)
            gatt?.writeCharacteristic(characteristic)
        }

    }

    override fun closeGatt() {
        if (context != null) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                if (ActivityCompat.checkSelfPermission(
                        context,
                        Manifest.permission.BLUETOOTH_CONNECT
                    ) == PackageManager.PERMISSION_GRANTED
                ) {
                    gatt?.disconnect()
                    gatt = null
                }
            } else {
                gatt?.disconnect()
                gatt = null
            }
        }
    }

    private val scanCallback: ScanCallback = object : ScanCallback() {
        override fun onScanResult(callbackType: Int, result: ScanResult?) {
            super.onScanResult(callbackType, result)
            sendDeviceBle(result)
            val device = result?.device ?: return
            val context = context ?: return
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                if (ActivityCompat.checkSelfPermission(
                        context,
                        Manifest.permission.BLUETOOTH_CONNECT
                    ) == PackageManager.PERMISSION_GRANTED
                ) {
                    scanner?.stopScan(this)
                    isNotScanCancel = false
                    gatt = device.connectGatt(context, true, mGattCallback)
                }
            } else {
                scanner?.stopScan(this)
                isNotScanCancel = false
                gatt = device.connectGatt(context, true, mGattCallback)
            }
        }

        override fun onScanFailed(errorCode: Int) {
            super.onScanFailed(errorCode)
            notification("Scan fail $errorCode")
        }

        override fun onBatchScanResults(results: MutableList<ScanResult>?) {
            super.onBatchScanResults(results)
            Log.d(BluetoothReceive::class.simpleName, "onBatchScanResults: ")
            if (results == null) return
            for (result in results) {
                Log.d(BluetoothReceive::class.simpleName, "onBatchScanResults: $result")
            }
        }
    }

    private fun sendDeviceBle(result: ScanResult?) {
        val resultEvent = result?.let { ResultDataEvent(dataDeviceBle, it) }
        val gson = Gson()
        activity?.runOnUiThread {
            sink?.success(gson.toJson(resultEvent))
        }
    }

    override fun startScan() {
        val ctx = context ?: return
        if (ctx.checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION)
            == PackageManager.PERMISSION_GRANTED
        ) {
            val adp = adapter ?: return
            if (!adp.isEnabled) {
                settingsBlue()
                return
            }
            if (!FuncAsyncData().isLocationEnabled(ctx)) {
                FuncAsyncData().enableLocation(ctx)
            }
            scanner = adapter.bluetoothLeScanner
            val arrFilter: List<ScanFilter> = this.serviceUuids
                ?.map {
                    ScanFilter.Builder().setServiceUuid(ParcelUuid(it)).build()
                }?.toList() ?: ArrayList()
            val scanSettings: ScanSettings =
                ScanSettings.Builder().setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY).build()
            scanner!!.startScan(arrFilter, scanSettings, scanCallback)
            notification("Scanning")
        } else {
            requestLocationPermission()
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ): Boolean {
        when (requestCode) {
            99 -> {
                if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    if (context?.checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION)
                        == PackageManager.PERMISSION_GRANTED
                    ) {
                        startScan()
                    } else {
                        requestLocationPermission()
                    }
                }
            }
        }
        return true
    }

    private fun requestLocationPermission() {
        activity?.let {
            ActivityCompat.requestPermissions(
                it,
                arrayOf(
                    Manifest.permission.ACCESS_FINE_LOCATION,
                ),
                99
            )
        }
    }
}