//
//  CherryModel.swift
//  Cherry
//
//  Created by junyng on 2022/06/29.
//

import SwiftUI
import Photos

@MainActor
final class CherryModel: NSObject, ObservableObject {
    @Published var assets = [PhotoAsset]() {
        didSet {
            fetchResults = PHAsset.fetchAssets(
                withLocalIdentifiers: assets.map { $0.id },
                options: nil
            )
        }
    }
    
    private var fetchResults: PHFetchResult<PHAsset>?
    
    override init() {
        super.init()
        
        PHPhotoLibrary.shared().register(self)
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
}

extension CherryModel: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let results = fetchResults,
              let changes = changeInstance.changeDetails(for: results) else {
                  return
              }
        
        fetchResults = changes.fetchResultAfterChanges
        
        let removals = changes.removedObjects.converted()
        let updates = changes.changedObjects.converted()
        
        if removals.count > 0 {
            assets.removeAll(where: { removals.contains($0) })
        }
        
        if updates.count > 0 {
            assets = assets.map { asset -> PhotoAsset in
                let updated = updates.filter { $0.id == asset.id }.first
                return updated ?? asset
            }
        }
    }
}

extension Array where Element == PHAsset {
    func converted() -> [PhotoAsset] {
        return self.map {
            .init(
                id: $0.localIdentifier,
                creationDate: $0.creationDate,
                modificationDate: $0.modificationDate
            )
        }
    }
}
