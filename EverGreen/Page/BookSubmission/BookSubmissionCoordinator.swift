//
//  BookSubmissionCoordinator.swift
//  EverGreen
//
//  Created by Darul Firmansyah on 10/08/24.
//

import Foundation
import SwiftUI
import UIKit

struct BookSubmissionInput {
    let bookId: Int
    let delegate: BookSubmissionActionDelegate
}

class BookSubmissionCoordinator: NSObject, Coordinator {
    weak var parentCoordinator: Coordinator?
    
    var children: [Coordinator] = []
    var navigationController: UINavigationController
    let input: BookSubmissionInput
    
    init(navigationController : UINavigationController, input: BookSubmissionInput) {
        self.input = input
        self.navigationController = navigationController
        super.init()
        
        self.navigationController.delegate = self
    }
    
    func start() {
        let hosting = UIHostingController(rootView: BookSubmissionView(id: input.bookId, onBookSubmitted: { [weak self] result in
            self?.input.delegate.onBookSubmitted(result: result)
            self?.navigationController.popViewController(animated: true)
        }))
        hosting.title = "Book Submission"
        navigationController.pushViewController(hosting, animated: true)
    }
    
    deinit {
        print("Deinit checker", String(describing: self))
    }
}

extension BookSubmissionCoordinator: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if viewController is UIHostingController<BookListView> { // back navigation, remove coordinator
            parentCoordinator?.childDidFinish(self)
        }
    }
}
