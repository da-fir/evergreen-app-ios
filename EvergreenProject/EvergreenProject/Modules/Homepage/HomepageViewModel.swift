//
//  Untitled.swift
//  EvergreenProject
//
//  Created by Darul Firmansyah on 14/11/24.
//

import CoreLocation
import Foundation
import UIKit

final class HomepageViewModel: ObservableObject {
    private let locationManager: LocationManagerProtocol
    private let apiClient: APIProtocol
    @Published var isAllowedToRequestLocation: Bool?
    @Published var currentLocationStatusViewAttributes: CityAirStatusViewAttributes?
    
    init(locationManager: LocationManagerProtocol, apiClient: APIProtocol) {
        self.locationManager = locationManager
        self.apiClient = apiClient
        refreshLocationPermissionStatus()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onLocationPermissionChanged), name: Notification.Name("LocationPermissionChanged"), object: nil)
    }
    
    @MainActor
    func requestLocation() async {
        do {
            locationManager.requestAuthorization()
            await getCurrentCityAirStatus(try await locationManager.currentLocation)
        }
        catch {
            refreshLocationPermissionStatus()
        }
    }
    
    func refreshLocationPermissionStatus() {
        isAllowedToRequestLocation = locationManager.isAllowedToRequestLocation()
    }
    
    func goToSettings() {
        UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
    }
    
    @objc
    private func onLocationPermissionChanged() {
        locationManager.requestAuthorization()
        refreshLocationPermissionStatus()
    }
    
    @MainActor
    private func getCurrentCityAirStatus(_ userLocation: CLLocation) async {
        Task {
            do {
                let response = try await apiClient.asyncRequest(endpoint: AirVisualEndpoints.getNearesCity(
                    userLocation.coordinate.latitude,
                    userLocation.coordinate.longitude
                ), responseModel: AIRVisualResponse<NearestCityResponse>.self)
                currentLocationStatusViewAttributes = CityAirStatusViewAttributes(cityName: response.data.city, airStatus: response.data.current.pollution.aqius.description)
            }
        }
    }
}


struct CityAirStatusViewAttributes {
    let cityName: String
    let airStatus: String
}
