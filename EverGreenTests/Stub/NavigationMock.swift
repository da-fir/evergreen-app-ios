//
//  NavigationMock.swift
//  EverGreenTests
//
//  Created by Destriana Orchidea on 11/08/24.
//

import Foundation
@testable import EverGreen

final class NavigationMock: NSObject, BookListNavigationDelegate {
    
    var actions: [String] = []
    func onOpenBookSubmission(input: BookSubmissionInput) {
        actions.append("onOpenBookSubmission" + input.bookId.description)
    }
    
    func onOpenBookDetail(book: BookModel) {
        actions.append("onOpenBookDetail" + book.id.description)
    }
    
    func onBookWillDeleted(book: BookModel, completion: @escaping ((Bool) -> Void)) {
        actions.append("onBookWillDeleted" + book.id.description)
        completion(true)
    }
    
    
}
