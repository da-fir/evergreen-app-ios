//
//  DetailView.swift
//  EverGreen
//
//  Created by Darul Firmansyah on 10/08/24.
//

import Foundation
import SwiftUI

struct DetailView: View {
    @ObservedObject
    var viewModel: DetailViewModel
    
    var body: some View {
        List {
            Section {
                HStack {
                    HStack {
                        AsyncImage(
                            url: URL(string: viewModel.book.cover),
                            content: { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 50, height: 50)
                            },
                            placeholder: {
                                ActivityIndicator(isAnimating: true)
                            })
                        .frame(width: 50, height: 50)
                        .background(Circle().fill(Color.gray))
                        .fixedSize()
                        .clipShape(Circle())
                        VStack(spacing: 5) {
                            HStack {
                                Text("Author:")
                                    .font(.callout)
                                    .lineLimit(1)
                                Spacer()
                                Text(viewModel.book.displayDate)
                                    .font(.caption)
                                    .lineLimit(1)
                            }
                            HStack {
                                Text(viewModel.book.author)
                                    .font(.callout)
                                    .lineLimit(1)
                                Spacer()
                                Text(viewModel.isLocal ? "(Local)" : "(Remote)")
                                    .font(.caption)
                                    .lineLimit(1)
                            }
                        }
                    }
                }
            }
            
            Section {
                VStack(alignment: .leading) {
                    Text(viewModel.book.title + (viewModel.fetchedCount > 0 ? " (Refreshed)" : ""))
                        .font(.headline)
                        .lineLimit(2)
                    Text(viewModel.book.description)
                        .font(.subheadline)
                }
            }
        }
    }
}
