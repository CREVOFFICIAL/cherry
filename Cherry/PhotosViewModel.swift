//
//  PhotosViewModel.swift
//  Cherry
//
//  Created by junyeong-cho on 2021/12/12.
//

import Photos
import SwiftUI

final class PhotosViewModel: ObservableObject {
    @Published var assets = [PHAsset]()
    
    func requestAuthorization() async -> Bool {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        return status == .authorized
    }
    
    @MainActor
    func load() async {
        Task {
            guard await requestAuthorization() else { return }
            let assets = await fetchPhotos()
            await MainActor.run {
                withAnimation {
                    self.assets = assets
                }
            }
        }
    }
    
    private func fetchPhotos() async -> [PHAsset] {
        let result = PHAsset.fetchAssets(with: .image, options: nil)
        var assets = [PHAsset]()
        result.enumerateObjects { asset, _, _ in
            assets.append(asset)
        }
        return assets
    }
}
