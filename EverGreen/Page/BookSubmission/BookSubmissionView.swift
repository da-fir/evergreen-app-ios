//
//  BookSubmissionView.swift
//  EverGreen
//
//  Created by Darul Firmansyah on 10/08/24.
//

import SwiftUI

protocol BookSubmissionActionDelegate: AnyObject {
    func onBookSubmitted(result: BookModel)
}

struct BookSubmissionView: View {
    @State var title: String = ""
    @State var author: String = ""
    @State var description: String = ""
    @State var cover: String = "https://picsum.photos/200/300"
    @State var publicationDate: Date = Date()
    
    // predefined
    let id: Int
    let onBookSubmitted: ((BookModel) -> Void)
    
    var body: some View {
        Form(content: {
            TextField("Title", text: $title)
            TextField("Author", text: $author)
            TextField("Description", text: $description)
            TextField("CoverURL", text: $cover)
            DatePicker("Publication Date",
                       selection: $publicationDate,
                       displayedComponents: [.date])
            Button("Save") {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                
                onBookSubmitted(BookModel(isLocal: true, id: id, title: title, author: author, description: description, cover: cover, publicationDate: formatter.string(from: publicationDate)))
            }
        })
    }
}
