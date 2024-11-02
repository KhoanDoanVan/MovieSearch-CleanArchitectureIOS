//
//  NetworkService.swift
//  Networking-CleanArchitectureIOS
//
//  Created by Đoàn Văn Khoan on 31/10/24.
//

import Foundation

// MARK: - Implementation
protocol NetworkService {
    typealias CompletionHandler = (Result<Data?, NetworkError>) -> Void
    
    func request(
        endpoint: Requestable,
        completion: @escaping CompletionHandler
    ) -> NetworkCancellable?
}

final class DefaultNetworkService {
    
    // MARK: Parameter
    private let config: NetworkConfigurable
    private let sessionManager: NetworkSessionManager
    private let logger: NetworkErrorLogger
    
    // MARK: Init
    init(
        config: NetworkConfigurable,
        sessionManager: NetworkSessionManager = DefaultNetworkSessionManager(),
        logger: NetworkErrorLogger = DefaultNetworkErrorLogger()
    ) {
        self.config = config
        self.sessionManager = sessionManager
        self.logger = logger
    }
    
    // MARK: Request
    private func request(
        request: URLRequest,
        completion: @escaping CompletionHandler
    ) -> NetworkCancellable {
        
        let sessionDataTask = sessionManager.request(request) { data, response, requestError in
            /// Failed
            if let requestError {
                var error: NetworkError
                if let response = response as? HTTPURLResponse {
                    error = .error(statusCode: response.statusCode, data: data)
                } else {
                    error = self.resolve(error: requestError)
                }
                
                self.logger.log(error: error)
                completion(.failure(error))
            }
            /// Success
            else {
                self.logger.log(responseData: data, response: response)
                completion(.success(data))
            }
        }
        logger.log(request: request)
        return sessionDataTask
    }
    
    /// Resolve the error to know type of the error
    private func resolve(error: Error) -> NetworkError {
        let code = URLError.Code(rawValue: (error as NSError).code)
        
        switch code {
        case .notConnectedToInternet:
            return .notConnected
        case .cancelled:
            return .cancelled
        default:
            return .generic(error)
        }
    }
}

extension DefaultNetworkService: NetworkService {
    func request(endpoint: Requestable, completion: @escaping CompletionHandler) ->  NetworkCancellable? {
        do {
            let urlRequest = try endpoint.urlRequest(with: config)
            return request(request: urlRequest, completion: completion)
        } catch {
            completion(.failure(.urlGeneration))
            return nil
        }
    }
}

// MARK: - Network Session Manager
protocol NetworkSessionManager {
    typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void
    
    func request(_ request: URLRequest, completion: @escaping CompletionHandler) -> NetworkCancellable
}

final class DefaultNetworkSessionManager: NetworkSessionManager {
    func request(
        _ request: URLRequest,
        completion: @escaping CompletionHandler
    ) -> NetworkCancellable {
        let task = URLSession.shared.dataTask(with: request, completionHandler: completion)
        task.resume()
        return task
    }
}

// MARK: - Logger Error
protocol NetworkErrorLogger {
    func log(request: URLRequest)
    func log(responseData data: Data?, response: URLResponse?)
    func log(error: Error)
}

final class DefaultNetworkErrorLogger: NetworkErrorLogger {
    
    /// Log with Request parameter
    func log(request: URLRequest) {
        print("---------")
        print("request: \(request.url!)")
        print("headers: \(request.allHTTPHeaderFields!)")
        print("method: \(request.httpMethod!)")
        
        if let httpBody = request.httpBody,
           let result = ((try? JSONSerialization.jsonObject(with: httpBody, options: []) as? [String:AnyObject]) as [String:AnyObject]??)
        {
            printIfDebug("body: \(String(describing: result))")
        }
        else if let httpBody = request.httpBody,
            let resultString = String(data: httpBody, encoding: .utf8)
        {
            printIfDebug("body: \(String(describing: resultString))")
        }
    }
    
    /// Log with ResponseData and Response parameters
    func log(responseData data: Data?, response: URLResponse?) {
        guard let data else { return }
        if let dataDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any]
        {
            printIfDebug("responseData: \(String(describing: dataDict))")
        }
    }
    
    /// Log with Error parameter
    func log(error: Error) {
        printIfDebug("\(error)")
    }
}

// MARK: - Network Cancellable
protocol NetworkCancellable {
    func cancel()
}

// MARK: - Network Error
enum NetworkError: Error {
    case error(statusCode: Int, data: Data?)
    case notConnected
    case cancelled
    case generic(Error)
    case urlGeneration
}

extension URLSessionTask: NetworkCancellable { }

// MARK: - Print If Debug
func printIfDebug(_ string: String) {
    #if DEBUG
    print(string)
    #endif
}
