package com.hodoan.flutter_blue_background.services

import android.app.Service
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.annotation.RequiresApi

class RestartService : Service() {
    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    private var context: Context? = null

    override fun onCreate() {
        super.onCreate()
        context = this
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
         super.onStartCommand(intent, flags, startId)
        return START_STICKY
    }

    @RequiresApi(Build.VERSION_CODES.O)
    override fun onTaskRemoved(rootIntent: Intent?) {
        Log.d(RestartService::class.java.simpleName, "onTaskRemoved: ")
        val intent = Intent(this, BluetoothReceive::class.java)
        startForegroundService(intent)
        sendBroadcast(intent)
        val filter = IntentFilter(BluetoothDevice.ACTION_FOUND)
        filter.addAction(BluetoothAdapter.ACTION_STATE_CHANGED)
        filter.addAction(BluetoothDevice.ACTION_FOUND)
        filter.addAction(BluetoothDevice.ACTION_ACL_CONNECTED)
        filter.addAction(BluetoothDevice.ACTION_ACL_DISCONNECTED)
        filter.addAction(BluetoothAdapter.ACTION_DISCOVERY_FINISHED)
        val bluetoothReceive = BluetoothForegroundReceive()

        context?.applicationContext?.registerReceiver(bluetoothReceive, filter)
        bluetoothReceive.startScan()
        super.onTaskRemoved(rootIntent)
    }
}