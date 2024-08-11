//
//  DetailViewModel.swift
//  EverGreen
//
//  Created by Darul Firmansyah on 10/08/24.
//

import Foundation
import Combine
import SwiftUI

class DetailViewModel : ObservableObject {
    //MARK: - Properties
    private let networkService: NetworkManagerProtocol
    private var cancellables: Set<AnyCancellable> = []
    
    @Published var isLocal: Bool
    @Published var book: BookModel
    var fetchedCount: Int = 0 // just for additional info, flag of data fetched from server or cache
    
    
    init(book: BookModel, networkManager: NetworkManagerProtocol) {
        self.book = book
        self.isLocal = book.isLocal
        self.networkService = networkManager
        
        // initial load, only fetch if not local book
        guard !book.isLocal
        else {
            return
        }
        
        getBook()
    }
    
    private func getBook() {
        let response: AnyPublisher<BookModel, APIError> = networkService.request(.booksDetail("\(book.id)"), headers: nil, parameters: nil)
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
                case .failure(let _):
                    break
                }
            }
        receiveValue: { [weak self] response in
            guard let self
            else {
                return
            }
            fetchedCount += 1 // flag that Data showed is from API
            self.book = response
        }
        .store(in: &cancellables)
    }
    
}
