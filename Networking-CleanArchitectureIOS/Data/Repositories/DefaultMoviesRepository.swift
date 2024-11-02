//
//  DefaultMoviesRepository.swift
//  Networking-CleanArchitectureIOS
//
//  Created by Đoàn Văn Khoan on 2/11/24.
//

import Foundation

final class DefaultMoviesRepository {
    
    private let dataTransferService: DataTransferService
    private let backgroundQueue: DataTransferDispatchQueue
    
    init(
        dataTransferService: DataTransferService,
        backgroundQueue: DataTransferDispatchQueue = DispatchQueue.global(qos: .userInitiated)
    ) {
        self.dataTransferService = dataTransferService
        self.backgroundQueue = backgroundQueue
    }
    
}

extension DefaultMoviesRepository: MoviesRepository {
    func fetchMoviesList(
        query: MovieQuery,
        page: Int,
        completion: @escaping (Result<MoviesPage, Error>) -> Void
    ) -> (Cancellable)? {
        
        let requestDTO = MoviesRequestDTO(query: query.query, page: page)
        let task = RepositoryTask()
        
        let endpoint = APIEndpoints.getMovies(with: requestDTO)
        
        task.networkTask = self.dataTransferService.request(
            with: endpoint,
            on: backgroundQueue
        ) { result in
            switch result {
            case .success(let responseDTO):
                completion(.success(responseDTO.toDomain()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        return task
    }
}
