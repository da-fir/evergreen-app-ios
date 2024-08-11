//
//  BookListCoordinator.swift
//  EverGreen
//
//  Created by Darul Firmansyah on 03/08/24.
//

import Foundation
import SwiftUI
import UIKit

class BookListCoordinator: NSObject, Coordinator {
    
    weak var parentCoordinator: Coordinator?
    
    var children: [Coordinator] = []
    
    var navigationController: UINavigationController
    
    init(navigationController : UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewModel: BookListViewModel = BookListViewModel(navigationDelegate: self,
                                                             networkManager: NetworkManager(),
                                                             bookDataService: BookDataService())
        let hosting = UIHostingController(rootView: BookListView(viewModel: viewModel))
        hosting.title = "Book List"
        navigationController.viewControllers = [hosting]
        navigationController.navigationBar.isTranslucent = true
    }
    
    @objc
    func openBookSubmissionTray() {
        let BookListCoordinator = BookListCoordinator(navigationController: navigationController)
        children.removeAll()
        
        BookListCoordinator.parentCoordinator = self
        children.append(BookListCoordinator)
        
        BookListCoordinator.start()
    }
}

extension BookListCoordinator: BookListNavigationDelegate {
    func onOpenBookDetail(book: BookModel) {
        let detailCoordintor = DetailCoordinator(navigationController: navigationController, input: DetailInput(book: book))
        children.removeAll()
        
        detailCoordintor.parentCoordinator = self
        children.append(detailCoordintor)
        
        detailCoordintor.start()
    }
    
    func onBookWillDeleted(book: BookModel, completion: @escaping ((Bool) -> Void)) {
        let deleteAlert = UIAlertController(title: "Delete?", message: "\(book.title) local book will be lost.", preferredStyle: UIAlertController.Style.alert)
        
        deleteAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            completion(true)
        }))
        
        deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            completion(false)
        }))
        navigationController.topViewController?.present(deleteAlert, animated: true)
    }
    
    func onOpenBookSubmission(input: BookSubmissionInput) {
        let bookSubmissionCoordinator = BookSubmissionCoordinator(navigationController: navigationController, input: input)
        children.removeAll()
        
        bookSubmissionCoordinator.parentCoordinator = self
        children.append(bookSubmissionCoordinator)
        
        bookSubmissionCoordinator.start()
    }
}
