//
//  AppConfiguration.swift
//  Networking-CleanArchitectureIOS
//
//  Created by Đoàn Văn Khoan on 1/11/24.
//

import Foundation

final class AppConfiguration {
    
    static let shared = AppConfiguration()
    
    /// API KEY
    lazy var apiKey: String = {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "ApiKey") as? String else {
            fatalError("ApiKey must not be empty in plist")
        }
        return apiKey
    }()
    
    /// API BASE URL
    lazy var apiBaseURL: String = {
        guard let apiBaseURL = Bundle.main.object(forInfoDictionaryKey: "ApiBaseURL") as? String else {
            fatalError("ApiBaseURL must not be empty in plist")
        }
        return apiBaseURL
    }()
}
