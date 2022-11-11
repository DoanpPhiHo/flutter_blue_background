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
        default:
            result(FlutterMethodNotImplemented)
        }
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
