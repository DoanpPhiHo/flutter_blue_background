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
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let charValue = characteristic.value else {return}
        let value = [UInt8](charValue)
        eventSink?(value)
    }
}
