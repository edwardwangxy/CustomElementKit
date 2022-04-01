//
//  CustomAsyncImage.swift
//  FATThemeProjectManager
//
//  Created by Xiangyu Wang on 12/13/21.
//

import SwiftUI
import Combine


public class CustomAsyncImageData: ObservableObject {
    public enum CachePolicy {
        case reload
        case cached
    }
    
    let url: URL
    let hasURL: Bool
    let cacheSize: CGFloat
    private var loading: Bool = false
    private let cachePolicy: CachePolicy
    
    private var id: String?
    private var fm = FileManager.default
    let loadImageComplete: (UIImage) -> Void
    let delay: Double
    let clearCacheTime: Double
    
    public init(url: URL?, customCacheID: String? = nil, cachePolicy: CachePolicy = .cached, delay: Double = 0, cacheSize: CGFloat = 400, clearCacheTime: Double = 30, loadImageComplete: @escaping (UIImage) -> Void = {_ in}) {
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
        self.clearCacheTime = clearCacheTime
    }
    
    deinit {
//        CustomAsyncImageCache.shared.scheduleCacheClear(id: self.id ?? self.url.path, time: self.clearCacheTime)
    }
    
    enum ImageLoadError: Error {
        case loadFail
    }
    
    func fetch(complete: @escaping (Data?) -> Void) {
        self.loadImage { image in
            if let getImage = image {
                complete(getImage)
            }
        }
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
    
    func reloadImage(complete: @escaping (Data?) -> Void) {
        var request = URLRequest(url: self.url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        URLSession(configuration: .default).dataTask(with: request, completionHandler: { data, response, error in
            if let getData = data {
                if getData.count > Int(self.cacheSize * self.cacheSize * 4) {
                    self.generateThumb(image: getData, maxSize: self.cacheSize) { image in
                        complete(image?.pngData())
                    }
                } else {
                    complete(getData)
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
    
    func cacheImage(url: URL, complete: @escaping (Data?) -> Void) {
        URLSession(configuration: .ephemeral).dataTask(with: url) { data, response, error in
            if let getData = data {
                if getData.count > Int(self.cacheSize * self.cacheSize * 4) {
                    var lastPath = self.url.lastPathComponent
                    if let getCustomID = self.id {
                        lastPath = getCustomID
                    }
                    self.generateThumb(image: getData, maxSize: self.cacheSize) { image in
                        if let cachedURL = try? self.fm.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true) {
                            try? self.fm.removeItem(at: cachedURL.appendingPathComponent(lastPath))
                            try? image?.pngData()?.write(to: cachedURL.appendingPathComponent(lastPath))
                        }
                        complete(image?.pngData())
                    }
                } else {
                    complete(getData)
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
    
    func loadImage(complete: @escaping (Data?) -> Void) {
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
                self.cacheImage(url: cachedURL.appendingPathComponent(lastPath), complete: complete)
            } else {
                self.cacheImage(url: self.url, complete: complete)
            }
        }
        
    }
}

public struct CustomAsyncImage: View {

    let imageData: CustomAsyncImageData
    private let activeResizable: Bool
    @State var placeholder: AnyView?
    @State var image: Data? = nil
    @State var timer: DispatchSourceTimer? = nil
    let clearTime: Double
    
    public init(url: URL?, customCacheID: String? = nil, cachePolicy: CustomAsyncImageData.CachePolicy = .cached, resizable: Bool = true, delay: Double = 0, cacheSize: CGFloat = 512, clearTime: Double = 30, loadImageComplete: @escaping (UIImage) -> Void = {_ in}) {
        
        self.activeResizable = resizable
        self.imageData = CustomAsyncImageData(url: url, customCacheID: customCacheID, cachePolicy: cachePolicy, delay: delay, cacheSize: cacheSize, clearCacheTime: clearTime, loadImageComplete: loadImageComplete)
        self.clearTime = clearTime
    }
    
    public init<PH: View>(url: URL?, customCacheID: String? = nil, cachePolicy: CustomAsyncImageData.CachePolicy = .cached, resizable: Bool = true, cacheSize: CGFloat = 512, clearTime: Double = 30, @ViewBuilder placeholder: () -> PH, delay: Double = 0, loadImageComplete: @escaping (UIImage) -> Void = {_ in}) {
        self.activeResizable = resizable
        self._placeholder = State(initialValue: AnyView(placeholder()))
        self.imageData = CustomAsyncImageData(url: url, customCacheID: customCacheID, cachePolicy: cachePolicy, delay: delay, cacheSize: cacheSize, clearCacheTime: clearTime, loadImageComplete: loadImageComplete)
        self.clearTime = clearTime
    }
    
    public func placeholder<Content: View>(@ViewBuilder _ content: () -> Content) -> Self {
        self.placeholder = AnyView(content())
        return self
    }

    public var body: some View {
        ZStack {
            if let getImage = self.image {
                if self.activeResizable {
                    Image(uiImage: UIImage(data: getImage)!)
                        .resizable()
                } else {
                    Image(uiImage: UIImage(data: getImage)!)
                }
            } else if let placeholder = placeholder {
                placeholder
            }
        }
        .onAppear {
            if self.image == nil {
                self.imageData.fetch { data in
                    if let getData = data {
                        withAnimation {
                            self.image = getData
                        }
                    }
                }
            }
        }
        .onDisappear {
            self.image = nil
        }
    }
}

