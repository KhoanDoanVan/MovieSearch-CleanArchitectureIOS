//
//  MoviesScenceDIContainer.swift
//  Networking-CleanArchitectureIOS
//
//  Created by Đoàn Văn Khoan on 2/11/24.
//


import Foundation

final class MoviesScenceDIContainer {
    
    // MARK: - Dependencies
    struct Dependencies {
        let apiDataTransferService: DataTransferService
    }
    
    private let dependencies: Dependencies
    
    // MARK: - Init
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    
    // MARK: - Repositories
    func makeMoviesRepository() -> MoviesRepository {
        DefaultMoviesRepository(dataTransferService: dependencies.apiDataTransferService)
    }
    
    
    // MARK: - UseCases
    func makeSearchMoviesUseCase() -> SearchMoviesUseCase {
        DefaultSearchMoviesUseCase(moviesRepository: makeMoviesRepository())
    }
    
    // MARK: - Movies List
    func makeMoviesListViewModel() -> MoviesListViewModel {
        MoviesListViewModel(searchMoviesUseCase: makeSearchMoviesUseCase())
    }
}
