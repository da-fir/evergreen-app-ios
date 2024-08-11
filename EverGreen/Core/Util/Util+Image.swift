//
//  Util.swift
//  EverGreen
//
//  https://gist.github.com/k3zi/856c86a08c5869639e90a6afd094e01e
//

import Combine
import SwiftUI
/// A view that asynchronously loads and displays an image.
///
/// Loading an image from a URL uses the shared URLSession.
struct CustomAsyncImage<Content> : View, Equatable where Content : View {
    static func == (lhs: CustomAsyncImage, rhs: CustomAsyncImage) -> Bool {
        let lhsImage = lhs.image
        let rhsImage = rhs.image
        if (lhsImage == nil && rhsImage != nil) || (lhsImage != nil && rhsImage == nil) {
            return false
        } else {
            return true
        }
    }
    
    final class Loader: ObservableObject {
        @Published var data: Data? = nil
        private var cancellables = Set<AnyCancellable>()
        init(_ url: URL?) {
            guard let url = url else { return }
            URLSession.shared.dataTaskPublisher(for: url)
                .map(\.data)
                .map { $0 as Data? }
                .replaceError(with: nil)
                .receive(on: RunLoop.main)
                .assign(to: \.data, on: self)
                .store(in: &cancellables)
        }
    }

    @ObservedObject private var imageLoader: Loader
    private let conditionalContent: ((Image?) -> Content)?
    private let scale: CGFloat

    /// Loads and displays an image from the given URL.
    ///
    /// When no image is available, standard placeholder content is shown.
    ///
    /// In the example below, the image from the specified URL is loaded and shown.
    ///
    ///     AsyncImage(url: URL(string: "https://example.com/screenshot.png"))
    ///
    /// - Parameters:
    ///   - url: The URL for the image to be shown.
    ///   - scale: The scale to use for the image.
    init(url: URL?, scale: CGFloat = 1) where Content == Image {
        self.imageLoader = Loader(url)
        self.scale = scale
        self.conditionalContent = nil
    }

    /// Loads and displays an image from the given URL.
    ///
    /// When an image is loaded, the `image` content is shown; when no image is
    /// available, the `placeholder` is shown.
    ///
    /// In the example below, the image from the specified URL is loaded and
    /// shown as a tiled resizable image. While it is loading, a green
    /// placeholder is shown.
    ///
    ///     AsyncImage(url: URL(string: "https://example.com/tile.png")) { image in
    ///         image.resizable(resizingMode: .tile)
    ///     } placeholder: {
    ///         Color.green
    ///     }
    ///
    /// - Parameters:
    ///   - url: The URL for the image to be shown.
    ///   - scale: The scale to use for the image.
    ///   - content: The view to show when the image is loaded.
    ///   - placeholder: The view to show while the image is still loading.
    init<I, P>(url: URL?, scale: CGFloat = 1, @ViewBuilder content: @escaping (Image) -> I, @ViewBuilder placeholder: @escaping () -> P) where Content == _ConditionalContent<I, P>, I : View, P : View {
        self.imageLoader = Loader(url)
        self.scale = scale
        self.conditionalContent = { image in
            if let image = image {
                return ViewBuilder.buildEither(first: content(image))
            } else {
                return ViewBuilder.buildEither(second: placeholder())
            }
        }
    }

    private var image: Image? {
        imageLoader.data
            .flatMap {
                UIImage(data: $0, scale: scale)
            }
            .flatMap(Image.init)
    }

    var body: some View {
        if let conditionalContent = conditionalContent {
            conditionalContent(image)
        } else if let image = image {
            image
        }
    }

}

// Indicator for image
struct ActivityIndicator: UIViewRepresentable {
    
    typealias UIView = UIActivityIndicatorView
    var isAnimating: Bool
    var configuration = { (indicator: UIView) in }

    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIView { UIView() }
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<Self>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
        configuration(uiView)
    }
}
