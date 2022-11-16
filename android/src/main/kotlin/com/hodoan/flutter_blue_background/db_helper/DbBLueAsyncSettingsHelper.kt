package com.hodoan.flutter_blue_background.db_helper

import android.annotation.SuppressLint
import android.content.ContentValues
import android.content.Context
import android.database.Cursor
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper
import android.util.Log
import org.json.JSONObject

class DbBLueAsyncSettingsHelper(context: Context, factory: SQLiteDatabase.CursorFactory?) :
    SQLiteOpenHelper(
        context, DATABASE_NAME, factory, DATABASE_VERSION
    ) {
    override fun onCreate(db: SQLiteDatabase?) {
        val query = ("CREATE TABLE " + TABLE_NAME + " ("
                + ID_COL + " INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, " +
                NAME_COl + " TEXT," +
                VALUE_COL + " TEXT" + ")")
        db?.execSQL(query)
    }

    override fun onUpgrade(db: SQLiteDatabase?, oldVersion: Int, newVersion: Int) {
        db?.execSQL("DROP TABLE IF EXISTS $TABLE_NAME")
        onCreate(db)
    }

    @SuppressLint("Range")
    fun cursorToString(cursor: Cursor): String {
        val result = mutableMapOf(
            Pair("name_tasks", cursor.getString(cursor.getColumnIndex(NAME_COl))),
            Pair("value", cursor.getString(cursor.getColumnIndex(VALUE_COL)))
        )
        return JSONObject(result as Map<*, *>).toString()
    }

    @SuppressLint("Range")
    fun cursorToModel(cursor: Cursor): BlueAsync {
        return BlueAsync(
            name = cursor.getString(cursor.getColumnIndex(NAME_COl)),
            value = cursor.getString(cursor.getColumnIndex(VALUE_COL))
        )
    }

    fun add(name: String, value: String): Boolean {
        val values = ContentValues()
        values.put(NAME_COl, name)
        values.put(VALUE_COL, value)

        val db = this.writableDatabase
        return try {
            db.insert(TABLE_NAME, null, values)
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
            db.delete(TABLE_NAME, "$NAME_COl = ?", arrayOf(name))
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

        const val TABLE_NAME = "blue_settings"

        const val ID_COL = "id"

        const val NAME_COl = "name"

        const val VALUE_COL = "value"
    }
}

class BlueAsync(val name:String,val value:String)