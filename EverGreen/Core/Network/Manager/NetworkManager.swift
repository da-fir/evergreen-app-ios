//
//  NetworkManager.swift
//  SandboxApp
//
//  Created by Darul Firmansyah on 28/06/24.
//

import Combine
import Foundation

enum APIError: Error, Codable {
    case invalidURL
    case requestFailed(String)
    case decodingFailed
}

enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum Endpoint {
    case books
    case booksDetail(String)
    
    var path: String {
        switch self {
        case .books:
            return "/books"
        case let .booksDetail(id):
            return "/books/" + (id)
        }
    }
    
    var httpMethod: HttpMethod {
        switch self {
        default:
            return .get
        }
    }
}

protocol NetworkManagerProtocol {
    func request<T: Decodable>(_ endpoint: Endpoint, headers: [String: String]?, parameters: [String: String]?) -> AnyPublisher<T, APIError>
}

class NetworkManager: NetworkManagerProtocol {
    private let baseURL: String = "https://my-json-server.typicode.com/cutamar/mock"
    
    private func defaultHeaders() -> [String: String] {
        return [
            "Accept": "application/json"
        ]
    }
    
    func request<T: Decodable>(_ endpoint: Endpoint, headers: [String: String]? = nil, parameters: [String: String]? = nil) -> AnyPublisher<T, APIError> {
        
        guard let url = URL(string: baseURL + endpoint.path)
        else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endpoint.httpMethod.rawValue
        let allHeaders = defaultHeaders().merging(headers ?? [:], uniquingKeysWith: { (_, new) in new })
        for (key, value) in allHeaders {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { (data, response) -> (Data) in
                if let httpResponse = response as? HTTPURLResponse,
                   (200..<300).contains(httpResponse.statusCode) {
                    return data
                } else {
                    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                    throw APIError.requestFailed("Request failed with status code: \(statusCode)")
                }
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .tryMap { (responseWrapper) -> T in
                return responseWrapper
            }
            .mapError { error -> APIError in
                if error is DecodingError {
                    return APIError.decodingFailed
                } else if let apiError = error as? APIError {
                    return apiError
                } else {
                    return APIError.requestFailed("An unknown error occurred.")
                }
            }
            .eraseToAnyPublisher()
    }
}
