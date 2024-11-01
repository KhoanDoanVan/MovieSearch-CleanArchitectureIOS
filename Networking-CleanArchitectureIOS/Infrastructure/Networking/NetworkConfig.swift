//
//  NetworkConfig.swift
//  Networking-CleanArchitectureIOS
//
//  Created by Đoàn Văn Khoan on 31/10/24.
//

import Foundation

// MARK: Network Configuration
protocol NetworkConfigurable {
    var baseURL: URL { get }
    var headers: [String: String] { get }
    var queryParameters: [String: String] { get }
}


// MARK: Api Data Network Config
struct ApiDataNetworkConfig: NetworkConfigurable {
    /// Properties be inherited from NetworkConfigurable
    let baseURL: URL
    let headers: [String : String]
    let queryParameters: [String : String]
    
    init(
        baseURL: URL,
        headers: [String : String] = [:],
        queryParameters: [String : String] = [:]
    ) {
        self.baseURL = baseURL
        self.headers = headers
        self.queryParameters = queryParameters
    }
}
