//
//  APIEndpoints.swift
//  Networking-CleanArchitectureIOS
//
//  Created by Đoàn Văn Khoan on 1/11/24.
//

import Foundation

// MARK: - API Endpoint

struct APIEndpoints {
    /// Get Endpoint of movies
    static func getMovies(with moviesRequestDTO: MoviesRequestDTO) -> Endpoint<MoviesResponseDTO> {
        
        return Endpoint(
            path: "3/search/movie",
            method: .get,
            queryParametersEncodable: moviesRequestDTO
        )
    }
    
    
    /// Get Endpoint of poster movies
    static func getMoviePoster(path: String, width: Int) -> Endpoint<Data> {
        let sizes = [92, 154, 185, 342, 500, 780]
        let closeWidth = sizes
            .enumerated()
            .min {
                abs($0.1 - width) < abs($1.1 - width)
            }?
            .element ?? sizes.first!
        
        return Endpoint(
            path: "t/p/w\(closeWidth)\(path)",
            method: .get,
            responseDecoder: RawDataResponseDecoder()
        )
    }
}
