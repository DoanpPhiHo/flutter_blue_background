//
//  BackgroundRefreshAppWorker.swift
//  flutter_blue_background
//
//  Created by HoDoan on 07/11/2022.
//

import Foundation
import BackgroundTasks

@available(iOS 13.0, *)
class BackgroundRefreshAppWorker {
    let entrypointName = "backgroundEntrypoint"
    let uri = "package:flutter_background_service_ios/flutter_background_service_ios.dart"
    let engine = FlutterEngine(name: "BackgroundHandleFlutterEngine")
    
    var onCompleted: VoidInputVoidReturnBlock?
    var task: BGAppRefreshTask
    var channel: FlutterMethodChannel?
    
    init(task: BGAppRefreshTask){
        self.task = task
    }
    
    public func run() {
        let defaults = UserDefaults.standard
        let callbackHandle = defaults.object(forKey: "background_callback_handle") as? Int64
        if (callbackHandle == nil){
            print("No callback handle for background")
            return
        }
        
        let isRunning = engine.run(withEntrypoint: entrypointName, libraryURI: uri, initialRoute: nil, entrypointArgs: [String(callbackHandle!)])
        
        if (isRunning){
            SwiftFlutterBlueBackgroundPlugin.register(with: engine as! FlutterPluginRegistrar)
            
            let binaryMessenger = engine.binaryMessenger
            channel = FlutterMethodChannel(name: "id.flutter/background_service_ios_bg", binaryMessenger: binaryMessenger, codec: FlutterJSONMethodCodec())
            channel?.setMethodCallHandler(handleMethodCall)
        }
    }
    
    public func cancel(){
        DispatchQueue.main.async {
            self.engine.destroyContext()
        }
        
        self.task.setTaskCompleted(success: false)
        self.onCompleted?()
    }
    
    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if (call.method == "setBackgroundFetchResult") {
            let result = call.arguments as? Bool ?? false
            self.task.setTaskCompleted(success: result)
            
            DispatchQueue.main.async {
                self.engine.destroyContext()
            }
            
            self.onCompleted?()
            print("Flutter Background Service Completed")
        }
    }
}
