//
//  APIError.swift
//  EvergreenProject
//
//  Created by Darul Firmansyah on 18/11/24.
//

import Foundation

struct APIError: Error, Codable {
    let status: String
    let data: ErrorData
    
    init(status: String, data: ErrorData) {
        self.status = status
        self.data = data
    }
    
    init() {
        self.init(status: "ERROR-0", data: ErrorData(message: "Unknown API error"))
    }
    
    init(message: String) {
        self.init(status: "ERROR-0", data: ErrorData(message: message))
    }
}

struct ErrorData: Codable {
    let message: String
}
