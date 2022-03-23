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
    let hasURL: Bool
    @State var image: UIImage? = nil
    @State private var loader: AnyCancellable? = nil
    private let activeResizable: Bool
    private let cachePolicy: CachePolicy
    @State var placeholder: AnyView?
    private var id: String?
    private var fm = FileManager.default
    private var delay: Double
    @State private var timer: DispatchSourceTimer?
    @State private var clearTimer: Timer?
    let loadImageComplete: (UIImage) -> Void
    public init(url: URL?, customCacheID: String? = nil, cachePolicy: CachePolicy = .cached, resizable: Bool = true, delay: Double = 0.5, loadImageComplete: @escaping (UIImage) -> Void = {_ in}) {
        if let getURL = url {
            self.url = getURL
            self.hasURL = true
        } else {
            self.url = URL(string: "https://parseapi.handyapp.io/parse/files/handy_app/771d070dd3650f52ed429f25fd260b21_ef51303fda014c28c0d707c02f94e58c_3BFA08DD-786D-4787-B252-79650196F69B.png")!
            self.hasURL = false
        }
        self.id = customCacheID
        if self.url.isFileURL {
            self.cachePolicy = .reload
        } else {
            self.cachePolicy = cachePolicy
        }
        self.activeResizable = resizable
        self.delay = delay
        self.loadImageComplete = loadImageComplete
    }
    
    public init<PH: View>(url: URL?, customCacheID: String? = nil, cachePolicy: CachePolicy = .cached, resizable: Bool = true, @ViewBuilder placeholder: () -> PH, delay: Double = 0.5, loadImageComplete: @escaping (UIImage) -> Void = {_ in}) {
        if let getURL = url {
            self.url = getURL
            self.hasURL = true
        } else {
            self.url = URL(string: "https://parseapi.handyapp.io/parse/files/handy_app/771d070dd3650f52ed429f25fd260b21_ef51303fda014c28c0d707c02f94e58c_3BFA08DD-786D-4787-B252-79650196F69B.png")!
            self.hasURL = false
        }
        
        self.id = customCacheID
        if self.url.isFileURL {
            self.cachePolicy = .reload
        } else {
            self.cachePolicy = cachePolicy
        }
        self.activeResizable = resizable
        self._placeholder = State(initialValue: AnyView(placeholder()))
        self.delay = delay
        self.loadImageComplete = loadImageComplete
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
        .onAppear {
            if !self.hasURL {
                return
            }
            if self.url.path.contains("F13D476A-6B0E-4EE4-8631-52E4060B5BE0") {
                print(self.url)
            }
            self.clearTimer?.invalidate()
            if self.image == nil {
                self.timer = DispatchSource.makeTimerSource()
                self.timer?.schedule(deadline: .now() + self.delay)
                self.timer?.setEventHandler(handler: {
                    self.loader = self.loadImage()
                        .subscribe(on: DispatchQueue.global(qos: .utility), options: nil)
                        .receive(on: DispatchQueue.main, options: nil)
                        .sink(receiveCompletion: { _ in
                            
                        }, receiveValue: { image in
                            self.loadImageComplete(image)
                            DispatchQueue.main.async {
                                withAnimation {
                                    self.image = image
                                }
                                
                            }
                        })
                })
                self.timer?.resume()
            }
        }
        .onDisappear {
            self.timer?.cancel()
            self.loader?.cancel()
        }
    }
}

