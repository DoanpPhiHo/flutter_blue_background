import Flutter
import UIKit
import CoreBluetooth

public class SwiftFlutterBlueBackgroundPlugin: NSObject, FlutterPlugin {
    private let baseUUID: String = "00001523-1212-efde-1523-785feabcd123"
    private let charUUID: String = "00001524-1212-efde-1523-785feabcd123"
    
    var eventSink: FlutterEventSink?
    
    private var peripheral:CBPeripheral?
    private var char: CBCharacteristic?
    private var manager: CBCentralManager?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = SwiftFlutterBlueBackgroundPlugin()
        let eventChannel = FlutterEventChannel(name: "flutter_blue_background/write_data_status", binaryMessenger: registrar.messenger())
        let channel = FlutterMethodChannel(name: "flutter_blue_background", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: channel)
        eventChannel.setStreamHandler(instance)
        registrar.addApplicationDelegate(instance)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            getPlatformVersion(result: result)
        case "startBackground":
            startBackground(result: result)
        case "writeCharacteristic":
            writeCharacteristic(data: call.arguments as Any,result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    private func getPlatformVersion(result:@escaping FlutterResult){
        result("iOS " + UIDevice.current.systemVersion)
    }
    
    private func startBackground(result:@escaping FlutterResult){
        self.manager = CBCentralManager(delegate: self, queue: .main)
        result(true)
    }
    
    private func writeCharacteristic(data: Any,result:@escaping FlutterResult){
        //        guard let args = data as? FlutterStandardTypedData else { return }
        eventSink?("0")
        let sendBytes:[UInt8] = data as! [UInt8]
        let uint8Pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: sendBytes.count)
        uint8Pointer.initialize(from: sendBytes, count: sendBytes.count)
        let msgData = Data(bytes: uint8Pointer, count: sendBytes.count)
        guard let _char = self.char else {return}
        self.peripheral?.writeValue(msgData, for: _char, type: .withResponse)
        result(true)
    }
}

extension SwiftFlutterBlueBackgroundPlugin : FlutterStreamHandler {
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
    
    
}

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

extension SwiftFlutterBlueBackgroundPlugin : CBCentralManagerDelegate{
    private func managerScan(){
        self.manager?.scanForPeripherals(withServices: ["1808"].map({uuid in CBUUID.init(string: uuid)}), options: nil)
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
