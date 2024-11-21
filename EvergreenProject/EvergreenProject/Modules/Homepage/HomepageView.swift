//
//  HomepageView.swift
//  EvergreenProject
//
//  Created by Darul Firmansyah on 14/11/24.
//
import SwiftUI

struct HomePageView: View {
    @State private var path = NavigationPath()
    @EnvironmentObject var appWatcher: AppWatcher
    @ObservedObject var viewModel = HomepageViewModel(locationManager: LocationManager(), apiClient: MockApiClient(sendError: false))
    
    var body: some View {
        NavigationStack {
            List  {
                Section {
                    if let currentLocationStatusViewAttributes = viewModel.currentLocationStatusViewAttributes {
                        Text("\(currentLocationStatusViewAttributes.cityName) - \(currentLocationStatusViewAttributes.airStatus)")
                    }
                } header: {
                    VStack(alignment: .leading) {
                        Text("Current Location")
                            .font(.title3)
                        
                        if viewModel.isAllowedToRequestLocation == false {
                            Button {
                                viewModel.goToSettings()
                            } label: {
                                Text("Location Permission not allowed. Tap here!")
                                    .font(.footnote)
                            }
                        }
                        
                    }
                }
                .textCase(nil)
                
                Section {
                    Text("Custom Location")
                } header: {
                    VStack(alignment: .leading) {
                        Text("Custom Location")
                            .font(.title3)
                        Text("Add up to \(AppConfig.maxCitiesCount) Cities")
                            .font(.footnote)
                    }
                }
                .textCase(nil)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("EverGreen ~ AirQ")
                }
                
                if appWatcher.isEligibleToAddMoreCities() {
                    ToolbarItem(placement: .topBarLeading) {
                        NavigationStack(path: $path) {
                            Button {
                                path.append("NewView")
                            } label: {
                                Image(systemName: "plus.square.fill")
                            }
                            .navigationDestination(for: String.self) { view in
                                if view == "NewView" {
                                    CitySubmissionView()
                                }
                            }
                        }
                    }
                }
            }
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbarBackground(.white, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Home")
        }
        .onAppear {
            Task { @MainActor in
                await viewModel.requestLocation()
            }
        }
    }
}
