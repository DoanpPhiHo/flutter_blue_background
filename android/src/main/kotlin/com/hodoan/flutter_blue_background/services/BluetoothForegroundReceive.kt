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
import androidx.annotation.RequiresApi
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import com.hodoan.flutter_blue_background.FlutterBlueBackgroundPlugin
import com.hodoan.flutter_blue_background.R
import com.hodoan.flutter_blue_background.interfaces.IActionBlueLe
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.PluginRegistry
import java.util.*

class BluetoothForegroundReceive: BroadcastReceiver(),
    IActionBlueLe, ActivityAware, PluginRegistry.RequestPermissionsResultListener {
    private var scanner: BluetoothLeScanner? = null
    private var adapter: BluetoothAdapter? = null
    private val tag: String = "BluetoothReceive"
    private var activity: Activity? = null

    private var isNotScanCancel = true

    private var context: Context? = null

    private val notificationId = 1998
    private val channelId = "flutter_blue_background.services"
    private val contentTitle = "Blue Background Service"

    private var charUUID:String? = null
    private var baseUUID:String? = null
    private var serviceUuids:List<String>? = null

    private fun notification(text: String) {
        context?.let {
            val intent = Intent(it, ContactsContract.Profile::class.java)
            val pendingIntent =
                PendingIntent.getActivity(it, 0, intent, PendingIntent.FLAG_IMMUTABLE)
            val builder =
                NotificationCompat.Builder(it, channelId)
                    .setSmallIcon(R.drawable.ic_stat_name)
                    .setContentTitle(contentTitle)
                    .setContentText(text)
                    .setPriority(NotificationCompat.PRIORITY_MAX)
            builder.setContentIntent(pendingIntent).setAutoCancel(false)
            builder.setOngoing(true)
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

    @SuppressWarnings("MissingPermission")
    private fun settingsBlue() {
        val enableBtIntent = Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE)
        ActivityCompat.startActivityForResult(activity!!, enableBtIntent, 1, Bundle())
//        adapter?.enable()
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
            activity?.runOnUiThread {
                Log.d("broadcastUpdate", "broadcastUpdate: $result")
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
        activity?.let {
            if (ContextCompat.checkSelfPermission(
                    it,
                    Manifest.permission.ACCESS_FINE_LOCATION
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                requestLocationPermission()
                return
            }
        }
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
        scanner?.startScan(arrFilter?:ArrayList(), scanSettings, scanCallback)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ): Boolean {
        when (requestCode) {
            99 -> {
                if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    if (ContextCompat.checkSelfPermission(
                            activity!!,
                            Manifest.permission.ACCESS_FINE_LOCATION
                        ) == PackageManager.PERMISSION_GRANTED
                    ) {
                        startScan()
                    }

                } else {
                    requestLocationPermission()
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

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        Log.d("onAttachedToActivity", "onAttachedToActivity: hehehe")
        if (this.context == null){
            context = binding.activity.applicationContext
            val bluetoothManager: BluetoothManager? =
                context?.applicationContext?.getSystemService(BluetoothManager::class.java)
            adapter = bluetoothManager?.adapter
        }

        val sharedPreferences = binding.activity.applicationContext.getSharedPreferences("flutter_blue_background",
            Context.MODE_PRIVATE)

        serviceUuids = sharedPreferences.getString(FlutterBlueBackgroundPlugin::serviceUUIDStr.toString(),null)?.split(",")?.toList()
        baseUUID = sharedPreferences.getString(FlutterBlueBackgroundPlugin::baseUUIDStr.toString(),null)
        charUUID = sharedPreferences.getString(FlutterBlueBackgroundPlugin::charUUIDStr.toString(),null)

        if (activity == null) {
            if (ContextCompat.checkSelfPermission(
                    binding.activity,
                    Manifest.permission.ACCESS_FINE_LOCATION
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                requestLocationPermission()
                return
            }
        }
        activity = binding.activity
        if (ContextCompat.checkSelfPermission(
                activity!!,
                Manifest.permission.ACCESS_FINE_LOCATION
            ) == PackageManager.PERMISSION_GRANTED
        ) {
            startScan()
        }
    }

    override fun onDetachedFromActivityForConfigChanges() {
        TODO("Not yet implemented")
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        TODO("Not yet implemented")
    }

    override fun onDetachedFromActivity() {
        TODO("Not yet implemented")
    }
}