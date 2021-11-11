//
//  SwiftUIView.swift
//  
//
//  Created by Xiangyu Wang on 11/11/21.
//

import SwiftUI

public struct CustomAsyncImage: View {
    
    let imageURL: URL?
    @State var fetchedImage: UIImage? = nil
    
    public init(url: URL?) {
        self.imageURL = url
    }
    
    public var body: some View {
        Image(uiImage: self.fetchedImage ?? UIImage())
            .onAppear {
                if self.fetchedImage == nil {
                    DispatchQueue.global(qos: .utility).async {
                        if let getURL = self.imageURL, let data = try? Data(contentsOf: getURL), let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                self.fetchedImage = image
                            }
                        }
                    }
                }
            }
    }
}

