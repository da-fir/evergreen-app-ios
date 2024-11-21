//
//  CitySubmissionViewModel.swift
//  EvergreenProject
//
//  Created by Darul Firmansyah on 20/11/24.
//
import Foundation
import UIKit

final class CitySubmissionViewModel: ObservableObject {
    private let apiClient: APIProtocol
    
    @Published var selectedCountry: Pickable = Pickable(label: "")
    @Published var selectedState: Pickable = Pickable(label: "")
    @Published var selectedCity: Pickable = Pickable(label: "")
    @Published var isFetching: Bool = false
    @Published var countries: [Pickable] = []
    @Published var states: [Pickable] = []
    @Published var cities: [Pickable] = []
    
    init(apiClient: APIProtocol) {
        self.apiClient = apiClient
        Task {
            await getCountries()
        }
    }
    
    @MainActor
    func getCountries() async {
        Task {
            do {
                isFetching = true
                let response = try await apiClient.asyncRequest(endpoint: AirVisualEndpoints.getCountries, responseModel: AIRVisualResponse<[CountryObj]>.self)
                countries = response.data.map({ Pickable(label: $0.country) })
                isFetching = false
            }
        }
    }
    
    @MainActor
    func getStates() async {
        Task {
            do {
                isFetching = true
                let response = try await apiClient.asyncRequest(endpoint: AirVisualEndpoints.getStates(selectedCountry.label), responseModel: AIRVisualResponse<[StateObj]>.self)
                states = response.data.map({ Pickable(label: $0.state) })
                isFetching = false
            }
        }
    }
    
    @MainActor
    func getCities() async {
        Task {
            do {
                isFetching = true
                let response = try await apiClient.asyncRequest(endpoint: AirVisualEndpoints.getCities(selectedState.label, selectedCountry.label), responseModel: AIRVisualResponse<[CityObj]>.self)
                cities = response.data.map({ Pickable(label: $0.city) })
                isFetching = false
            }
        }
    }
    
    func onCountryChanged() {
        states = []
        selectedState = Pickable(label: "")
        cities = []
        selectedCity = Pickable(label: "")
        Task { @MainActor in
            await getStates()
        }
    }
    
    func onStateChanged() {
        cities = []
        selectedCity = Pickable(label: "")
        Task { @MainActor in
            await getCities()
        }
    }
    
    func onCityChanged() {
        print(selectedCity)
    }
}
