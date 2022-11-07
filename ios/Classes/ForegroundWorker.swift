//
//  ForegroundWorker.swift
//  flutter_blue_background
//
//  Created by HoDoan on 07/11/2022.
//

import Foundation
class ForegroundWorker {
    let entrypointName = "foregroundEntrypoint"
    let uri = "package:flutter_background_service_ios/flutter_background_service_ios.dart"
    let engine = FlutterEngine(name: "ForegroundHandleFlutterEngine")
    
    var channel: FlutterMethodChannel?
    var mainChannel: FlutterMethodChannel
    var onTerminated: VoidInputVoidReturnBlock?
    
    init(mainChannel: FlutterMethodChannel){
        self.mainChannel = mainChannel
    }
    
    public func run() {
        let defaults = UserDefaults.standard
        let callbackHandle = defaults.object(forKey: "foreground_callback_handle") as? Int64
        if (callbackHandle == nil){
            print("No callback handle for foreground")
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
    
    public func onReceivedData(data: Any?) {
        self.channel?.invokeMethod("onReceiveData", arguments: data)
    }
    
    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if (call.method == "sendData") {
            self.mainChannel.invokeMethod("onReceiveData", arguments: call.arguments)
            result(true);
            return;
        }
        
        if (call.method == "stopService") {
            self.engine.destroyContext()
            result(true)
            self.onTerminated?()
            return;
        }
    }
}
