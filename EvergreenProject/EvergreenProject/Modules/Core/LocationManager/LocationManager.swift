//
//  LocationManager.swift
//  EvergreenProject
//
//  Created by Darul Firmansyah on 18/11/24.
//

import Foundation
import CoreLocation

protocol LocationManagerProtocol: CLLocationManagerDelegate {
    func requestAuthorization()
    func isAllowedToRequestLocation() -> Bool?
    var currentLocation: CLLocation { get async throws }
}

final class LocationManager: NSObject, LocationManagerProtocol  {
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func isAllowedToRequestLocation() -> Bool? {
        switch locationManager.authorizationStatus {
            
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        case .restricted, .denied:
            return false
        case .notDetermined:
            return nil
        default:
            return false
        }
    }
    
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    //MARK: Stored Continuation Object
    private var continuation: CheckedContinuation<CLLocation, Error>?
    
    //MARK: Async Request the Current Location
    var currentLocation: CLLocation {
        get async throws {
            return try await withCheckedThrowingContinuation { continuation in
                // 1. Set up the continuation object
                self.continuation = continuation
                // 2. Triggers the update of the current location
                locationManager.requestLocation()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {
            continuation?.resume(returning: lastLocation)
            continuation = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        continuation?.resume(throwing: error)
        continuation = nil
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        NotificationCenter.default.post(name: Notification.Name("LocationPermissionChanged"), object: nil)
    }
    
}
