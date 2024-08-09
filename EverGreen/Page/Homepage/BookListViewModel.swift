//
//  BookListViewModel.swift
//  SandboxApp
//
//  Created by Darul Firmansyah on 28/06/24.
//

import Combine
import Foundation

class BookListViewModel : ObservableObject {
    //MARK: - Properties
    private let networkService: NetworkManagerProtocol
    private let bookDataService: BookDataServiceProtocol
    private var cancellables: Set<AnyCancellable> = []
    
    @Published var books: [BookModel] = []
    @Published var state: PageState = .loading
    @Published var lovedBooks: Set<Int>
    
    init(networkManager: NetworkManagerProtocol, bookDataService: BookDataServiceProtocol) {
        self.bookDataService = bookDataService
        self.networkService = networkManager
        
        // get loved books
        lovedBooks = bookDataService.getLovedBooks()
        
        // initial load
        getBooks(parameters: nil)
    }
    
    func isBookLoved(_ book: BookModel) -> Bool {
        lovedBooks.contains(book.id)
    }
    
    func toggleLoved(book: BookModel) {
        if isBookLoved(book) {
            lovedBooks.remove(book.id)
        } else {
            lovedBooks.insert(book.id)
        }
        
        bookDataService.setLovedBooks(ids: lovedBooks)
    }
    
    //MARK: - API CALL
    func getBooks(parameters: [String: String]?) {
        if books.isEmpty {
            state = .loading
        }
        
        let response: AnyPublisher<[BookModel], APIError> = networkService.request(.books, headers: nil, parameters: parameters)
        response
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                guard let self
                else {
                    return
                }
                
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    if let cachedBooks: [BookModel] = self.bookDataService.getCachedBooks() {
                        self.books.append(contentsOf: cachedBooks)
                        self.state = .cached
                    }
                    else {
                        self.state = .error
                    }
                }
            }
        receiveValue: { [weak self] response in
            guard let self
            else {
                return
            }
            self.books.append(contentsOf: response)
            self.state = .success
            self.bookDataService.setCachedBooks(books: self.books)
        }
        .store(in: &cancellables)
    }
    
    func addNewBook() {
        let possibleId: Int = getPossibleId()
        let book: BookModel = BookModel(id: getPossibleId(), title: UUID().uuidString, author: "author", description: "desc", cover: "cover", publicationDate: "NOW!")
    }
    
    private func getPossibleId() -> Int {
        let id: Int = books.map { $0.id }.max() ?? 0
        return id + 1
    }
}
