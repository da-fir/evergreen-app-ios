//
//  AppInfoSheetView.swift
//  EvergreenProject
//
//  Created by Darul Firmansyah on 14/11/24.
//
import SwiftUI

struct AppInfoSheetView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appWatcher: AppWatcher

    var body: some View {
        NavigationView {
            List {
                Section {
                    Text("API Call Count: \(appWatcher.APICallCount)")
                    Text("API Call Left: \(appWatcher.APICallAvailable)")
                } header: {
                    Text("www.iqair.com Public API Status")
                } footer: {
                    Text("Please retry later if no slot left")
                }
                .textCase(nil)
            }
            .navigationTitle("Info")
        }
    }
}
