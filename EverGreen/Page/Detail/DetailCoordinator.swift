//
//  DetailCoordinator.swift
//  EverGreen
//
//  Created by Darul Firmansyah on 10/08/24.
//

import Foundation
import SwiftUI
import UIKit

struct DetailInput {
    let book: BookModel
}

class DetailCoordinator: NSObject, Coordinator {
    weak var parentCoordinator: Coordinator?
    
    var children: [Coordinator] = []
    var navigationController: UINavigationController
    let input: DetailInput
    
    init(navigationController : UINavigationController, input: DetailInput) {
        self.input = input
        self.navigationController = navigationController
        super.init()
        
        self.navigationController.delegate = self
    }
    
    func start() {
        let hosting = UIHostingController(rootView: DetailView(viewModel: DetailViewModel(book: input.book, networkManager: NetworkManager())))
        hosting.title = input.book.title
        navigationController.pushViewController(hosting, animated: true)
    }
    
    deinit {
        print("Deinit checker", String(describing: self))
    }
}

extension DetailCoordinator: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if viewController is UIHostingController<BookListView> { // back navigation, remove coordinator
            parentCoordinator?.childDidFinish(self)
        }
    }
}
