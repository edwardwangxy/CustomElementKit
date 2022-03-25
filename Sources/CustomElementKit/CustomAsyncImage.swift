//
//  CustomAsyncImage.swift
//  FATThemeProjectManager
//
//  Created by Xiangyu Wang on 12/13/21.
//

import SwiftUI
import Combine

class CustomAsyncImageCache {
    static let shared = CustomAsyncImageCache()
    
    let imageCache = NSCache<NSString, UIImage>()
    
    private var scheduleCacheRemove: [String: DispatchSourceTimer] = [:]
    
    func cacheImage(id: String, image: UIImage) {
        self.imageCache.setObject(image, forKey: NSString(string: id))
    }
    
    func loadImage(id: String) -> UIImage? {
        self.scheduleCacheRemove[id]?.cancel()
        return self.imageCache.object(forKey: NSString(string: id))
    }
    
    func scheduleCacheClear(id: String) {
        self.scheduleCacheRemove[id]?.cancel()
        let timer = DispatchSource.makeTimerSource()
        timer.schedule(deadline: .now() + 60 * 5)
        timer.setEventHandler {
            self.imageCache.removeObject(forKey: NSString(string: id))
            self.scheduleCacheRemove[id]?.cancel()
        }
        timer.resume()
        self.scheduleCacheRemove[id] = timer
    }
    
}

public class CustomAsyncImageData: ObservableObject {
    public enum CachePolicy {
        case reload
        case cached
    }
    @Published var image: UIImage? = nil
    let url: URL
    let hasURL: Bool
    let cacheSize: CGFloat
    private var loading: Bool = false
    private let cachePolicy: CachePolicy
    
    private var id: String?
    private var fm = FileManager.default
    let loadImageComplete: (UIImage) -> Void
    let delay: Double
    
    public init(url: URL?, customCacheID: String? = nil, cachePolicy: CachePolicy = .cached, delay: Double = 0, cacheSize: CGFloat = 400, loadImageComplete: @escaping (UIImage) -> Void = {_ in}) {
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
        self.delay = delay
        self.loadImageComplete = loadImageComplete
        self.cacheSize = cacheSize
        if let getImage = CustomAsyncImageCache.shared.loadImage(id: self.id ?? self.url.path) {
            DispatchQueue.main.async {
                self.image = getImage
            }
        } else {
            self.loadImage { image in
                if let getImage = image {
                    CustomAsyncImageCache.shared.cacheImage(id: self.id ?? self.url.path, image: getImage)
                    DispatchQueue.main.async {
                        self.image = getImage
                    }
                }
            }
        }
    }
    
    deinit {
        CustomAsyncImageCache.shared.scheduleCacheClear(id: self.id ?? self.url.path)
    }
    
    enum ImageLoadError: Error {
        case loadFail
    }
    
    func generateThumb(image: Data, maxSize: CGFloat = 100, callback: @escaping (UIImage?) -> Void) {
        let options = [
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: maxSize] as CFDictionary
        image.withUnsafeBytes { ptr in
            guard let bytes = ptr.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                callback(nil)
                return
            }
            if let cfData = CFDataCreate(kCFAllocatorDefault, bytes, image.count){
                let source = CGImageSourceCreateWithData(cfData, nil)!
                let imageReference = CGImageSourceCreateThumbnailAtIndex(source, 0, options)!
                let thumbnail = UIImage(cgImage: imageReference) // You get your thumbail here
                callback(thumbnail)
            } else {
                callback(nil)
            }
        }
    }
    
    func reloadImage(complete: @escaping (UIImage?) -> Void) {
        var request = URLRequest(url: self.url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        URLSession(configuration: .default).dataTask(with: request, completionHandler: { data, response, error in
            if let getData = data {
                if getData.count > Int(self.cacheSize * self.cacheSize * 4) {
                    self.generateThumb(image: getData, maxSize: self.cacheSize) { image in
                        complete(image)
                    }
                } else {
                    complete(UIImage(data: getData))
                }
                
            } else {
                complete(nil)
            }
            DispatchQueue.main.async {
                self.loading = false
            }
        })
        .resume()
    }
    
    func loadImage(complete: @escaping (UIImage?) -> Void) {
        if self.loading {
            return
        }
        self.loading = true
        switch self.cachePolicy {
        case .reload:
            self.reloadImage(complete: complete)
        case .cached:
            var lastPath = self.url.lastPathComponent
            if let getCustomID = self.id {
                lastPath = getCustomID
            }
            if let cachedURL = try? self.fm.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true), self.fm.fileExists(atPath: cachedURL.appendingPathComponent(lastPath).path) {
                var request = URLRequest(url: cachedURL.appendingPathComponent(lastPath))
                request.cachePolicy = .returnCacheDataElseLoad
                URLSession(configuration: .default).dataTask(with: request) { data, response, error in
                    if let getData = data {
                        if getData.count > Int(self.cacheSize * self.cacheSize * 4) {
                            self.generateThumb(image: getData, maxSize: self.cacheSize) { image in
                                if let cachedURL = try? self.fm.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true) {
                                    try? self.fm.removeItem(at: cachedURL.appendingPathComponent(lastPath))
                                    try? image?.pngData()?.write(to: cachedURL.appendingPathComponent(lastPath))
                                }
                                complete(image)
                            }
                        } else {
                            complete(UIImage(data: getData))
                        }
                    } else {
                        complete(nil)
                    }
                    DispatchQueue.main.async {
                        self.loading = false
                    }
                }
                .resume()
            } else {
                var request = URLRequest(url: self.url)
                request.cachePolicy = .returnCacheDataElseLoad
                URLSession.shared.downloadTask(with: request) { localURL, _, error in
                    if let getURL = localURL, let data = try? Data(contentsOf: getURL) {
                        if data.count > Int(self.cacheSize * self.cacheSize * 4) {
                            self.generateThumb(image: data, maxSize: self.cacheSize) { image in
                                if let cachedURL = try? self.fm.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true) {
                                    try? self.fm.removeItem(at: cachedURL.appendingPathComponent(lastPath))
                                    try? image?.pngData()?.write(to: cachedURL.appendingPathComponent(lastPath))
                                }
                                complete(image)
                            }
                        } else {
                            complete(UIImage(data: data))
                        }
                    } else {
                        complete(nil)
                    }
                    DispatchQueue.main.async {
                        self.loading = false
                    }
                }
                .resume()
            }
        }
        
    }
}

public struct CustomAsyncImage: View {

    @ObservedObject var imageData: CustomAsyncImageData
    private let activeResizable: Bool
    @State var placeholder: AnyView?
    
    public init(url: URL?, customCacheID: String? = nil, cachePolicy: CustomAsyncImageData.CachePolicy = .cached, resizable: Bool = true, delay: Double = 0, cacheSize: CGFloat = 400, loadImageComplete: @escaping (UIImage) -> Void = {_ in}) {
        
        self.activeResizable = resizable
        self.imageData = CustomAsyncImageData(url: url, customCacheID: customCacheID, cachePolicy: cachePolicy, delay: delay, cacheSize: cacheSize, loadImageComplete: loadImageComplete)
    }
    
    public init<PH: View>(url: URL?, customCacheID: String? = nil, cachePolicy: CustomAsyncImageData.CachePolicy = .cached, resizable: Bool = true, cacheSize: CGFloat = 400, @ViewBuilder placeholder: () -> PH, delay: Double = 0, loadImageComplete: @escaping (UIImage) -> Void = {_ in}) {
        self.activeResizable = resizable
        self._placeholder = State(initialValue: AnyView(placeholder()))
        self.imageData = CustomAsyncImageData(url: url, customCacheID: customCacheID, cachePolicy: cachePolicy, delay: delay, cacheSize: cacheSize, loadImageComplete: loadImageComplete)
    }
    
    public func placeholder<Content: View>(@ViewBuilder _ content: () -> Content) -> Self {
        self.placeholder = AnyView(content())
        return self
    }

    public var body: some View {
        ZStack {
            if let getImage = self.imageData.image {
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
    }
}

