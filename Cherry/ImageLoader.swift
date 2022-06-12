//
//  ImageLoader.swift
//  Cherry
//
//  Created by junyeong-cho on 2021/12/12.
//

import Photos
import UIKit

final class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    
    private(set) var isLoading = false
    
    private let phasset: PHAsset
    private let size: CGSize
    
    init(phasset: PHAsset, size: CGSize = C.imageSize) {
        self.phasset = phasset
        self.size = size
    }
    
    @MainActor
    func load() async {
        guard !isLoading else { return }
        isLoading = true
        Task {
            let image = await loadImage()
            await MainActor.run {
                self.image = image
                self.isLoading = false
            }
        }
    }
    
    func loadImage() async -> UIImage? {
        return await withCheckedContinuation { [weak self] continuation in
            guard let self = self else { return }
            let manager = PHImageManager.default()
            let options = PHImageRequestOptions()
            options.isSynchronous = true
            options.deliveryMode = .highQualityFormat
            manager.requestImage(
                for: self.phasset,
                   targetSize: self.size,
                   contentMode: .aspectFit,
                   options: options) { image, _ in
                       continuation.resume(with: .success(image))
                   }
        }
    }
}

fileprivate struct C {
    static let imageSize: CGSize = .init(width: 100, height: 100)
}
