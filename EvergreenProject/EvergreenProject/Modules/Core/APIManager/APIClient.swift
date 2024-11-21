//
//  APIClient.swift
//  EvergreenProject
//
//  Created by Darul Firmansyah on 18/11/24.
//

import Combine
import Foundation

final class APIClient: APIProtocol {
    // 1
    var session: URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        configuration.timeoutIntervalForRequest = 60 // seconds that a task will wait for data to arrive
        configuration.timeoutIntervalForResource = 300 // seconds for whole resource request to complete ,.
        return URLSession(configuration: configuration)
    }
    // 2
    func asyncRequest<T: Decodable>(endpoint: EndpointProvider, responseModel: T.Type) async throws -> T {
        do {
            let (data, response) = try await session.data(for: endpoint.asURLRequest())
            return try self.manageResponse(data: data, response: response)
        } catch let error as APIError { // 3
            throw error
        } catch {
            throw APIError(message: "Unknown API error")
        }
    }
    
    func asyncImage(fileURL: URL) async throws -> URL {
            do {
                let response = try await session.download(from: fileURL)
                return response.0
            } catch {
                throw APIError(message: "Unknown API error")
            }
        }
    
    // 4
    func combineRequest<T: Decodable>(endpoint: EndpointProvider, responseModel: T.Type) -> AnyPublisher<T, APIError> {
        do {
            return session
                .dataTaskPublisher(for: try endpoint.asURLRequest())
                .tryMap { output in
                    return try self.manageResponse(data: output.data, response: output.response)
                }
                .mapError { // 5
                    $0 as? APIError ?? APIError(message: "Unknown API error \($0.localizedDescription)")
                }
                .eraseToAnyPublisher()
        } catch let error as APIError { // 6
            return AnyPublisher<T, APIError>(Fail(error: error))
        } catch {
            return AnyPublisher<T, APIError>(Fail(error: APIError(
                message: "Unknown API error \(error.localizedDescription)"
            )))
        }
    }
    
    private func manageResponse<T: Decodable>(data: Data, response: URLResponse) throws -> T {
            guard let response = response as? HTTPURLResponse else {
                throw APIError(
                    message: "Invalid HTTP response"
                )
            }
            switch response.statusCode {
            case 200...299:
                do {
                    return try JSONDecoder().decode(T.self, from: data)
                } catch {
                    print("‼️", error)
                    throw APIError(
                        message: "Error decoding data"
                    )
                }
            default:
                guard let decodedError = try? JSONDecoder().decode(APIError.self, from: data) else {
                    throw APIError(
                        message: "Unknown backend error"
                    )
                }
                
                throw decodedError
            }
        }
}
