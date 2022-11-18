//
//  Plugin+CBPeripheralDelegate.swift
//  flutter_blue_background
//
//  Created by HoDoan on 11/11/2022.
//

import CoreBluetooth

extension SwiftFlutterBlueBackgroundPlugin : CBPeripheralDelegate{
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services ?? [] {
            if service.uuid.uuidString.lowercased() == baseUUID.lowercased(){
                self.peripheral!.discoverCharacteristics(nil, for: service)
            }
        }
    }
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for char in service.characteristics ?? [] {
            if char.uuid.uuidString.lowercased() == charUUID.lowercased(){
                self.char = char
                self.peripheral?.setNotifyValue(true, for: char)
                sendListTaskDb()
            }
        }
    }
    
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    func sendListTaskDb(){
        guard let _char = self.char else {return}
        let listTask:[BlueModel] = db.readModel()
        
        self.tastCount = listTask.count
        
        for task in listTask {
            let index:Int = listTask.firstIndex(where: {$0.name == task.name})!
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0 +  Double(index)){
                let sendBytes:[UInt8] = task.value
                
                let uint8Pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: sendBytes.count)
                uint8Pointer.initialize(from: sendBytes, count: sendBytes.count)
                let msgData = Data(bytes: uint8Pointer, count: sendBytes.count)
                
                self.peripheral?.writeValue( msgData, for: _char, type: .withResponse)

            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let charValue = characteristic.value else {return}
        let value = [UInt8](charValue)
        eventSink?(value)
        self.tastCount -= 1
        print("tastCount: \(tastCount)")
        if self.tastCount == 0{
            // kill ble
            let task:BlueModel? = db.readModelTurnOff()
            let _char = self.char
            if task != nil && _char != nil {
                let sendBytes:[UInt8] = task!.value
                
                let uint8Pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: sendBytes.count)
                uint8Pointer.initialize(from: sendBytes, count: sendBytes.count)
                let msgData = Data(bytes: uint8Pointer, count: sendBytes.count)

                self.peripheral?.writeValue( msgData, for: _char!, type: .withResponse)
            }
            self.tastCount = -1
        }
        let _ = dbBle.add(taskValue: value.map({v in String(v)}).joined(separator: ","))
    }
}
