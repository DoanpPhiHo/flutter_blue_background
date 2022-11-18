package com.hodoan.flutter_blue_background

import android.app.*
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.SharedPreferences
import android.os.Build
import android.util.Log
import com.google.gson.Gson
import com.hodoan.flutter_blue_background.convert.UuidConvert
import com.hodoan.flutter_blue_background.db_helper.BleValue
import com.hodoan.flutter_blue_background.db_helper.BlueAsync
import com.hodoan.flutter_blue_background.db_helper.DbBLueAsyncSettingsHelper
import com.hodoan.flutter_blue_background.services.BluetoothReceive
import com.hodoan.flutter_blue_background.services.RestartService
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.*


/** FlutterBlueBackgroundPlugin */
class FlutterBlueBackgroundPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private var sharedPreferences: SharedPreferences? = null
    val serviceUUIDStr: String = "serviceUuids"
    val baseUUIDStr = "baseUUID"
    val charUUIDStr = "charUUID"
    val isActiveBG = "isActiveBG"
    val channelId = "flutter_blue_background.services"

    private lateinit var channel: MethodChannel
    private lateinit var binaryMessenger: BinaryMessenger
    private var bluetoothReceive: BluetoothReceive? = null
    private var context: Context? = null

    private var serviceUuids: List<UUID>? = null
    private var baseUUID: String? = null
    private var charUUID: String? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPluginBinding) {
        binaryMessenger = flutterPluginBinding.binaryMessenger
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_blue_background")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
        sharedPreferences = flutterPluginBinding.applicationContext.getSharedPreferences(
            "flutter_blue_background",
            Context.MODE_PRIVATE
        )
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getPlatformVersion" -> getPlatformVersion(result)
            "startBackground" -> startBackground(result)
            "writeCharacteristic" -> writeCharacteristic(call.arguments, result)
            "initial" -> initialSettings(call, result)
            // db
            "add_task_async" -> addTaskAsync(call, result)
            "remove_task_async" -> removeTaskAsync(call, result)
            "clear_ble_data" -> clearBleData(result)
            "get_list_task_async" -> listTaskAsync(result)
            "get_list_ble_value" -> listBleData(result)
            else -> result.notImplemented()
        }
    }

    private fun listBleData(result: Result) {
        context?.let {
            val db = DbBLueAsyncSettingsHelper(it, null)
            val resultDb = db.argsBle()
            val gson = Gson()
            result.success(gson.toJson(resultDb))
            return
        }
        result.success(null)
    }

    private fun clearBleData(result: Result) {
        context?.let {
            val db = DbBLueAsyncSettingsHelper(it, null)
            val resultDb = db.removeAll()
            result.success(resultDb)
            return
        }
        result.success(false)
    }

    private fun listTaskAsync(result: Result) {
        context?.let {
            val db = DbBLueAsyncSettingsHelper(it, null)
            val resultDb = db.args()
            val gson = Gson()
            result.success(gson.toJson(resultDb))
            return
        }
        result.success(null)
    }

    private fun removeTaskAsync(call: MethodCall, result: Result) {
        context?.let {
            val db = DbBLueAsyncSettingsHelper(it, null)
            val data = call.arguments as String
            val resultDb = db.remove(data)
            result.success(resultDb)
            return
        }
        result.success(false)
    }

    private fun addTaskAsync(call: MethodCall, result: Result) {
        context?.let {
            val db = DbBLueAsyncSettingsHelper(it, null)
            val data = call.arguments as Map<*, *>
            val taskData = (data["value"] as ByteArray).map { v -> v.toInt() }.joinToString()
            Log.e(FlutterBlueBackgroundPlugin::class.simpleName, "addTaskAsync: $taskData", )
            val resultDb = db.add(
                data["name_tasks"] as String,taskData)
            result.success(resultDb)
            return
        }
        result.success(false)
    }

    private fun initialSettings(call: MethodCall, result: Result) {
        val data = call.arguments as Map<*, *>
        serviceUuids = (data["uuidService"] as List<*>).map { it as ByteArray }
            .map { UuidConvert().convert16BitToUuid(it) }
        baseUUID = data["baseUUID"] as String
        charUUID = data["charUUID"] as String
        sharedPreferences?.edit()?.apply {
            putString(serviceUUIDStr, serviceUuids?.joinToString { it.toString() })
            putString(baseUUIDStr, baseUUID)
            putString(charUUIDStr, charUUID)
        }?.apply()
        result.success(null)
        return
    }

    private fun writeCharacteristic(arguments: Any?, result: Result) {
        val listInt = arguments as ByteArray
        Log.d("writeCharacteristic", "writeCharacteristic: ")
        bluetoothReceive?.writeCharacteristic(listInt)
        result.success(true)
    }

    private fun startBackground(result: Result) {
        sharedPreferences?.edit()?.apply {
            putBoolean(isActiveBG, true)
        }?.apply()
        val filter = IntentFilter(BluetoothDevice.ACTION_FOUND)
        filter.addAction(BluetoothAdapter.ACTION_STATE_CHANGED)
        filter.addAction(BluetoothDevice.ACTION_FOUND)
        filter.addAction(BluetoothDevice.ACTION_ACL_CONNECTED)
        filter.addAction(BluetoothDevice.ACTION_ACL_DISCONNECTED)
        filter.addAction(BluetoothAdapter.ACTION_DISCOVERY_FINISHED)

        val bluetoothManager: BluetoothManager? =
            context?.applicationContext?.getSystemService(BluetoothManager::class.java)
        val bluetoothAdapter: BluetoothAdapter? = bluetoothManager?.adapter
        bluetoothReceive = BluetoothReceive(
            context, activity, bluetoothAdapter,
            binaryMessenger, serviceUuids, baseUUID, charUUID
        )

        context?.applicationContext?.registerReceiver(bluetoothReceive, filter)
        val intent = Intent(context, RestartService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context?.applicationContext?.startService(intent)
        }
        bluetoothReceive?.startScan()
        result.success(true)
        return
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
        val intent = Intent(context, RestartService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context?.applicationContext?.startForegroundService(intent)
        }
        sharedPreferences?.edit()?.apply {
            putBoolean(isActiveBG, false)
        }?.apply()
    }
}
