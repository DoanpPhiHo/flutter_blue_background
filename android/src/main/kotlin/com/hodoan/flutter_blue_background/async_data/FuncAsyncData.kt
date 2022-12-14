package com.hodoan.flutter_blue_background.async_data

import android.Manifest
import android.bluetooth.BluetoothGatt
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.location.LocationManager
import android.os.Build
import android.provider.Settings
import androidx.core.app.ActivityCompat
import com.hodoan.flutter_blue_background.db_helper.DbBLueAsyncSettingsHelper
import java.util.*


class FuncAsyncData {
    fun turnOffBle(context: Context?, gatt: BluetoothGatt?, baseUUID: String?, charUUID: String?) {
        context?.let {
            val db = DbBLueAsyncSettingsHelper(it, null)
            val resultDb = db.turnOff()
            for (item in resultDb) {
                val listInt: List<Byte> =
                    item.value.split(",").map { v -> v.toInt() }.map { v -> v.toByte() }
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
                writeData(
                    context,
                    gatt,
                    baseUUID ?: "00001523-1212-efde-1523-785feabcd123",
                    charUUID ?: "00001524-1212-efde-1523-785feabcd123",
                    data
                )
            }
        }
    }

    private fun writeData(
        context: Context?,
        gatt: BluetoothGatt?,
        baseUUID: String,
        charUUID: String,
        bytes: ByteArray
    ) {
        val service = gatt?.getService(UUID.fromString(baseUUID)) ?: return
        val characteristic = service.getCharacteristic(UUID.fromString(charUUID)) ?: return
        characteristic.value = bytes
        if (context != null) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                if (ActivityCompat.checkSelfPermission(
                        context,
                        Manifest.permission.BLUETOOTH_CONNECT
                    ) == PackageManager.PERMISSION_GRANTED
                ) {
                    gatt.setCharacteristicNotification(characteristic, true)
                    gatt.writeCharacteristic(characteristic)
                }
            } else {
                gatt.setCharacteristicNotification(characteristic, true)
                gatt.writeCharacteristic(characteristic)
            }
        }
    }

    fun savaDataDB(context: Context?, value: ByteArray) {
        context?.let {
            val db = DbBLueAsyncSettingsHelper(it, null)
            db.add(value.map {v->
                java.lang.Byte.toUnsignedInt(v).toString(radix = 10).padStart(2, '0').toInt()
            }.joinToString())
        }
    }

    fun isLocationEnabled(context: Context): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            // This is a new method provided in API 28
            val lm: LocationManager =
                context.getSystemService(Context.LOCATION_SERVICE) as LocationManager
            lm.isLocationEnabled
        } else {
            // This was deprecated in API 28
            val mode: Int = Settings.Secure.getInt(
                context.contentResolver, Settings.Secure.LOCATION_MODE,
                Settings.Secure.LOCATION_MODE_OFF
            )
            mode != Settings.Secure.LOCATION_MODE_OFF
        }
    }

    fun enableLocation(context: Context) {
        val intent = Intent(
            Settings.ACTION_LOCATION_SOURCE_SETTINGS
        )
        context.startActivity(intent)
    }
}