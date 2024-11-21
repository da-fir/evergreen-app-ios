//
//  NearestCityResponse.swift
//  EvergreenProject
//
//  Created by Darul Firmansyah on 18/11/24.
//
import Foundation

// MARK: - Welcome
struct AIRVisualResponse<DataType: Codable>: Codable {
    let status: String
    let data: DataType
}

// MARK: Root Data
protocol BaseModel: Codable {
    // error message
    var message: String? { get }
}

// MARK: - DataClass
struct NearestCityResponse: BaseModel {
    var message: String?
    let city, state, country: String
    let location: Location
    let current: Current
}

// MARK: - Current
struct Current: Codable {
    let pollution: Pollution
    let weather: Weather
}

// MARK: - Pollution
struct Pollution: Codable {
    let ts: String
    let aqius: Int
    let mainus: String
    let aqicn: Int
    let maincn: String
}

// MARK: - Weather
struct Weather: Codable {
    let ts: String
    let tp, pr, hu: Int
    let ws: Double
    let wd: Int
    let ic: String
}

// MARK: - Location
struct Location: Codable {
    let type: String
    let coordinates: [Double]
}
