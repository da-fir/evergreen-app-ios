//
//  MainApp.swift
//  EvergreenProject
//
//  Created by Darul Firmansyah on 14/11/24.
//

import SwiftUI

@main
struct RoutingApp: App {
    @StateObject var appWatcher = AppWatcher()
    
    var body: some Scene {
        WindowGroup {
            HomePageView()
        }
        .environmentObject(appWatcher)
    }
}
