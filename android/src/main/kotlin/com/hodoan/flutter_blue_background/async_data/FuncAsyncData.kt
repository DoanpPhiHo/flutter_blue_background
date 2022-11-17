package com.hodoan.flutter_blue_background.async_data

import android.bluetooth.BluetoothGatt
import android.content.Context
import android.os.Build
import androidx.annotation.RequiresApi
import com.hodoan.flutter_blue_background.db_helper.BlueAsync
import com.hodoan.flutter_blue_background.db_helper.DbBLueAsyncSettingsHelper
import com.hodoan.flutter_blue_background.db_helper.DbBleValueHelper
import java.util.*

class FuncAsyncData {
    fun turnOffBle(context: Context?, gatt: BluetoothGatt?, baseUUID: String?, charUUID: String?) {
        context?.let {
            val db = DbBLueAsyncSettingsHelper(it, null)
            val resultDb = db.turnOff()
            val list = ArrayList<BlueAsync>()
            if (resultDb == null) return
            list.add(db.cursorToModel(resultDb))
            for (item in list) {
                val listInt: List<Byte> = item.value.split(",") as List<Byte>
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
                    gatt,
                    baseUUID ?: "00001523-1212-efde-1523-785feabcd123",
                    charUUID ?: "00001524-1212-efde-1523-785feabcd123",
                    data
                )
            }
        }
    }

    @SuppressWarnings("MissingPermission")
    fun writeData(gatt: BluetoothGatt?, baseUUID: String, charUUID: String, bytes: ByteArray) {
        val service = gatt?.getService(UUID.fromString(baseUUID)) ?: return
        val characteristic = service.getCharacteristic(UUID.fromString(charUUID)) ?: return
        characteristic.value = bytes
        gatt.setCharacteristicNotification(characteristic, true)
        gatt.writeCharacteristic(characteristic)
    }

    @RequiresApi(Build.VERSION_CODES.O)
    fun savaDataDB(context: Context?, value: List<Int>) {
        context?.let {
            val db = DbBleValueHelper(it, null)
            db.add(value.joinToString { "," })
        }
    }

    @SuppressWarnings("MissingPermission")
    fun autoWriteValue(
        context: Context?,
        gatt: BluetoothGatt?,
        baseUUID: String?,
        charUUID: String?
    ) {
        context?.let {
            val db = DbBLueAsyncSettingsHelper(it, null)
            val resultDb = db.argsNoTurnOff()
            val list = ArrayList<BlueAsync>()
            if (resultDb == null) return
            list.add(db.cursorToModel(resultDb))
            while (resultDb.moveToNext()) {
                list.add(db.cursorToModel(resultDb))
            }
            for (item in list) {
                val listInt: List<Byte> = item.value.split(",") as List<Byte>
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
                    gatt, baseUUID ?: "00001523-1212-efde-1523-785feabcd123",
                    charUUID ?: "00001524-1212-efde-1523-785feabcd123", data
                )
            }
        }
    }
}