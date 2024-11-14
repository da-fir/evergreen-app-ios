//
//  HomepageView.swift
//  EvergreenProject
//
//  Created by Darul Firmansyah on 14/11/24.
//
import SwiftUI

struct HomePageView: View {
    @State var shouldPresentInfoSheet = false
    @EnvironmentObject var appWatcher: AppWatcher
    
    var body: some View {
        NavigationStack {
            List  {
                Section {
                    Text("Current Location")
                } header: {
                    VStack(alignment: .leading) {
                        Text("Current Location")
                            .font(.title3)
                        Button {
                            
                        } label: {
                            Text("Location Permission not allowed. Tap here!")
                                .font(.footnote)
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
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        shouldPresentInfoSheet = true
                    } label: {
                        Image(systemName: "info.square.fill")
                    }
                    .sheet(isPresented: $shouldPresentInfoSheet) {
                        AppInfoSheetView()
                    }
                    
                }
                
                ToolbarItem(placement: .principal) {
                    Text("EverGreen ~ AirQ")
                }
                
                if appWatcher.isEligibleToAddMoreCities() {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                        } label: {
                            Image(systemName: "plus.square.fill")
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
    }
}
