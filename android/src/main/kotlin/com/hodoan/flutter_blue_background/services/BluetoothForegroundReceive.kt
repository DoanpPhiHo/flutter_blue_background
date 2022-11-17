package com.hodoan.flutter_blue_background.services

import android.Manifest
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
import androidx.core.app.NotificationCompat
import com.hodoan.flutter_blue_background.FlutterBlueBackgroundPlugin
import com.hodoan.flutter_blue_background.R
import com.hodoan.flutter_blue_background.async_data.FuncAsyncData
import com.hodoan.flutter_blue_background.db_helper.DbBLueAsyncSettingsHelper
import com.hodoan.flutter_blue_background.interfaces.IActionBlueLe
import java.util.*

class BluetoothForegroundReceive : BroadcastReceiver(),
    IActionBlueLe {
    private var scanner: BluetoothLeScanner? = null
    private var adapter: BluetoothAdapter? = null
    private val tag: String = "BluetoothForegroundReceive"

    private var isNotScanCancel = true

    private var context: Context? = null

    private val notificationId = 1998
    private val contentTitle = "Blue Background Service"

    private var charUUID: String? = null
    private var baseUUID: String? = null
    private var serviceUuids: List<String>? = null

    private var taskCount = -1

    private fun notification(text: String) {
        context?.let {
            val intent = Intent(it, ContactsContract.Profile::class.java)
            val pendingIntent =
                PendingIntent.getActivity(it, 0, intent, PendingIntent.FLAG_IMMUTABLE)
            val builder =
                NotificationCompat.Builder(it, FlutterBlueBackgroundPlugin::channelId.toString())
                    .setSmallIcon(R.drawable.ic_stat_name)
                    .setContentTitle(contentTitle)
                    .setContentText("Foreground $text")
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
        if (checkBgActive()) return
        initBg(context)
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
                        settingsBlue(context)
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

    private fun checkBgActive(): Boolean {
        return context?.applicationContext?.applicationContext?.getSharedPreferences(
            "flutter_blue_background",
            Context.MODE_PRIVATE
        )?.getBoolean(FlutterBlueBackgroundPlugin::isActiveBG.toString(), false) ?: false
    }

    private fun initBg(context: Context?) {
        if (this.context == null) {
            this.context = context
            val bluetoothManager: BluetoothManager? =
                context?.applicationContext?.getSystemService(BluetoothManager::class.java)
            adapter = bluetoothManager?.adapter

            val sharedPreferences =
                context?.applicationContext?.applicationContext?.getSharedPreferences(
                    "flutter_blue_background",
                    Context.MODE_PRIVATE
                )

            serviceUuids = sharedPreferences?.getString(
                FlutterBlueBackgroundPlugin::serviceUUIDStr.toString(),
                null
            )?.split(",")?.toList()
            baseUUID =
                sharedPreferences?.getString(
                    FlutterBlueBackgroundPlugin::baseUUIDStr.toString(),
                    null
                )
            charUUID =
                sharedPreferences?.getString(
                    FlutterBlueBackgroundPlugin::charUUIDStr.toString(),
                    null
                )

            notification("Start")
        }
    }

    private fun settingsBlue(context: Context?) {
        val ctx = context ?: return
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            if (ActivityCompat.checkSelfPermission(
                    ctx,
                    Manifest.permission.BLUETOOTH_CONNECT
                ) == PackageManager.PERMISSION_GRANTED
            ) {
                val enableBtIntent = Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE)
                ctx.applicationContext?.startActivity(enableBtIntent, Bundle())
            }
        } else {
            val enableBtIntent = Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE)
            ctx.applicationContext?.startActivity(enableBtIntent, Bundle())
        }

        notification("please turn on bluetooth")
    }

    private var gatt: BluetoothGatt? = null

    private val mGattCallback: BluetoothGattCallback by lazy {
        object : BluetoothGattCallback() {
            override fun onConnectionStateChange(gatt: BluetoothGatt, status: Int, newState: Int) {
                if (newState == BluetoothProfile.STATE_CONNECTED) {
                    val ctx = context ?: return
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        if (ActivityCompat.checkSelfPermission(
                                ctx,
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
        if (UUID.fromString(charUUID) == characteristic.uuid) {
            val result = characteristic.value.map {
                java.lang.Byte.toUnsignedInt(it).toString(radix = 10).padStart(2, '0').toInt()
            }
            FuncAsyncData().savaDataDB(context, characteristic.value)
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
        val ctx = context ?: return
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            if (ActivityCompat.checkSelfPermission(
                    ctx,
                    Manifest.permission.BLUETOOTH_CONNECT
                ) == PackageManager.PERMISSION_GRANTED
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
        val ctx = context ?: return
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            if (ActivityCompat.checkSelfPermission(
                    ctx,
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

    private val scanCallback: ScanCallback = object : ScanCallback() {
        override fun onScanResult(callbackType: Int, result: ScanResult?) {
            super.onScanResult(callbackType, result)
            val device = result?.device ?: return
            val ctx = context ?: return
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                if (ActivityCompat.checkSelfPermission(
                        ctx,
                        Manifest.permission.BLUETOOTH_CONNECT
                    ) == PackageManager.PERMISSION_GRANTED
                ) {
                    Log.d(tag, "onScanResult: ${device.address} ${device.name}")
                    scanner?.stopScan(this)
                    isNotScanCancel = false
                    gatt = device.connectGatt(ctx, true, mGattCallback)

                }
            } else {
                Log.d(tag, "onScanResult: ${device.address} ${device.name}")
                scanner?.stopScan(this)
                isNotScanCancel = false
                gatt = device.connectGatt(ctx, true, mGattCallback)

            }
        }

        override fun onScanFailed(errorCode: Int) {
            super.onScanFailed(errorCode)
            Log.d("ScanCallback", "onScanFailed: $errorCode")
        }
    }

    override fun startScan() {
        val ctx = context ?: return
        if (adapter?.isEnabled == false) {
            settingsBlue(context)
            return
        }
        if(!FuncAsyncData().isLocationEnabled(ctx)){
            FuncAsyncData().enableLocation(ctx)
        }
        scanner = adapter?.bluetoothLeScanner
        val arrFilter: List<ScanFilter>? = this.serviceUuids
            ?.map {
                ScanFilter.Builder().setServiceUuid(ParcelUuid(UUID.fromString(it))).build()
            }?.toList()
        val scanSettings: ScanSettings =
            ScanSettings.Builder().setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY).build()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            if (ActivityCompat.checkSelfPermission(
                    ctx,
                    Manifest.permission.BLUETOOTH_SCAN
                ) == PackageManager.PERMISSION_GRANTED
            ) {
                scanner?.startScan(arrFilter ?: ArrayList(), scanSettings, scanCallback)
            }
        } else {
            scanner?.startScan(arrFilter ?: ArrayList(), scanSettings, scanCallback)
        }
        notification("scanning")
    }
}