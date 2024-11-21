//
//  APIManagerContracts.swift
//  EvergreenProject
//
//  Created by Darul Firmansyah on 18/11/24.
//

import Foundation

//TODO: NetworkLayer by Lukas Seltsam
//https://medium.com/@c64midi/modern-generic-network-layer-with-swift-concurrency-async-await-and-combine-part-4-unit-612eabec2b17

enum RequestMethod: String {
    case delete = "DELETE"
    case get = "GET"
    case patch = "PATCH"
    case post = "POST"
    case put = "PUT"
}

protocol EndpointProvider {
    var scheme: String { get }
    var baseURL: String { get }
    var path: String { get }
    var method: RequestMethod { get }
    var token: String { get }
    var queryItems: [URLQueryItem]? { get }
    var body: [String: Any]? { get }
    var mockFile: String? { get }
}

extension EndpointProvider {

    var scheme: String { // 1
        return "https"
    }

    var baseURL: String { // 2
        return "api.airvisual.com"
    }

    var token: String { //3
        return ""
    }

    func asURLRequest() throws -> URLRequest { // 4

        var urlComponents = URLComponents() // 5
        urlComponents.scheme = scheme
        urlComponents.host =  baseURL
        urlComponents.path = path
        if let queryItems = queryItems {
            urlComponents.queryItems = queryItems
        }
        guard let url = urlComponents.url else {
            throw APIError(message: "URL error")
        }

        var urlRequest = URLRequest(url: url) // 6
        urlRequest.httpMethod = method.rawValue
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("true", forHTTPHeaderField: "X-Use-Cache")

        if !token.isEmpty {
            urlRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let body = body {
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            } catch {
                throw APIError(message: "Error encoding http body")
            }
        }
        return urlRequest
    }
}
