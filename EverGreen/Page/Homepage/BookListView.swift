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
            
            Button {
                viewModel.addNewBook()
            } label: {
                Text("Add New Book ...")
                    .foregroundColor(.black)
                    .bold()
            }
            
            ForEach(viewModel.books) { book in
                Button {
                    viewModel.onBookTapped(book)
                } label: {
                    cellView(book: book)
                }
            }
            
            Button {
                viewModel.addNewBook()
            } label: {
                Text("Add New Book ...")
                    .foregroundColor(.black)
                    .bold()
            }
        }
    }
    
    @ViewBuilder
    func cellView(book: BookModel) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(book.title + (book.isLocal ? " (Local Book)" : ""))
                    .font(.headline)
                
                
                if book.isLocal {
                    Button {
                        viewModel.onBookWillDeleted(book)
                    } label: {
                        Image(systemName: "trash.circle.fill")
                            .foregroundColor(.blue)
                    }
                    .frame(width: 40)
                    .frame(height: 40)
                }
                
                Spacer()
            }
            
            HStack {
                ZStack(alignment: .bottomTrailing) {
                    if #available(iOS 15.0, *) {
                        AsyncImage(url: URL(string: book.cover)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            ActivityIndicator(isAnimating: true)
                        }
                        .padding(24)
                    } else {
                        // iOS 13 support
                        CustomAsyncImage(
                            url: URL(string: book.cover),
                            content: { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            },
                            placeholder: {
                                ActivityIndicator(isAnimating: true)
                            })
                        .padding(24)
                    }
                    Button {
                        viewModel.toggleLoved(book: book)
                    } label: {
                        Image(systemName: viewModel.isBookLoved(book) ? "heart.fill" : "heart")
                            .foregroundColor(.red)
                    }
                    .frame(width: 40)
                    .frame(height: 40)
                }
                .frame(width: 100)
                .frame(height: 100)
                
                
                VStack(alignment: .leading) {
                    Text("Author: " + book.author)
                        .font(.footnote)
                    Text("Release: " + book.displayDate)
                        .font(.footnote)
                    Text(book.description)
                        .font(.subheadline)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                .padding()
            }
            .padding()
        }
    }
}
