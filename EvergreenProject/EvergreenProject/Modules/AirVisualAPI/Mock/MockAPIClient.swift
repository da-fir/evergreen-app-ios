//
//  MockAPIClient.swift
//  EvergreenProject
//
//  Created by Darul Firmansyah on 18/11/24.
//

import Combine
import Foundation

protocol Mockable: AnyObject {
    var bundle: Bundle { get }
    func loadJSON<T: Decodable>(filename: String, type: T.Type) -> T
}

extension Mockable {
    var bundle: Bundle {
        return Bundle(for: type(of: self))
    }

    func loadJSON<T: Decodable>(filename: String, type: T.Type) -> T {
        guard let path = bundle.url(forResource: filename, withExtension: "json") else {
            fatalError("Failed to load JSON")
        }

        do {
            let data = try Data(contentsOf: path)
            let decodedObject = try JSONDecoder().decode(type, from: data)

            return decodedObject
        } catch {
            fatalError("Failed to decode loaded JSON")
        }
    }
}

class MockApiClient: Mockable, APIProtocol {

    var sendError: Bool
    var mockFile: String?

    init(sendError: Bool = false, mockFile: String? = nil) {
        self.sendError = sendError
        self.mockFile = mockFile
    }

    func asyncRequest<T>(endpoint: EndpointProvider, responseModel: T.Type) async throws -> T where T: Decodable {
        if sendError {
            throw APIError(message: "AsyncFailed")
        } else {
            let filename = mockFile ?? endpoint.mockFile!
            return loadJSON(filename: filename, type: responseModel.self)
        }
    }

    func combineRequest<T>(endpoint: EndpointProvider, responseModel: T.Type) -> AnyPublisher<T, APIError> where T: Decodable {
        if sendError {
            return Fail(error: APIError(message: "CombineFailed"))
                .eraseToAnyPublisher()
        } else {
            let filename = mockFile ?? endpoint.mockFile!
            return Just(loadJSON(filename: filename, type: responseModel.self) as T)
                .setFailureType(to: APIError.self)
                .eraseToAnyPublisher()
        }
    }
}
