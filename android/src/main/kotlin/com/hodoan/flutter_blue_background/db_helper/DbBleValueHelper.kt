package com.hodoan.flutter_blue_background.db_helper

import android.annotation.SuppressLint
import android.content.ContentValues
import android.content.Context
import android.database.Cursor
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper
import android.os.Build
import android.util.Log
import androidx.annotation.RequiresApi
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter

class DbBleValueHelper(context: Context, factory: SQLiteDatabase.CursorFactory?) :
    SQLiteOpenHelper(
        context, DATABASE_NAME, factory, DATABASE_VERSION
    ) {
    override fun onCreate(db: SQLiteDatabase?) {
        val query = ("CREATE TABLE " + TABLE_NAME + " ("
                + ID_COL + " INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, " +
                TIME_COL + " TEXT," +
                VALUE_COL + " TEXT" + ")")
        db?.execSQL(query)
    }

    override fun onUpgrade(db: SQLiteDatabase?, oldVersion: Int, newVersion: Int) {
        db?.execSQL("DROP TABLE IF EXISTS $TABLE_NAME")
        onCreate(db)
    }

    @SuppressLint("Range")
    fun cursorToModel(cursor: Cursor): BleValue {
        return BleValue(
            time = cursor.getString(cursor.getColumnIndex(TIME_COL)),
            value = cursor.getString(cursor.getColumnIndex(VALUE_COL))
        )
    }

    @RequiresApi(Build.VERSION_CODES.O)
    fun add(value: String): Boolean {
        val values = ContentValues()
        val formatter = DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm:ss")
        val current = LocalDateTime.now().format(formatter)
        values.put(TIME_COL, current)
        values.put(VALUE_COL, value)

        val db = this.writableDatabase
        return try {
            db.insert(TABLE_NAME, null, values)
            true
        } catch (e: java.lang.Exception) {
            Log.d(DbBleValueHelper::class.java.simpleName, "add: error $e")
            false
        } finally {
            db.close()
        }
    }

    fun removeAll(): Boolean {
        val db = this.writableDatabase
        return try {
            db.delete(TABLE_NAME, "", arrayOf())
            true
        } catch (e: java.lang.Exception) {
            Log.d(DbBLueAsyncSettingsHelper::class.java.simpleName, "remove: error $e")
            false
        } finally {
            db.close()
        }
    }

    fun args(): Cursor? {
        val db = this.readableDatabase
        return db?.rawQuery("SELECT * FROM $TABLE_NAME", null)
    }

    companion object {
        private const val DATABASE_NAME = "BLUE_ASYNC_SETTINGS"

        private const val DATABASE_VERSION = 1

        const val TABLE_NAME = "ble_value"

        const val ID_COL = "id"

        const val TIME_COL = "time"

        const val VALUE_COL = "value"
    }
}

class BleValue(val time:String,val value:String)