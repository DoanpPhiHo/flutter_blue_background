package com.hodoan.flutter_blue_background.db_helper

import android.annotation.SuppressLint
import android.content.ContentValues
import android.content.Context
import android.database.Cursor
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper
import android.util.Log
import java.text.SimpleDateFormat
import java.util.*
import kotlin.collections.ArrayList

class DbBLueAsyncSettingsHelper(context: Context, factory: SQLiteDatabase.CursorFactory?) :
    SQLiteOpenHelper(
        context, DATABASE_NAME, factory, DATABASE_VERSION
    ) {
    override fun onCreate(db: SQLiteDatabase?) {
        val query = ("CREATE TABLE " + TABLE_BLUE_NAME + " ("
                + ID_COL + " INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, " +
                NAME_COl + " TEXT," +
                VALUE_COL + " TEXT" + ")")
        val queryBle = ("CREATE TABLE " + TABLE_BLE_NAME + " ("
                + ID_COL + " INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, " +
                TIME_COL + " TEXT," +
                VALUE_COL + " TEXT" + ")")
        db?.execSQL(query)
        db?.execSQL(queryBle)
    }

    override fun onUpgrade(db: SQLiteDatabase?, oldVersion: Int, newVersion: Int) {
        db?.execSQL("DROP TABLE IF EXISTS $TABLE_BLUE_NAME")
        db?.execSQL("DROP TABLE IF EXISTS $TABLE_BLE_NAME")
        onCreate(db)
    }

    // ============ ble =================

    private fun cursorToModelBle(cursor: Cursor): BleValue {
        return BleValue(
            time = cursor.getString(cursor.getColumnIndexOrThrow(TIME_COL)),
            value = cursor.getString(cursor.getColumnIndexOrThrow(VALUE_COL))
        )
    }

    @SuppressLint("SimpleDateFormat")
    fun add(value: String): Boolean {
        val values = ContentValues()
        val sdf = SimpleDateFormat("dd/MM/yyyy hh:mm:ss")
        val currentDate = sdf.format(Date())
        values.put(TIME_COL, currentDate)
        values.put(VALUE_COL, value)

        val db = this.writableDatabase
        return try {
            db.insert(TABLE_BLE_NAME, null, values)
            true
        } catch (e: java.lang.Exception) {
            Log.d(DbBLueAsyncSettingsHelper::class.java.simpleName, "add: error $e")
            false
        } finally {
            db.close()
        }
    }

    fun removeAll(): Boolean {
        val db = this.writableDatabase
        return try {
            db.delete(TABLE_BLE_NAME, "", arrayOf())
            true
        } catch (e: java.lang.Exception) {
            Log.d(DbBLueAsyncSettingsHelper::class.java.simpleName, "remove: error $e")
            false
        } finally {
            db.close()
        }
    }

    fun argsBle(): List<BleValue> {
        val db = this.readableDatabase
        return try {
            val cursor = db?.rawQuery("SELECT * FROM $TABLE_BLE_NAME", null) ?: return ArrayList()
            val list = ArrayList<BleValue>()
            if (cursor.moveToFirst()) {
                list.add(cursorToModelBle(cursor))
                while (cursor.moveToNext()) {
                    list.add(cursorToModelBle(cursor))
                }
                cursor.close()
                return list
            } else {
                cursor.close()
                return ArrayList()
            }
        } catch (e: java.lang.Exception) {
            Log.d(DbBLueAsyncSettingsHelper::class.java.simpleName, "args: error $e")
            ArrayList()
        } finally {
            db.close()
        }
    }

    // ================ end ble ==============

    private fun cursorToModel(cursor: Cursor): BlueAsync {
        return BlueAsync(
            name = cursor.getString(cursor.getColumnIndexOrThrow(NAME_COl)),
            value = cursor.getString(cursor.getColumnIndexOrThrow(VALUE_COL))
        )
    }

    fun add(name: String, value: String): Boolean {
        val values = ContentValues()
        values.put(NAME_COl, name)
        values.put(VALUE_COL, value)

        val db = this.writableDatabase
        return try {
            db.insert(TABLE_BLUE_NAME, null, values)
            true
        } catch (e: java.lang.Exception) {
            Log.d(DbBLueAsyncSettingsHelper::class.java.simpleName, "add: error $e")
            false
        } finally {
            db.close()
        }
    }

    fun remove(name: String): Boolean {
        val db = this.writableDatabase
        return try {
            db.delete(TABLE_BLUE_NAME, "$NAME_COl = ?", arrayOf(name))
            true
        } catch (e: java.lang.Exception) {
            Log.d(DbBLueAsyncSettingsHelper::class.java.simpleName, "remove: error $e")
            false
        } finally {
            db.close()
        }
    }

    fun args(): List<BlueAsync> {
        val db = this.readableDatabase
        val cursor = db?.rawQuery("SELECT * FROM $TABLE_BLUE_NAME", null) ?: return ArrayList()

        val list = java.util.ArrayList<BlueAsync>()
        if (cursor.moveToFirst()) {
            list.add(cursorToModel(cursor))
            while (cursor.moveToNext()) {
                list.add(cursorToModel(cursor))
            }
            cursor.close()
            db.close()
            return list
        }
        cursor.close()
        db.close()
        return ArrayList()
    }

    fun argsNoTurnOff(): List<BlueAsync> {
        val db = this.readableDatabase
        val resultDb =
            db?.rawQuery("SELECT * FROM $TABLE_BLUE_NAME WHERE name != ?", arrayOf(TURN_OFF))
                ?: return ArrayList()
        val list = ArrayList<BlueAsync>()
        if (resultDb.moveToFirst()) {
            list.add(cursorToModel(resultDb))
            while (resultDb.moveToNext()) {
                list.add(cursorToModel(resultDb))
            }
            resultDb.close()
            db.close()
            return list
        }

        resultDb.close()
        db.close()
        return ArrayList()
    }

    fun turnOff(): List<BlueAsync> {
        Log.d(DbBLueAsyncSettingsHelper::class.simpleName, "turnOff: ")
        val db = this.readableDatabase
        val cursor =
            db?.rawQuery("SELECT * FROM $TABLE_BLUE_NAME WHERE name = ?", arrayOf(TURN_OFF))
                ?: return ArrayList()
        val list = ArrayList<BlueAsync>()
        if (cursor.moveToFirst()) {
            list.add(cursorToModel(cursor))
            cursor.close()
            db.close()
            return list
        }
        cursor.close()
        db.close()
        return ArrayList()
    }

    companion object {
        private const val DATABASE_NAME = "BLUE_ASYNC_SETTINGS"

        private const val DATABASE_VERSION = 4

        const val TABLE_BLUE_NAME = "blue_settings"
        const val TABLE_BLE_NAME = "ble_value"

        const val ID_COL = "id"

        const val TURN_OFF = "turn_off"

        const val TIME_COL = "time"

        const val NAME_COl = "name"

        const val VALUE_COL = "value"
    }
}

class BlueAsync(val name: String, val value: String)

class BleValue(val time: String, val value: String)