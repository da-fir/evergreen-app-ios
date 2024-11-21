//
//  APIProtocol.swift
//  EvergreenProject
//
//  Created by Darul Firmansyah on 18/11/24.
//

import Combine
import Foundation

protocol APIProtocol {

    func asyncRequest<T: Decodable>(endpoint: EndpointProvider, responseModel: T.Type) async throws -> T
    func combineRequest<T: Decodable>(endpoint: EndpointProvider, responseModel: T.Type) -> AnyPublisher<T, APIError>
}
