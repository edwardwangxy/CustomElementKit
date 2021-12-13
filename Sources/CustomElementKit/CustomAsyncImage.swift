//
//  CustomAsyncImage.swift
//  FATThemeProjectManager
//
//  Created by Xiangyu Wang on 12/13/21.
//

import SwiftUI
import Combine

public struct CustomAsyncImage: View {
    
    public enum CachePolicy {
        case reload
        case cached
    }
    
    let url: URL
    @State var image: UIImage? = nil
    @State private var loader: AnyCancellable? = nil
    private let activeResizable: Bool
    private let cachePolicy: CachePolicy
    @State
    private var placeholder: AnyView?
    
    public init(url: URL, cachePolicy: CachePolicy = .cached, resizable: Bool = true) {
        self.url = url
        self.cachePolicy = cachePolicy
        self.activeResizable = resizable
    }
    
    enum ImageLoadError: Error {
        case loadFail
    }
    
    func loadImage() -> AnyPublisher<UIImage, Error> {
        var request = URLRequest(url: self.url)
        switch self.cachePolicy {
        case .reload:
            request.cachePolicy = .reloadIgnoringLocalCacheData
        case .cached:
            request.cachePolicy = .returnCacheDataElseLoad
        }
        request.cachePolicy = .reloadIgnoringLocalCacheData
        return URLSession(configuration: .default).dataTaskPublisher(for: request)
            .tryMap { (data, response) in
                guard let image = UIImage(data: data) else {
                    throw ImageLoadError.loadFail
                }
                return image
            }
            .eraseToAnyPublisher()
    }
    
    public func placeholder<Content: View>(@ViewBuilder _ content: () -> Content) -> Self {
        self.placeholder = AnyView(content())
        return self
    }

    public var body: some View {
        ZStack {
            if let getImage = self.image {
                if self.activeResizable {
                    Image(uiImage: getImage)
                        .resizable()
                } else {
                    Image(uiImage: getImage)
                }
            } else if let placeholder = placeholder {
                placeholder
            }
        }
        .scaledToFill()
        .onAppear {
            self.loader = self.loadImage()
                .subscribe(on: DispatchQueue.global(qos: .utility), options: nil)
                .receive(on: DispatchQueue.main, options: nil)
                .sink(receiveCompletion: { _ in
                    
                }, receiveValue: { image in
                    self.image = image
                })
        }
        .onDisappear {
            self.loader?.cancel()
            self.image = nil
        }
    }
}


