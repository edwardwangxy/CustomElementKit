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
    @ObservedObject var imageHolder: CustomAsyncImageHolder = CustomAsyncImageHolder()
    @State private var loader: AnyCancellable? = nil
    private let activeResizable: Bool
    private let cachePolicy: CachePolicy
    private var id: String?
    private var fm = FileManager.default
    @State private var timer: Timer?
    @State private var clearTimer: Timer?
    
    public init(url: URL, customCacheID: String? = nil, cachePolicy: CachePolicy = .cached, resizable: Bool = true) {
        self.url = url
        self.id = customCacheID
        if self.url.isFileURL {
            self.cachePolicy = .reload
        } else {
            self.cachePolicy = cachePolicy
        }
        self.activeResizable = resizable
    }
    
    enum ImageLoadError: Error {
        case loadFail
    }
    
    func loadImage() -> AnyPublisher<UIImage, Error> {
        
        switch self.cachePolicy {
        case .reload:
            var request = URLRequest(url: self.url)
            request.cachePolicy = .reloadIgnoringLocalCacheData
            return URLSession(configuration: .default).dataTaskPublisher(for: request)
                .tryMap { (data, response) in
                    guard let image = UIImage(data: data) else {
                        throw ImageLoadError.loadFail
                    }
                    return image
                }
                .eraseToAnyPublisher()
        case .cached:
            var lastPath = self.url.lastPathComponent
            if let getCustomID = self.id {
                lastPath = getCustomID
            }
            if let cachedURL = try? self.fm.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true), self.fm.fileExists(atPath: cachedURL.appendingPathComponent(lastPath).path) {
                var request = URLRequest(url: cachedURL.appendingPathComponent(lastPath))
                request.cachePolicy = .returnCacheDataElseLoad
                return URLSession(configuration: .default).dataTaskPublisher(for: request)
                    .tryMap { (data, response) in
                        guard let image = UIImage(data: data) else {
                            throw ImageLoadError.loadFail
                        }
                        return image
                    }
                    .eraseToAnyPublisher()
            } else {
                return Deferred {
                    Future<UIImage, Error>.init { promise in
                        var request = URLRequest(url: self.url)
                        request.cachePolicy = .returnCacheDataElseLoad
                        URLSession.shared.downloadTask(with: url) { localURL, _, error in
                            if let getErr = error {
                                promise(.failure(getErr))
                            } else if let getURL = localURL {
                                if let cachedURL = try? self.fm.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true) {
                                    try? self.fm.removeItem(at: cachedURL.appendingPathComponent(lastPath))
                                    try? self.fm.copyItem(at: getURL, to: cachedURL.appendingPathComponent(lastPath))
                                }
                                do {
                                    let data = try Data(contentsOf: getURL)
                                    if let getImage = UIImage(data: data) {
                                        promise(.success(getImage))
                                    } else {
                                        promise(.failure(ImageLoadError.loadFail))
                                    }
                                } catch {
                                    promise(.failure(error))
                                }
                            } else {
                                promise(.failure(ImageLoadError.loadFail))
                            }
                        }
                        .resume()
                    }
                }
                .eraseToAnyPublisher()
            }
        }
        
    }
    
    public func placeholder<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        self
            .modifier(CustomAsyncImagePlaceholderModifier(imageHolder: self.imageHolder, content))
    }

    public var body: some View {
        ZStack {
            if let getImage = self.imageHolder.image {
                if self.activeResizable {
                    Image(uiImage: getImage)
                        .resizable()
                } else {
                    Image(uiImage: getImage)
                }
            }
        }
        .onAppear {
            self.clearTimer?.invalidate()
            if self.imageHolder.image == nil {
                self.loader = self.loadImage()
                    .subscribe(on: DispatchQueue.global(qos: .utility), options: nil)
                    .receive(on: DispatchQueue.main, options: nil)
                    .sink(receiveCompletion: { _ in
                        
                    }, receiveValue: { image in
                        self.imageHolder.image = image
                    })
            }
        }
        .onDisappear {
            self.timer?.invalidate()
            self.loader?.cancel()
        }
    }
}

struct CustomAsyncImagePlaceholderModifier<PH: View>: ViewModifier {
    
    let content: PH
    @ObservedObject var imageHolder: CustomAsyncImageHolder
    
    init(imageHolder: CustomAsyncImageHolder, @ViewBuilder _ content: () -> PH) {
        self.content = content()
        self.imageHolder = imageHolder
    }
    
    func body(content: Content) -> some View {
        ZStack {
            if self.imageHolder.image == nil {
                self.content
            }
            content
        }
    }
}

class CustomAsyncImageHolder: ObservableObject {
    @Published var image: UIImage?
}
