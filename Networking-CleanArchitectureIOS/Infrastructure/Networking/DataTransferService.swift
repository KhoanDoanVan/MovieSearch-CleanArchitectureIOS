//
//  DataTransferService.swift
//  Networking-CleanArchitectureIOS
//
//  Created by Đoàn Văn Khoan on 31/10/24.
//

import Foundation

protocol ResponseDecoder {
    func decode<T: Decodable>(_ data: Data) throws -> T
}
