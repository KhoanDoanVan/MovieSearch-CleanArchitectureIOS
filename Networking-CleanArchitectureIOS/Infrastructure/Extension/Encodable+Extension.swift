//
//  Encodable+Extension.swift
//  Networking-CleanArchitectureIOS
//
//  Created by Đoàn Văn Khoan on 31/10/24.
//

import Foundation

extension Encodable {
    func toDictionary() throws -> [String: Any]? {
        let data = try JSONEncoder().encode(self)
        let jsonData = try JSONSerialization.jsonObject(with: data)
        return jsonData as? [String:Any]
    }
}
