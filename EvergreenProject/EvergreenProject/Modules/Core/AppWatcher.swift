//
//  AppWatcher.swift
//  EvergreenProject
//
//  Created by Darul Firmansyah on 14/11/24.
//

import Foundation
class AppWatcher: ObservableObject {
    @Published var APIMessage: String? = nil
    @Published var APICallCount: Int = 0
    
    @Published var userCustomCityCount: Int = 0
    
    func isEligibleToAddMoreCities() -> Bool {
        userCustomCityCount < AppConfig.maxCitiesCount
    }
}

final class AppConfig {
    static let maxCitiesCount: Int = 3
}
