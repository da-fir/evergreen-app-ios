//
//  BookModel.swift
//  SandboxApp
//
//  Created by Darul Firmansyah on 28/06/24.
//

import Foundation

struct BookModel: Codable, Hashable, Identifiable {
    var uuid: UUID = UUID()
    let id: Int
    let title, author, description: String
    let cover: String
    let publicationDate: String
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case author = "author"
        case description = "description"
        case publicationDate = "publicationDate"
        case cover = "cover"
    }
}
