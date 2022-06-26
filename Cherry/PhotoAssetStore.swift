//
//  PhotoAssetStore.swift
//  Cherry
//
//  Created by junyng on 2022/06/26.
//

import Photos
import SwiftUI

@MainActor final class PhotoAssetStore: NSObject, ObservableObject {
    @Published private(set) var assets = [PhotoAsset]()
    
    private(set) var fetchResults: PHFetchResult<PHAsset>?
    
    override init() {
        super.init()
        
        PHPhotoLibrary.shared().register(self)
    }
    
    func append(assets: [PhotoAsset]) {
        self.assets.append(contentsOf: assets)
        saveChanges()
    }
    
    func remove(assets: [PhotoAsset]) {
        self.assets.removeAll(where: { assets.contains($0) })
        saveChanges()
    }
    
    private func saveChanges() {
        fetchResults = PHAsset.fetchAssets(
            withLocalIdentifiers: assets.map { $0.id },
            options: nil
        )
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
}

extension PhotoAssetStore: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let results = fetchResults,
              let changes = changeInstance.changeDetails(for: results) else {
                  return
              }
        
        fetchResults = changes.fetchResultAfterChanges
        
        let removed = changes.removedObjects
        
        assets.removeAll {
            removed.map { $0.localIdentifier }.contains($0.id)
        }
        
        // TODO: update change objects
    }
}
