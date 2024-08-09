//
//  HomepageCoordinator.swift
//  EverGreen
//
//  Created by Destriana Orchidea on 03/08/24.
//

import Foundation
import SwiftUI
import UIKit

class HomepageCoordinator : Coordinator {
    
    weak var parentCoordinator: Coordinator?
    
    var children: [Coordinator] = []
    
    var navigationController: UINavigationController
    
    private lazy var viewModel: BookListViewModel = BookListViewModel(networkManager: NetworkManager(),
                                                                      bookDataService: BookDataService())
    
    init(navigationController : UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let hosting = UIHostingController(rootView: BookListView(viewModel: viewModel))
        
        // set Add Button EntryPoint
        let addButton : UIBarButtonItem = UIBarButtonItem(title: "Add Book", style: UIBarButtonItem.Style.plain, target: self, action: #selector(openBookSubmissionTray))
        hosting.navigationItem.rightBarButtonItem = addButton
        
        hosting.title = "Book List"
        navigationController.viewControllers = [hosting]
        navigationController.navigationBar.isTranslucent = true
    }
    
    @objc
    func openBookSubmissionTray() {
        let homepageCoordinator = HomepageCoordinator(navigationController: navigationController)
        children.removeAll()
        
        homepageCoordinator.parentCoordinator = self
        children.append(homepageCoordinator)
        
        homepageCoordinator.start()
    }
}
