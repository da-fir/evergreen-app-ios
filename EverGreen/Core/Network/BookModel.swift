//
//  BookModel.swift
//  SandboxApp
//
//  Created by Darul Firmansyah on 28/06/24.
//

import Foundation

struct BookModel: Codable, Hashable, Identifiable, Comparable {
    static func < (lhs: BookModel, rhs: BookModel) -> Bool {
        lhs.isLocal
    }
    
    let isLocal: Bool
    let id: Int
    let title, author, description: String
    let cover: String
    let publicationDate: String
    private(set) var displayDate: String = ""
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case author = "author"
        case description = "description"
        case publicationDate = "publicationDate"
        case cover = "cover"
        case isLocal = "isLocal"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.isLocal = try container.decodeIfPresent(Bool.self, forKey: .isLocal) ?? false
        self.id = try container.decode(Int.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.author = try container.decode(String.self, forKey: .author)
        self.description = try container.decode(String.self, forKey: .description)
        self.cover = try container.decode(String.self, forKey: .cover)
        self.publicationDate = try container.decode(String.self, forKey: .publicationDate)
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        if let date = dateFormatter.date(from: publicationDate) {
            dateFormatter.dateStyle = .medium
            self.displayDate = dateFormatter.string(from: date)
        }
        else {
            self.displayDate = ""
        }
    }
    
    init(isLocal: Bool,
         id: Int,
         title: String,
         author: String,
         description: String,
         cover: String,
         publicationDate: String) {
        self.isLocal = isLocal
        self.id = id
        self.title = title
        self.author = author
        self.description = description
        self.cover = cover
        self.publicationDate = publicationDate
    }
}
