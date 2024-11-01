//
//  MoviesRequestDTO.swift
//  Networking-CleanArchitectureIOS
//
//  Created by Đoàn Văn Khoan on 1/11/24.
//


import Foundation


struct MoviesRequestDTO: Encodable {
    let query: String
    let page: Int
}
