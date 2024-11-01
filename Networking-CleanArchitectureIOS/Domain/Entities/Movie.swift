//
//  Movie.swift
//  Networking-CleanArchitectureIOS
//
//  Created by Đoàn Văn Khoan on 31/10/24.
//

import Foundation

// MARK: - Movie
struct Movie {
    typealias Identifier = String
    
    let id: Identifier
    let title: String?
    let genre: Genre?
    let posterPath: String?
    let overview: String?
    let releaseDate: Date?
}

extension Movie {
    enum Genre {
        case adventure
        case scienceFiction
    }
}

// MARK: - Movie Page
struct MoviesPage {
    let page: Int
    let totalPages: Int
    let movie: [Movie]
}
