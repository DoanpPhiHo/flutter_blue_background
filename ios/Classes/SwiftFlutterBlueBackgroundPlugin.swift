import Flutter
import UIKit
import CoreBluetooth
import BackgroundTasks

public class SwiftFlutterBlueBackgroundPlugin: NSObject, FlutterPlugin {
    public static var taskIdentifier = "dev.flutter.background.refresh"
    
    //    private var manager: CBCentralManager = CBCentralManager(delegate: self, queue: .main)
    private var peripherals:[CBPeripheral] = []
    public var peripheralNames:[String]=[]
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_blue_background", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterBlueBackgroundPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    @available(iOS 13.0, *)
    private static func handleAppRefresh(task: BGAppRefreshTask) {
        let defaults = UserDefaults.standard
        let callbackHandle = defaults.object(forKey: "background_callback_handle") as? Int64
        if (callbackHandle == nil){
            print("Background handler is disabled")
            return
        }
        
        let operationQueue = OperationQueue()
        let operation = BackgroundRefreshAppOperation(
            task: task
        )
        
        operation.completionBlock = {
            scheduleAppRefresh()
        }
        
        operationQueue.addOperation(operation)
    }
    
    @available(iOS 13.0, *)
    public static func registerTaskIdentifier(taskIdentifier: String) {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: taskIdentifier, using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
    }
    
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable : Any] = [:]) -> Bool {
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        if #available(iOS 13, *){
            SwiftFlutterBlueBackgroundPlugin.registerTaskIdentifier(taskIdentifier:   SwiftFlutterBlueBackgroundPlugin.taskIdentifier)
        }
        return true
    }
    
    @available(iOS 13.0, *)
    private static func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: SwiftFlutterBlueBackgroundPlugin.taskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
        
        do {
            // cancel old schedule
            BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: SwiftFlutterBlueBackgroundPlugin.taskIdentifier)
            
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            getPlatformVersion(result: result)
        case "startBackground":
            startBackground(result: result)
        case "writeCharacteristic":
            writeCharacteristic(data: call.arguments as! [Int],result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    private func getPlatformVersion(result:@escaping FlutterResult){
        result("iOS " + UIDevice.current.systemVersion)
    }
    private func startBackground(result:@escaping FlutterResult){
//        self.manager.scanForPeripherals(withServices: nil)
    }
    
    private func writeCharacteristic(data:[Int],result:@escaping FlutterResult){
        
    }
}

//extension SwiftFlutterBlueBackgroundPlugin : CBCentralManagerDelegate{
//    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
//        if central.state == .poweredOff{
//            self.manager.scanForPeripherals(withServices: nil)
//        }
//    }
//
//    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
//        if !peripherals.contains( peripheral){
//            self.peripherals.append( peripheral)
//            print(peripheral.name ?? "print name")
//            self.peripheralNames.append(peripheral.name ?? "device noname")
//        }
//    }
//}
