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

// MARK: - Data Transfer Service

enum DataTransferError: Error {
    case noResponse
    case parsing(Error)
    case networkFailure(NetworkError)
    case resolvedNetworkFailure(Error)
}

protocol DataTransferDispatchQueue {
    func asyncExecute(work: @escaping () -> Void)
}

protocol DataTransferErrorLogger {
    func log(error: Error)
}

extension DispatchQueue: DataTransferDispatchQueue {
    func asyncExecute(work: @escaping () -> Void) {
        async(group: nil, execute: work)
    }
}

protocol DataTransferErrorResolver {
    func resolve(error: NetworkError) -> Error
}

// MARK: Main
protocol DataTransferService {
    typealias CompletionHandler<T> = (Result<T, DataTransferError>) -> Void
    
    @discardableResult
    func request<T: Decodable, E: ResponseRequestable> (
        with endpoint: E,
        on queue: DataTransferDispatchQueue,
        completion: @escaping CompletionHandler<T>
    ) -> NetworkCancellable? where E.Response == T
    
    @discardableResult
    func request<T: Decodable, E: ResponseRequestable> (
        with endpoint: E,
        completion: @escaping CompletionHandler<T>
    ) -> NetworkCancellable? where E.Response == T
    
    @discardableResult
    func request<E: ResponseRequestable> (
        with endpoint: E,
        on queue: DataTransferDispatchQueue,
        completion: @escaping CompletionHandler<Void>
    ) -> NetworkCancellable? where E.Response == Void
    
    @discardableResult
    func request<E: ResponseRequestable> (
        with endpoint: E,
        completion: @escaping CompletionHandler<Void>
    ) -> NetworkCancellable? where E.Response == Void
}

final class DefaultDataTransferService {
    
    private let networkService: NetworkService
    private let errorLogger: DataTransferErrorLogger
    private let errorResolver: DataTransferErrorResolver
    
    init(
        with networkService: NetworkService,
        errorLogger: DataTransferErrorLogger = DefaultDataTransferErrorLogger(),
        errorResolver: DataTransferErrorResolver = DefaultDataTransferErrorResolver()
    ) {
        self.networkService = networkService
        self.errorLogger = errorLogger
        self.errorResolver = errorResolver
    }
}

extension DefaultDataTransferService: DataTransferService {
    
    func request<T: Decodable, E: ResponseRequestable>(
        with endpoint: E,
        on queue: DataTransferDispatchQueue,
        completion: @escaping CompletionHandler<T>
    ) -> NetworkCancellable? where T == E.Response {
        
        networkService.request(endpoint: endpoint) { result in
            switch result {
            /// Success
            case .success(let data):
                print("SuccessFromHere")
                let result: Result<T, DataTransferError> = self.decode(
                    data: data,
                    decoder: endpoint.responseDecoder
                )
                queue.asyncExecute {
                    completion(result)
                }
            /// Failure
            case.failure(let error):
                self.errorLogger.log(error: error)
                let error = self.resolve(networkError: error)
                queue.asyncExecute {
                    completion(.failure(error))
                }
            }
        }
        
    }
    
    func request<T, E>(with endpoint: E, completion: @escaping CompletionHandler<T>) -> (NetworkCancellable)? where T : Decodable, T == E.Response, E : ResponseRequestable {
        request(
            with: endpoint,
            on: DispatchQueue.main,
            completion: completion
        )
    }
    
    func request<E>(with endpoint: E, on queue: DataTransferDispatchQueue, completion: @escaping CompletionHandler<Void>) -> (NetworkCancellable)? where E : ResponseRequestable, E.Response == () {
        networkService.request(endpoint: endpoint) { result in
            switch result {
            /// Success
            case .success:
                queue.asyncExecute {
                    completion(.success(()))
                }
            /// Failure
            case.failure(let error):
                self.errorLogger.log(error: error)
                let error = self.resolve(networkError: error)
                queue.asyncExecute {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func request<E>(with endpoint: E, completion: @escaping CompletionHandler<Void>) -> (NetworkCancellable)? where E : ResponseRequestable, E.Response == () {
        request(
            with: endpoint,
            on: DispatchQueue.main,
            completion: completion
        )
    }
    
    // MARK: Private
    private func decode<T: Decodable>(
        data: Data?,
        decoder: ResponseDecoder
    ) -> Result<T, DataTransferError> {
        do {
            guard let data = data else { return .failure(.noResponse) }
            let result: T = try decoder.decode(data)
            return .success(result)
        } catch {
            self.errorLogger.log(error: error)
            return .failure(.parsing(error))
        }
    }
    
    private func resolve(networkError error: NetworkError) -> DataTransferError {
        let resolvedError = self.errorResolver.resolve(error: error)
        return resolvedError is NetworkError ? .networkFailure(error) : .resolvedNetworkFailure(error)
    }
}

// MARK: - Logger
final class DefaultDataTransferErrorLogger: DataTransferErrorLogger {
    init() { }
    
    func log(error: Error) {
        printIfDebug("-------------")
        printIfDebug("\(error.localizedDescription)")
    }
}

// MARK: - Resolver
final class DefaultDataTransferErrorResolver: DataTransferErrorResolver {
    init() { }
    
    func resolve(error: NetworkError) -> Error {
        return error
    }
}


// MARK: - Response Decoders
class JSONResponseDecoder: ResponseDecoder {
    private let jsonDecoder = JSONDecoder()
    init() { }
    func decode<T: Decodable>(_ data: Data) throws -> T {
        return try jsonDecoder.decode(T.self, from: data)
    }
}


/// Using in APIEndpoints at Data layer
class RawDataResponseDecoder: ResponseDecoder {
    init() { }
    
    enum CodingKeys: String, CodingKey {
        case `default` = ""
    }
    func decode<T: Decodable>(_ data: Data) throws -> T {
        if T.self is Data.Type, let data = data as? T {
            return data
        } else {
            let context = DecodingError.Context(
                codingPath: [CodingKeys.default],
                debugDescription: "Expected Data type"
            )
            throw Swift.DecodingError.typeMismatch(T.self, context)
        }
    }
}
