//
//  AppWatcher.swift
//  EvergreenProject
//
//  Created by Darul Firmansyah on 14/11/24.
//

import Foundation
class AppWatcher: ObservableObject {
    @Published var APIKey: String = "32d4e153-b084-47be-9cc7-92cd3839f764"
    @Published var APIMessage: String? = nil
    @Published var APICallCount: Int = 0
    @Published var APICallAvailable: Int = 0
    
    @Published var userCustomCityCount: Int = 0
    
    func isEligibleToAddMoreCities() -> Bool {
        userCustomCityCount < AppConfig.maxCitiesCount
    }
}

final class AppConfig {
    static let maxCitiesCount: Int = 3
}
