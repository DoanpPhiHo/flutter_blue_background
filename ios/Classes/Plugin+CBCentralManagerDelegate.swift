//
//  Plugin+CBCentralManagerDelegate.swift
//  flutter_blue_background
//
//  Created by HoDoan on 11/11/2022.
//

import CoreBluetooth

extension SwiftFlutterBlueBackgroundPlugin : CBCentralManagerDelegate{
    func managerScan(){
        self.manager?.scanForPeripherals(withServices: self.uuidService.map({v in CBUUID.init(string: v)}), options: nil)
    }
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn{
            managerScan()
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("centralManager didFailToConnect \(String(describing: peripheral.name)) \(String(describing: error))")
        managerScan()
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("didDisconnectPeripheral \(String(describing: peripheral.name))")
        managerScan()
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.peripheral!.discoverServices(nil)
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        self.manager?.stopScan()
        self.peripheral = peripheral
        self.peripheral?.delegate = self
        self.manager?.connect(self.peripheral!,options: nil)
    }
}
