//
//  BackgroundRefreshAppOperation.swift
//  flutter_blue_background
//
//  Created by HoDoan on 07/11/2022.
//

import BackgroundTasks
import Foundation
@available(iOS 13.0, *)
class BackgroundRefreshAppOperation: Operation {
    var task: BGAppRefreshTask
    fileprivate var worker: BackgroundRefreshAppWorker?
    
    init(task: BGAppRefreshTask) {
        self.task = task
    }
    
    override func main() {
        let semaphore = DispatchSemaphore(value: 0)
        
        DispatchQueue.main.async {
            self.worker = BackgroundRefreshAppWorker(task: self.task)
            self.worker?.onCompleted = {
                semaphore.signal()
            }
            
            self.task.expirationHandler = {
                self.worker?.cancel()
            }
            
            self.worker?.run()
        }
        
        semaphore.wait()
    }
}
