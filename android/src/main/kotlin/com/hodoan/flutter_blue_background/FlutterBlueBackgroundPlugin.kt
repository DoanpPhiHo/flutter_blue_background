package com.hodoan.flutter_blue_background

import android.app.Activity
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.content.Context
import android.content.IntentFilter
import android.os.Build
import android.util.Log
import com.hodoan.flutter_blue_background.services.BluetoothReceive
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** FlutterBlueBackgroundPlugin */
class FlutterBlueBackgroundPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private lateinit var binaryMessenger: BinaryMessenger
    private var bluetoothReceive: BluetoothReceive? = null
    private var context: Context? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPluginBinding) {
        binaryMessenger = flutterPluginBinding.binaryMessenger
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_blue_background")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getPlatformVersion" -> getPlatformVersion(result)
            "startBackground" -> startBackground(result)
            "writeCharacteristic" -> {
                Log.d("writeCharacteristic", "onMethodCall: ")
                writeCharacteristic(call.arguments, result)
            }
            else -> result.notImplemented()
        }
    }

    @SuppressWarnings("MissingPermission")
    private fun writeCharacteristic(arguments: Any?, result: Result) {
        val listInt: List<Int> = arguments as List<Int>
        val data = byteArrayOf(
            listInt[0].toByte(),
            listInt[1].toByte(),
            listInt[2].toByte(),
            listInt[3].toByte(),
            listInt[4].toByte(),
            listInt[5].toByte(),
            listInt[6].toByte(),
            listInt[7].toByte(),
        )
        Log.d("writeCharacteristic", "writeCharacteristic: ")
        bluetoothReceive?.writeCharacteristic(data)
        result.success(true)
    }

    private fun startBackground(result: Result) {
        val filter = IntentFilter(BluetoothDevice.ACTION_FOUND)
        filter.addAction(BluetoothAdapter.ACTION_STATE_CHANGED)
        filter.addAction(BluetoothDevice.ACTION_FOUND)
        filter.addAction(BluetoothDevice.ACTION_ACL_CONNECTED)
        filter.addAction(BluetoothDevice.ACTION_ACL_DISCONNECTED)

        val bluetoothManager: BluetoothManager? =
            context?.applicationContext?.getSystemService(BluetoothManager::class.java)
        val bluetoothAdapter: BluetoothAdapter? = bluetoothManager?.adapter
        bluetoothReceive = BluetoothReceive(context, activity, bluetoothAdapter, binaryMessenger)

        context?.applicationContext?.registerReceiver(bluetoothReceive, filter)
        bluetoothReceive?.startScan()
        result.success(true)

    }

    private fun getPlatformVersion(result: Result) {
        result.success("Android ${Build.VERSION.RELEASE}")
    }


    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        context?.applicationContext?.unregisterReceiver(bluetoothReceive)

    }

    private var activity: Activity? = null

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
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
