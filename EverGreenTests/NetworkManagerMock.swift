//
//  NetworkManagerMock.swift
//  EverGreenTests
//
//  Created by Destriana Orchidea on 11/08/24.
//

import Combine
import Foundation
@testable import EverGreen

final class NetworkManagerMock: NetworkManagerProtocol {
    var isSuccess: Bool = true
    var requestCalled: Int = 0
    var lastEndpoint: Endpoint?
    var stringResponse: String = ""

    
    func request<T>(_ endpoint: Endpoint, headers: [String : String]?, parameters: [String : String]?) -> AnyPublisher<T, APIError> where T : Decodable {
        requestCalled += 1
        lastEndpoint = endpoint
        
        guard isSuccess
        else {
            return Fail<T, APIError>(error: APIError.decodingFailed).eraseToAnyPublisher()
        }
        
        let response = try! JSONDecoder().decode(T.self, from: String(stringResponse).data(using: .utf8)!)
        
        return Just(response)
        .setFailureType(to: APIError.self)
        .eraseToAnyPublisher()
        
    }
    
    
}
