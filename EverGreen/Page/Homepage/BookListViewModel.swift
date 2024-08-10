//
//  BookListViewModel.swift
//  SandboxApp
//
//  Created by Darul Firmansyah on 28/06/24.
//

import Combine
import Foundation

protocol BookListNavigationDelegate: NSObject {
    func onOpenBookSubmission(input: BookSubmissionInput)
    func onOpenBookDetail(book: BookModel)
    func onBookWillDeleted(book: BookModel, completion: @escaping ((Bool) -> Void))
}

final class BookListViewModel : ObservableObject {
    //MARK: - Properties
    private weak var navigationDelegate: BookListNavigationDelegate?
    private let networkService: NetworkManagerProtocol
    private let bookDataService: BookDataServiceProtocol
    private var cancellables: Set<AnyCancellable> = []
    
    @Published var books: [BookModel] = []
    @Published var state: PageState = .loading
    @Published var lovedBooks: Set<Int>
    
    init(navigationDelegate: BookListNavigationDelegate, networkManager: NetworkManagerProtocol, bookDataService: BookDataServiceProtocol) {
        self.navigationDelegate = navigationDelegate
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
            
            let cachedBooks = self.bookDataService.getCachedBooks() ?? []
            // update and use cahce books
            self.bookDataService.setCachedBooks(books: Array(Set(response + cachedBooks)))
            self.books.append(contentsOf: self.bookDataService.getCachedBooks() ?? [])
            self.state = .success
        }
        .store(in: &cancellables)
    }
    
    func addNewBook() {
        navigationDelegate?.onOpenBookSubmission(input: BookSubmissionInput(bookId: getPossibleId(), delegate: self))
    }
    
    func onBookTapped(_ book: BookModel) {
        navigationDelegate?.onOpenBookDetail(book: book)
    }
    
    func onBookWillDeleted(_ book: BookModel) {
        navigationDelegate?.onBookWillDeleted(book: book, completion: { isConfirmed in
            guard isConfirmed
            else {
                return
            }
            
            // remove book from loved list
            self.lovedBooks.remove(book.id)
            self.bookDataService.setLovedBooks(ids: self.lovedBooks)
            
            self.books.removeAll(where: { book == $0 })
            // update cahce books
            self.bookDataService.setCachedBooks(books: self.books)
        })
        
    }
    
    private func getPossibleId() -> Int {
        let id: Int = books.map { $0.id }.max() ?? 0
        return id + 1
    }
}

extension BookListViewModel: BookSubmissionActionDelegate {
    func onBookSubmitted(result: BookModel) {
        self.books.append(result)
        self.bookDataService.setCachedBooks(books: self.books)
    }
}
