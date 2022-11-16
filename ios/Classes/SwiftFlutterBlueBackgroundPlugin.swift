import Flutter
import UIKit
import CoreBluetooth

public class SwiftFlutterBlueBackgroundPlugin: NSObject, FlutterPlugin {
    var baseUUID: String = "00001523-1212-efde-1523-785feabcd123"
    var charUUID: String = "00001524-1212-efde-1523-785feabcd123"
    var uuidService:[String] = ["1808"]
    
    var eventSink: FlutterEventSink?
    
    var peripheral:CBPeripheral?
    var char: CBCharacteristic?
    var manager: CBCentralManager?
    
    var db = DBHelper()
    
    var tastCount:Int = -1
    
    let dbBle = DBBleHelper()
    
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
        case "initial": initialSettings(call,  result)
        case "startBackground":
            startBackground(result: result)
        case "writeCharacteristic":
            writeCharacteristic(data: call.arguments as Any,result: result)
            //db
        case "add_task_async" : addTaskAsync(call, result)
        case "remove_task_async" : removeTaskAsync(call, result)
        case "get_list_task_async" : listTaskAsync(result)
        case "get_list_ble_value": listBleValue(result)
        case "clear_ble_data":clearBleData(result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func listBleValue(_ result: @escaping FlutterResult){
        let resultDb: String? = dbBle.read()
        result(resultDb ?? "")
    }
    
    private func clearBleData(_ result: @escaping FlutterResult){
        let resultDb: Bool = dbBle.removeAll()
        result(resultDb)
    }
    
    private func addTaskAsync(_ call: FlutterMethodCall, _ result: @escaping FlutterResult){
        guard let data: Dictionary<String, Any> = call.arguments as? Dictionary<String,Any> else {return}
        let resultDb: Bool = db.add(task: data["name_tasks"] as! String, taskValue: data["value"] as! String)
        result(resultDb)
    }
    
    private func removeTaskAsync(_ call: FlutterMethodCall, _ result: @escaping FlutterResult){
        guard let data: String = call.arguments as? String else {return}
        let resultDb: Bool = db.remove(task: data)
        result(resultDb)
    }
    
    private func listTaskAsync(_ result: @escaping FlutterResult){
        let resultDb: String? = db.read()
        result(resultDb ?? "")
    }
    
    private func initialSettings(_ call: FlutterMethodCall, _ result: @escaping FlutterResult){
        guard let data: Dictionary<String, Any> = call.arguments as? Dictionary<String,String> else {return}
        if data["baseUUID"] != nil {
            baseUUID = data["baseUUID"] as! String
        }
        if data["charUUID"] != nil {
            charUUID = data["charUUID"] as! String
        }
        if data["uuidService"] != nil && (data["uuidService"] as! [String]).count > 0 {
            uuidService = data["uuidService"] as! [String]
        }
        result(nil)
    }
    
    private func getPlatformVersion(result:@escaping FlutterResult){
        result("iOS " + UIDevice.current.systemVersion)
    }
    
    private func startBackground(result:@escaping FlutterResult){
        self.manager = CBCentralManager(delegate: self, queue: .main)
        result(true)
    }
    
    public func applicationDidEnterBackground(_ application: UIApplication) {
        self.manager = CBCentralManager(delegate: self, queue: .main)
        managerScan()
    }
    
    private func writeCharacteristic(data: Any,result:@escaping FlutterResult){
        let sendBytes:[UInt8] = data as! [UInt8]
        let uint8Pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: sendBytes.count)
        uint8Pointer.initialize(from: sendBytes, count: sendBytes.count)
        let msgData = Data(bytes: uint8Pointer, count: sendBytes.count)
        guard let _char = self.char else {return}
        self.peripheral?.writeValue(msgData, for: _char, type: .withResponse)
        result(true)
    }
}
