package com.hodoan.flutter_blue_background.services

import android.annotation.SuppressLint
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.os.IBinder
import android.provider.ContactsContract
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.core.app.NotificationCompat
import com.hodoan.flutter_blue_background.R

class RestartService : Service() {
    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onCreate() {
        super.onCreate()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        sendNotification()
        blueInit()
        return START_STICKY
    }

    private fun blueInit() {
        val filter = IntentFilter(BluetoothDevice.ACTION_FOUND)
        filter.addAction(BluetoothAdapter.ACTION_STATE_CHANGED)
        filter.addAction(BluetoothDevice.ACTION_FOUND)
        filter.addAction(BluetoothDevice.ACTION_ACL_CONNECTED)
        filter.addAction(BluetoothDevice.ACTION_ACL_DISCONNECTED)
        filter.addAction(BluetoothAdapter.ACTION_DISCOVERY_FINISHED)
        val bluetoothReceive = BluetoothForegroundReceive()

        registerReceiver(bluetoothReceive, filter)
        bluetoothReceive.startScan()
    }

    private fun sendNotification() {

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val mChannel = NotificationChannel(
                BluetoothReceive::channelId.toString(),
                "General Notifications",
                NotificationManager.IMPORTANCE_HIGH
            )
            mChannel.description = "This is default channel used for all other notifications"

            val notificationManager =
                getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(mChannel)
        }

        val intent = Intent(this, ContactsContract.Profile::class.java)
        val pendingIntent =
            PendingIntent.getActivity(this, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT)

        val notification = NotificationCompat.Builder(this, BluetoothReceive::channelId.toString())
            .setSmallIcon(R.drawable.ic_stat_name)
            .setContentTitle("running service")
            .setContentText("start")
            .setContentIntent(pendingIntent)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .build()
        try {
            startForeground(1, notification)
        } catch (e: java.lang.Exception) {
            Log.d(RestartService::class.java.simpleName, "sendNotification: e")
        }
    }

    @RequiresApi(Build.VERSION_CODES.O)
    override fun onDestroy() {
        super.onDestroy()
//        val intent = Intent(this, BluetoothForegroundReceive::class.java)
//        startForegroundService(intent)
//        sendBroadcast(intent)
    }
}