package com.hodoan.flutter_blue_background.services

import android.app.NotificationManager
import android.app.PendingIntent
import android.bluetooth.*
import android.bluetooth.le.*
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.ParcelUuid
import android.provider.ContactsContract
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.core.app.NotificationCompat
import com.hodoan.flutter_blue_background.FlutterBlueBackgroundPlugin
import com.hodoan.flutter_blue_background.R
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

    @RequiresApi(Build.VERSION_CODES.S)
    @SuppressWarnings("MissingPermission")
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
                        settingsBlue()
                    }
                    BluetoothAdapter.STATE_ON -> {
                        notification("State On")
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

    @SuppressWarnings("MissingPermission")
    private fun settingsBlue() {
        val enableBtIntent = Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE)
        context?.applicationContext?.startActivity(enableBtIntent)
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

    private fun broadcastUpdate(characteristic: BluetoothGattCharacteristic) {
        if (UUID.fromString(charUUID) == characteristic.uuid) {
            val result = characteristic.value.map {
                java.lang.Byte.toUnsignedInt(it).toString(radix = 10).padStart(2, '0').toInt()
            }
            Log.d("broadcastUpdate", "broadcastUpdate: $result")
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

    @SuppressWarnings("MissingPermission")
    override fun closeGatt() {
        gatt?.disconnect()
        gatt = null
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
        val arrFilter: List<ScanFilter>? = this.serviceUuids
            ?.map {
                ScanFilter.Builder().setServiceUuid(ParcelUuid(UUID.fromString(it))).build()
            }?.toList()
        val scanSettings: ScanSettings =
            ScanSettings.Builder().setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY).build()
        scanner?.startScan(arrFilter ?: ArrayList(), scanSettings, scanCallback)
    }
}