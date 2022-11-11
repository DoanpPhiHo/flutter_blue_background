//
//  Plugin+FlutterStreamHandler.swift
//  flutter_blue_background
//
//  Created by HoDoan on 11/11/2022.
//

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
