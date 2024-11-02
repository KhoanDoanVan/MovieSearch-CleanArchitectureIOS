//
//  SearchMoviesUseCase.swift
//  Networking-CleanArchitectureIOS
//
//  Created by Đoàn Văn Khoan on 1/11/24.
//

import Foundation

// MARK: - Search Movies Use Case

protocol SearchMoviesUseCase {
    func execute(
        requestValue: SearchMoviesUseCaseRequestValue,
        completion: @escaping (Result<MoviesPage, Error>) -> Void
    ) -> Cancellable?
}

final class DefaultSearchMoviesUseCase: SearchMoviesUseCase {
    
    // Properties
    private let moviesRepository: MoviesRepository
//    private let moviesQueriesRepository: MoviesQueriesRepository
    
    init(
        moviesRepository: MoviesRepository
//        moviesQueriesRepository: MoviesQueriesRepository
    ) {
        self.moviesRepository = moviesRepository
//        self.moviesQueriesRepository = moviesQueriesRepository
    }
    
    func execute(
        requestValue: SearchMoviesUseCaseRequestValue,
        completion: @escaping (Result<MoviesPage, Error>) -> Void
    ) -> (Cancellable)? {
                
        return moviesRepository.fetchMoviesList(
            query: requestValue.query,
            page: requestValue.page
        ) { result in
                
//                if case .success = result {
//                    self.moviesQueriesRepository.saveRecentQuery(query: requestValue.query) { _ in
//                        
//                    }
//                }
                
                completion(result)
            }
    }
}


// MARK: - Search Movies Use Case Request Value

struct SearchMoviesUseCaseRequestValue {
    let query: MovieQuery
    let page: Int
}
