//
//  AirVisualEndpoints.swift
//  EvergreenProject
//
//  Created by Darul Firmansyah on 18/11/24.
//
import Foundation

enum AirVisualEndpoints: EndpointProvider {

    case getNearesCity(Double, Double)
    case getCountries
    case getStates(String)
    case getCities(String, String)

    var path: String {
        switch self {
        case .getNearesCity(_, _):
            return "/v2/nearest_city"
        case .getCountries:
            return "/v2/countries"
        case .getStates(_):
            return "/v2/states"
        case .getCities(_, _):
            return "/v2/cities"
        }
    }

    var method: RequestMethod {
        switch self {
        default:
            return .get
        }
    }

    var queryItems: [URLQueryItem]? {
        var keyedParams: [URLQueryItem] = [URLQueryItem(name: "key", value: "32d4e153-b084-47be-9cc7-92cd3839f764")]
        switch self {
        case .getNearesCity(let lat, let lon):
            keyedParams += [
                URLQueryItem(name: "lat", value: lat.description),
                URLQueryItem(name: "lon", value: lon.description)
            ]
        case .getStates(let country):
            keyedParams += [
                URLQueryItem(name: "country", value: country)
            ]
        case .getCities(let state, let country):
            keyedParams += [
                URLQueryItem(name: "state", value: state),
                URLQueryItem(name: "country", value: country)
            ]
        default:
            break
        }
        
        return keyedParams
    }

    var body: [String: Any]? {
        switch self {
        default:
            return nil
        }
    }

    var mockFile: String? {
        switch self {
        case .getNearesCity(_, _):
            return "_getNearestCityMockResponse"
        case .getCountries:
            return "_getCountriesMockResponse"
        case .getStates(_):
            return "_getStatesMockResponse"
        case .getCities(_, _):
            return "_getCitiesMockResponse"
        }
    }
}
