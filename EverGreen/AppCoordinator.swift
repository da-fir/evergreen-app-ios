//
//  AppCoordinator.swift
//  EverGreen
//
//  Created by Destriana Orchidea on 03/08/24.
//

import Foundation
import UIKit

// AppCoordinator is a ParentCoordinator
final class AppCoordinator: Coordinator {
    
    var parentCoordinator: Coordinator?
    
    var children: [Coordinator] = []
    
    var navigationController: UINavigationController
    
    init(navigationController : UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        // open homepage on start
        openHomepage()
    }
    
    func openHomepage() {
        let homepageCoordinator = HomepageCoordinator(navigationController: navigationController)
        children.removeAll()
        
        homepageCoordinator.parentCoordinator = self
        children.append(homepageCoordinator)
        
        homepageCoordinator.start()
    }
}
