//
//  BackgroundFetchWorker.swift
//  flutter_blue_background
//
//  Created by HoDoan on 07/11/2022.
//

import Foundation

typealias VoidInputVoidReturnBlock = () -> Void

class BackgroundFetchWorker {
    let entrypointName = "backgroundEntrypoint"
    let uri = "package:flutter_background_service_ios/flutter_background_service_ios.dart"
    let engine = FlutterEngine(name: "BackgroundHandleFlutterEngine")
    
    var onCompleted: VoidInputVoidReturnBlock?
    var task: ((UIBackgroundFetchResult) -> Void)
    var channel: FlutterMethodChannel?
    
    init(task: @escaping (UIBackgroundFetchResult) -> Void){
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
        self.engine.destroyContext()
        self.task(.failed)
        self.onCompleted?()
    }
    
    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if (call.method == "setBackgroundFetchResult") {
            let result = call.arguments as? Bool ?? false
            
            if (result) {
                self.task(.newData)
            } else {
                self.task(.noData)
            }
            
            self.engine.destroyContext()
            self.onCompleted?()
            print("Flutter Background Service Completed")
        }
    }
}
