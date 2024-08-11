//
//  EverGreenTests.swift
//  EverGreenTests
//
//  Created by Darul Firmansyah on 03/08/24.
//

import Combine
import XCTest
@testable import EverGreen

private let booksMock: String = """
[
  {
    "id": 1,
    "title": "To Kill a Mockingbird",
    "author": "Harper Lee",
    "description": "A classic of modern American literature that has been celebrated for its finely crafted characters and brilliant storytelling.",
    "cover": "https://m.media-amazon.com/images/I/51IXWZzlgSL._SX330_BO1,204,203,200_.jpg",
    "publicationDate": "1960-07-11T00:00:00.000Z"
  },
  {
    "id": 2,
    "title": "The Great Gatsby",
    "author": "F. Scott Fitzgerald",
    "description": "The story of Jay Gatsby, a self-made millionaire, and his pursuit of the American Dream.",
    "cover": "https://m.media-amazon.com/images/I/41NssxNlPlS._SY291_BO1,204,203,200_QL40_FMwebp_.jpg",
    "publicationDate": "1925-04-10T00:00:00.000Z"
  }
]
"""

private let bookDetailMock: String = """
  {
    "id": 1,
    "title": "To Kill a Mockingbird",
    "author": "Harper Lee",
    "description": "A classic of modern American literature that has been celebrated for its finely crafted characters and brilliant storytelling.",
    "cover": "https://m.media-amazon.com/images/I/51IXWZzlgSL._SX330_BO1,204,203,200_.jpg",
    "publicationDate": "1960-07-11T00:00:00.000Z"
  }
"""

private let localBookMock: BookModel = BookModel(isLocal: true, id: 99, title: "Some Title", author: "Some Author", description: "Some Desc", cover: "Some Cover", publicationDate: "Some Date")
private let remoteBookMock: BookModel = BookModel(isLocal: false, id: 999, title: "Some Title", author: "Some Author", description: "Some Desc", cover: "Some Cover", publicationDate: "Some Date")

final class EverGreenTests: XCTestCase {
    private let successStates: [PageState] = [.empty, .loading, .success]
    private var subscriptions: Set<AnyCancellable> = []
    
    private let networkManagerMock: NetworkManagerMock = NetworkManagerMock()
    private let navigationMock: NavigationMock = NavigationMock()
    private let bookDataServiceMock: BookDataServiceMock = BookDataServiceMock()
    
    func test_viewDidLoad_success() throws {
        // given
        networkManagerMock.stringResponse = booksMock
        
        let expectation: XCTestExpectation = XCTestExpectation(description: "test_viewDidLoad_success")
        let viewModel: BookListViewModel = BookListViewModel(navigationDelegate: navigationMock,
                                                             networkManager: networkManagerMock,
                                                             bookDataService: bookDataServiceMock)
        _ = viewModel.$books.sink { books in
            if books.count == 2 {
                expectation.fulfill()
            }
        }
        .store(in: &subscriptions)
        
        wait(for: [expectation], timeout: 2)
    }
    
    func test_viewDidLoad_error_cached_empty() throws {
        // given
        bookDataServiceMock.cachedBooks = []
        networkManagerMock.isSuccess = false
        let viewModel: BookListViewModel = BookListViewModel(navigationDelegate: navigationMock,
                                                             networkManager: networkManagerMock,
                                                             bookDataService: bookDataServiceMock)
        
        let expectation: XCTestExpectation = XCTestExpectation(description: "test_viewDidLoad_error_cached_empty")
        _ = viewModel.$state.sink { state in
            if viewModel.books.count == 0, state == .error {
                expectation.fulfill()
            }
        }
        .store(in: &subscriptions)
        
        wait(for: [expectation], timeout: 2)
    }

    func test_viewDidLoad_error_cached_exists() throws {
        // given
        bookDataServiceMock.cachedBooks = [localBookMock]
        networkManagerMock.isSuccess = false
        let viewModel: BookListViewModel = BookListViewModel(navigationDelegate: navigationMock,
                                                             networkManager: networkManagerMock,
                                                             bookDataService: bookDataServiceMock)
        
        let expectation: XCTestExpectation = XCTestExpectation(description: "test_viewDidLoad_error_cached_exists")
        _ = viewModel.$state.sink { state in
            if !viewModel.books.isEmpty, state == .cached {
                expectation.fulfill()
            }
        }
        .store(in: &subscriptions)
        
        wait(for: [expectation], timeout: 2)
    }
    
    func test_onBookTapped() throws {
        networkManagerMock.stringResponse = booksMock
        
        let expectation: XCTestExpectation = XCTestExpectation(description: "test_onBookTapped")
        let viewModel: BookListViewModel = BookListViewModel(navigationDelegate: navigationMock,
                                                             networkManager: networkManagerMock,
                                                             bookDataService: bookDataServiceMock)
        
        viewModel.onBookTapped(localBookMock)
        
        if navigationMock.actions.last == "onOpenBookDetail\(localBookMock.id)" {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2)
    }
    
    func test_onAddBook() throws {
        networkManagerMock.stringResponse = booksMock
        
        let expectation: XCTestExpectation = XCTestExpectation(description: "test_onBookTapped")
        let viewModel: BookListViewModel = BookListViewModel(navigationDelegate: navigationMock,
                                                             networkManager: networkManagerMock,
                                                             bookDataService: bookDataServiceMock)
        
        viewModel.addNewBook()
        
        if navigationMock.actions.last == "onOpenBookSubmission\(viewModel.getPossibleId())" {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2)
    }
    
    func test_onBookWillDeleted() throws {
        networkManagerMock.stringResponse = booksMock
        
        let expectation: XCTestExpectation = XCTestExpectation(description: "test_onBookWillDeleted")
        let viewModel: BookListViewModel = BookListViewModel(navigationDelegate: navigationMock,
                                                             networkManager: networkManagerMock,
                                                             bookDataService: bookDataServiceMock)
        
        _ = viewModel.$books.sink { books in
            if books.count == 2 {
                let targetId: Int = books.first!.id
                viewModel.onBookWillDeleted(books.first!)
                if self.navigationMock.actions.last == "onBookWillDeleted\(targetId)" {
                    expectation.fulfill()
                }
            }
        }
        .store(in: &subscriptions)
        
        wait(for: [expectation], timeout: 2)
    }
    
    func test_onBookConfirmedDeleted() throws {
        networkManagerMock.stringResponse = booksMock
        
        let expectation: XCTestExpectation = XCTestExpectation(description: "test_onBookConfirmedDeleted")
        let viewModel: BookListViewModel = BookListViewModel(navigationDelegate: navigationMock,
                                                             networkManager: networkManagerMock,
                                                             bookDataService: bookDataServiceMock)
        
        _ = viewModel.$state.sink { state in
            if state == .success {
                let sizeBeforeDelete: Int = viewModel.books.count
                viewModel.onBookConfirmedDelete(viewModel.books.first!)
                if viewModel.books.count == sizeBeforeDelete - 1 {
                    expectation.fulfill()
                }
            }
        }
        .store(in: &subscriptions)
        
        wait(for: [expectation], timeout: 2)
    }
    
    func test_onBookSubmitted() throws {
        networkManagerMock.stringResponse = booksMock
        
        let expectation: XCTestExpectation = XCTestExpectation(description: "test_onBookSubmitted")
        let viewModel: BookListViewModel = BookListViewModel(navigationDelegate: navigationMock,
                                                             networkManager: networkManagerMock,
                                                             bookDataService: bookDataServiceMock)
        
        _ = viewModel.$state.sink { state in
            if state == .success {
                let sizeBeforeAdd: Int = viewModel.books.count
                viewModel.onBookSubmitted(result: localBookMock)
                if viewModel.books.count == sizeBeforeAdd + 1 {
                    expectation.fulfill()
                }
            }
        }
        .store(in: &subscriptions)
        
        wait(for: [expectation], timeout: 2)
    }
    
    func test_detail_onRemoteBookDetailOpened() throws {
        networkManagerMock.stringResponse = bookDetailMock
        
        
        let expectation: XCTestExpectation = XCTestExpectation(description: "test_detail_onRemoteBookDetailOpened")
        let viewModel: DetailViewModel = DetailViewModel(book: remoteBookMock,
                                                         networkManager: networkManagerMock)
        
        var successCount = 0
        _ = viewModel.$book.sink { book in
            if book.title == remoteBookMock.title {
                successCount += 1
            }
            
            // after data loaded from server
            if book.title == "To Kill a Mockingbird" {
                successCount += 1
            }
            
            if successCount == 1 {
                expectation.fulfill()
            }
        }
        .store(in: &subscriptions)
        
        wait(for: [expectation], timeout: 2)
    }
}
