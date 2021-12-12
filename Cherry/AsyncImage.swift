//
//  AsyncImage.swift
//  Cherry
//
//  Created by junyeong-cho on 2021/12/12.
//

import Photos
import SwiftUI

struct AsyncImage<Placeholder: View>: View {
    @StateObject private var loader: ImageLoader
    
    private let placeholder: Placeholder
    private let image: (UIImage) -> Image
    
    init(
        phasset: PHAsset,
        @ViewBuilder placeholder: () -> Placeholder,
        @ViewBuilder image: @escaping (UIImage) -> Image = Image.init(uiImage:)
    ) {
        self.placeholder = placeholder()
        self.image = image
        _loader = StateObject(wrappedValue: ImageLoader(phasset: phasset))
    }
    
    var body: some View {
        content
            .task {
                await loader.load()
            }
    }
    
    private var content: some View {
        Group {
            if let uiImage = loader.image {
                image(uiImage)
            } else {
                placeholder
            }
        }
    }
}
