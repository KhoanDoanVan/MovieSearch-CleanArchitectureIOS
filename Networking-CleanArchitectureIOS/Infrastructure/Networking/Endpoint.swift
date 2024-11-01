//
//  Endpoint.swift
//  Networking-CleanArchitectureIOS
//
//  Created by Đoàn Văn Khoan on 31/10/24.
//

import Foundation

// MARK: - Method
enum HTTPMethodType: String {
    case get    = "GET"
    case post   = "POST"
    case put    = "PUT"
    case patch  = "PATCH"
    case delete = "DELETE"
    case head   = "HEAD"
}

// MARK: - Endpoint
class Endpoint<R>: ResponseRequestable {

    
    /// The typealias is the associate type from ResponseRequestable
    typealias Response = R
    
    /// The properties extends from ResponseRequestable
    let path: String
    let isFullPath: Bool
    let method: HTTPMethodType
    let headerParameters: [String : String]
    let queryParametersEncodable: Encodable?
    let queryParameters: [String : Any]
    let bodyParametersEncodable: Encodable?
    let bodyParameters: [String : Any]
    let bodyEncoder: BodyEncoder
    let reponseDecoder: ResponseDecoder
        
    init(
        path: String,
        method: HTTPMethodType,
        headerParameters: [String : String] = [:],
        queryParameters: [String : Any] = [:],
        bodyParameters: [String : Any] = [:],
        bodyEncoder: BodyEncoder = JSONBodyEncoder(),
        responseDecoder: ResponseDecoder = JSONResponseDecoder(),
        queryParametersEncodable: Encodable? = nil,
        bodyParametersEncodable: Encodable? = nil,
        isFullPath: Bool = false
    ) {
        self.path = path
        self.isFullPath = isFullPath
        self.method = method
        self.headerParameters = headerParameters
        self.queryParametersEncodable = queryParametersEncodable
        self.queryParameters = queryParameters
        self.bodyParametersEncodable = bodyParametersEncodable
        self.bodyParameters = bodyParameters
        self.bodyEncoder = bodyEncoder
        self.reponseDecoder = responseDecoder
    }
}


// MARK: - Requestable
protocol Requestable {
    var path: String { get }
    var isFullPath: Bool { get }
    var method: HTTPMethodType { get }
    // Header
    var headerParameters: [String: String] { get }
    // Query
    var queryParametersEncodable: Encodable? { get }
    var queryParameters: [String:Any] { get }
    // Body
    var bodyParametersEncodable: Encodable? { get }
    var bodyParameters: [String:Any] { get }
    var bodyEncoder: BodyEncoder { get }
    
    // Get URLRequest
    func urlRequest(with networkConfig: NetworkConfigurable) throws -> URLRequest
}

extension Requestable {
    
    // MARK: URL
    func url(with config: NetworkConfigurable) throws -> URL {
        
        /// Base URL
        let baseURL = config.baseURL.absoluteString.last != "/" ? (config.baseURL.absoluteString + "/") : (config.baseURL.absoluteString)
        
        /// EndPoint
        let endpoint = isFullPath ? path : baseURL.appending(path)
        
        /// URL Components
        guard var urlComponents = URLComponents(string: endpoint) else {
            throw RequestGenerationError.components
        }
        
        /// List Query Items key=value
        var urlQueryItems = [URLQueryItem]()
        
        let queryParameters = try queryParametersEncodable?.toDictionary() ?? self.queryParameters
        
        /// the main query parameters derived from your encodable or predefined dictionary
        queryParameters.forEach {
            urlQueryItems.append(URLQueryItem(name: $0.key, value: "\($0.value)"))
        }
        
        config.queryParameters.forEach {
            urlQueryItems.append(URLQueryItem(name: $0.key, value: $0.value))
        }
        
        /// Add QueryItems to url components
        urlComponents.queryItems = !urlQueryItems.isEmpty ? urlQueryItems : nil
        
        /// URL from urlCompoents like this https ://api.example.com/search?query=swift&limit=10
        guard let url = urlComponents.url else {
            throw RequestGenerationError.components
        }
        
        return url
    }
    
    // MARK: URL Request
    func urlRequest(with config: NetworkConfigurable) throws -> URLRequest {
        
        /// URL
        let url = try self.url(with: config)
        
        /// Create URL Request
        var urlRequest = URLRequest(url: url)
        
        /// Header
        var allHeaders: [String:String] = config.headers
        headerParameters.forEach {
            allHeaders.updateValue($1, forKey: $0)
        }
        
        let bodyParameters = try bodyParametersEncodable?.toDictionary() ?? self.bodyParameters
        
        /// If has body content
        if !bodyParameters.isEmpty {
            urlRequest.httpBody = bodyEncoder.encode(bodyParameters)
        }
        
        urlRequest.httpMethod = method.rawValue
        urlRequest.allHTTPHeaderFields = allHeaders
        
        return urlRequest
    }
}

// MARK: - ResponseRequestable
protocol ResponseRequestable: Requestable {
    /// sociatedtype is a keyword used within protocols to define a placeholder type
    associatedtype Response
    
}

// MARK: - BodyEncoder
protocol BodyEncoder {
    func encode(_ parameters: [String:Any]) -> Data?
}

// MARK: - JSONBodyEncoder
struct JSONBodyEncoder: BodyEncoder {
    func encode(_ parameters: [String : Any]) -> Data? {
        return try? JSONSerialization.data(withJSONObject: parameters)
    }
}


// MARK: - Request Generation Error
enum RequestGenerationError: Error {
    case components
}
