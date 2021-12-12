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
    
    init(phasset: PHAsset) {
        self.phasset = phasset
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
    
    private func loadImage() async -> UIImage? {
        return await withCheckedContinuation { continuation in
            let manager = PHImageManager.default()
            let options = PHImageRequestOptions()
            options.isSynchronous = true
            options.deliveryMode = .highQualityFormat
            manager.requestImage(
                for: phasset,
                   targetSize: CGSize(width: 200, height: 200),
                   contentMode: .aspectFit,
                   options: options) { image, _ in
                       continuation.resume(with: .success(image))
                   }
        }
    }
}
