//
//  BookDataServiceMock.swift
//  EverGreenTests
//
//  Created by Destriana Orchidea on 11/08/24.
//

import Foundation
@testable import EverGreen

final class BookDataServiceMock: BookDataServiceProtocol {
    var action: [String] = []
    var lovedBooks: Set<Int> = []
    var cachedBooks: [BookModel] = []
    
    func getLovedBooks() -> Set<Int> {
        action.append("getLovedBooks")
        return lovedBooks
    }
    
    func setLovedBooks(ids: Set<Int>) {
        action.append("setLovedBooks")
        lovedBooks = ids
    }
    
    func getCachedBooks() -> [EverGreen.BookModel]? {
        action.append("getCachedBooks")
        return cachedBooks
    }
    
    func setCachedBooks(books: [EverGreen.BookModel]) {
        action.append("setCachedBooks")
        cachedBooks = books
    }
    
    
}
