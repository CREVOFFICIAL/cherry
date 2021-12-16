//
//  PhotoLibrary.swift
//  Cherry
//
//  Created by junyeong-cho on 2021/12/12.
//

import Photos
import SwiftUI

final class PhotoLibrary: NSObject, ObservableObject, PHPhotoLibraryChangeObserver {
    
    @Published var assets = Dictionary<String, [PHAsset]>()
    
    var keys: [String] {
        return Array(assets.keys)
    }
    
    func binding(for key: String) -> Binding<[PHAsset]> {
        return Binding(get: {
            return self.assets[key] ?? []
        }, set: {
            self.assets[key] = $0
        })
    }
    
    private(set) var fetchResult: PHFetchResult<PHAsset>?
    
    func requestAuthorization() async -> Bool {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        
        if status == .authorized {
            PHPhotoLibrary.shared().register(self)
            return true
        }
        
        return false
    }
    
    @MainActor
    func load() async {
        Task {
            guard await requestAuthorization() else { return }
            let assets = await fetchPhotos()
            await MainActor.run {
                withAnimation {
                    self.assets = assets.groupedByDate()
                }
            }
        }
    }
    
    private func fetchPhotos() async -> [PHAsset] {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        if fetchResult == nil {
            fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        }
        var assets = [PHAsset]()
        fetchResult?.enumerateObjects { asset, _, _ in
            assets.append(asset)
        }
        return assets
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        Task { [weak self] in
            if let changes = changeInstance.changeDetails(for: fetchResult!) {
                self?.fetchResult = changes.fetchResultAfterChanges
                await load()
            }
        }
    }
}

extension Array where Element == PHAsset {
    func groupedByDate() -> Dictionary<String, [PHAsset]> {
        return Dictionary(grouping: self, by: { $0.creationDate!.formatted() })
    }
}

private extension Date {
    func formatted() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: self)
    }
}
