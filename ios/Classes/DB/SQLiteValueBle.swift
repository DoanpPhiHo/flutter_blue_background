//
//  SQLiteValueBle.swift
//  flutter_blue_background
//
//  Created by HoDoan on 16/11/2022.
//

import Foundation
import SQLite3

public class DBBleHelper{
    var db: OpaquePointer?
    var path: String = "flutter_blue_async.sqlite"
    var tableName = "ble_model"
    init(){
        self.db = createDB()
        self.createTable()
    }
    
    func createDB()->OpaquePointer?{
        let filePath = try! FileManager.default.url(for: .documentDirectory,
                                                    in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent(path)
        var db: OpaquePointer? = nil
        if sqlite3_open(filePath.path, &db) != SQLITE_OK {
            print("create db fail")
            return nil
        }else {
            print("create db success")
            return db
        }
    }
    
    func createTable(){
        let query = "create table if not exists \(tableName)(id integer primary key autoincrement, time text, value text)"
        var statement: OpaquePointer? = nil
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK{
            if sqlite3_step(statement) == SQLITE_DONE{
                print("create tb success")
            }else{
                print("create tb fail")
            }
        }else{
            print("prepare fail")
        }
        sqlite3_finalize(statement)
    }
    
    func getTime()->String{
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let second = calendar.component(.second, from: date)
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        return "\(year)/\(month)/\(day) \(hour):\(minutes):\(second)"
    }
    
    func add(taskValue value:String)->Bool{
        let query = "insert into \(tableName)(time,value) values (?,?)"
            
        var statement:OpaquePointer? = nil
        if sqlite3_prepare_v2(db,query, -1,&statement, nil) == SQLITE_OK{
            sqlite3_bind_text(statement, 1, (getTime() as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (value as NSString).utf8String, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_DONE{
                print("insert success")
                return true
            }else{
                print("insert fail")
                return false
            }
        }else{
            print("statement fail")
            return false
        }
    }
    
    func removeAll()->Bool{
        let query = "delete from \(tableName)"
        var statement : OpaquePointer? = nil
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
            if sqlite3_step(statement) == SQLITE_DONE{
                print("delete success")
            }else{
                print("insert fail")
                return false
            }
            return true
        }else{
            print("statement fail")
            return false
        }
    }
    
    func read() -> String? {
        var result: [BleModel] = []
        let query = "select * from \(tableName)"
        var statement:OpaquePointer? = nil
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
            while sqlite3_step(statement) == SQLITE_ROW{
                let time:String = String(cString: sqlite3_column_text(statement,1))
                let value = String(cString: sqlite3_column_text(statement,2))
                result.append(BleModel(time: time, value: value))
            }
        }
        let data = try? JSONEncoder().encode( result)
        guard let json:Data = data else {return nil}
        return String(data: json, encoding: .utf8)
    }
    
    
    
    func readModel() -> [BleModel] {
        var result: [BleModel] = []
        let query = "select * from \(tableName)"
        var statement:OpaquePointer? = nil
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
            while sqlite3_step(statement) == SQLITE_ROW{
                let time:String = String(cString: sqlite3_column_text(statement,1))
                let value = String(cString: sqlite3_column_text(statement,2))
                result.append(BleModel(time: time, value: value))
            }
        }
        return result
    }

}
struct BleModel: Codable{
    let time:String
    let value:String
}
