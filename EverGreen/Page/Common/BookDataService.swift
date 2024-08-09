//
//  BookDataService.swift
//  EverGreen
//
//  Created by Darul Firmansyah on 10/08/24.
//

import Foundation

protocol BookDataServiceProtocol {
    func getLovedBooks() -> Set<Int>
    func setLovedBooks(ids: Set<Int>)
    func getCachedBooks() -> [BookModel]?
    func setCachedBooks(books: [BookModel])
}

final class BookDataService: BookDataServiceProtocol {
    private let kLovedBook: String = "kLovedBook"
    private let kAllBooks: String = "kAllBooks"
    
    private let service: LocalDataServiceProtocol = LocalDataService()
    
    func getLovedBooks() -> Set<Int> {
        service.loadArrayInt(key: kLovedBook)
    }
    
    func setLovedBooks(ids: Set<Int>) {
        service.saveArrayInt(key: kLovedBook, items: ids)
    }
    
    func setCachedBooks(books: [BookModel]) {
        service.storedModel(key: kAllBooks, object: books + [])
    }
    
    func getCachedBooks() -> [BookModel]? {
        return service.getModel(key: kAllBooks, modelType: [BookModel].self)
    }
}
