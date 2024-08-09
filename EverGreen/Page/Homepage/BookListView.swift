//
//  BookListView.swift
//  SandboxApp
//
//  Created by Darul Firmansyah on 28/06/24.
//
import SwiftUI

struct BookListView: View {
    @ObservedObject
    var viewModel: BookListViewModel
    
    var body: some View {
        switch viewModel.state {
        case .loading:
            Text("Loading ...")
                .foregroundColor(.black)
                .bold()
        case .empty:
            Text("Page is Empty ...")
                .foregroundColor(.black)
                .bold()
        case .error:
            Text("Page is Error, Something Might Wrong")
                .foregroundColor(.black)
                .bold()
        default:
            contentView
        }
    }
    
    private var contentView: some View {
        List {
            if viewModel.state == .cached {
                Text("Page is Cached, Due something wrong")
                    .foregroundColor(.gray)
            }
            
            ForEach(viewModel.books) { book in
                HStack {
                    //            AsyncImage(
                    //                url: URL(string: user.avatar_url ?? ""),
                    //                content: { image in
                    //                    image.resizable()
                    //                        .aspectRatio(contentMode: .fit)
                    //                        .frame(width: 100, height: 100)
                    //                },
                    //                placeholder: {
                    //                    ProgressView()
                    //                        .frame(width: 100, height: 100)
                    //                })
                    //            .fixedSize()
                    
                    VStack(alignment: .leading) {
                        Text(book.title)
                            .font(.headline)
                        
                        Text(book.description)
                            .font(.subheadline)
                    }
                    Spacer()
                    Button {
                        
                    } label: {
                        Image(systemName: viewModel.isBookLoved(book) ? "heart.fill" : "heart")
                            .foregroundColor(.red)
                            .onTapGesture {
                                viewModel.toggleLoved(book: book)
                            }
                    }
                }
            }
        }
    }
}
