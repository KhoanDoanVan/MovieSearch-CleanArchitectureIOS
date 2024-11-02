//
//  RepositoryTask.swift
//  Networking-CleanArchitectureIOS
//
//  Created by Đoàn Văn Khoan on 2/11/24.
//

import Foundation

final class RepositoryTask: Cancellable {
    
    var networkTask: NetworkCancellable?
    var isCancelled: Bool = false
    
    func cancel() {
        networkTask?.cancel()
        isCancelled = true
    }
    
    
}
