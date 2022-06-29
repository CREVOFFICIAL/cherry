//
//  AssetFetcher.swift
//  Cherry
//
//  Created by junyng on 2022/06/15.
//

import Photos

final class PhotoAssetFetcher {
    struct Request {
        enum SortOrder {
            case latest
            case past
        }
        let count: Int
        let sortOrder: SortOrder
        let date: Date
        
        init(
            count: Int = 20,
            sortOrder: SortOrder = .latest,
            date: Date = .init()
        ) {
            self.count = count
            self.sortOrder = sortOrder
            self.date = date
        }
    }
    
    func fetch(request: Request) async throws -> [PhotoAsset] {
        let status = await requestAuthorization()
        guard status == .authorized || status == .limited else {
            throw PhotoAssetFetcher.Error.notAuthorized
        }
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = request.count
        switch request.sortOrder {
        case .latest:
            fetchOptions.predicate = NSPredicate(format: "(\(Key.creationDate) < %@)", request.date as NSDate)
            fetchOptions.sortDescriptors = [
                NSSortDescriptor(
                    key: Key.creationDate,
                    ascending: false
                )
            ]
        case .past:
            fetchOptions.predicate = NSPredicate(format: "(\(Key.creationDate) > %@)", request.date as NSDate)
            fetchOptions.sortDescriptors = [
                NSSortDescriptor(
                    key: Key.creationDate,
                    ascending: true
                )
            ]
        }
        var assets = [PHAsset]()
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        fetchResult.enumerateObjects { asset, _, _ in
            assets.append(asset)
        }
        return assets.map {
            .init(
                id: $0.localIdentifier,
                creationDate: $0.creationDate,
                modificationDate: $0.modificationDate
            )
        }
    }
    
    private func requestAuthorization() async -> PHAuthorizationStatus {
        return await withCheckedContinuation { continuation in
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                continuation.resume(with: .success(status))
            }
        }
    }
}

extension PhotoAssetFetcher {
    private struct Key {
        static let creationDate = "creationDate"
    }
}

extension PhotoAssetFetcher {
    enum Error: Swift.Error {
        case notAuthorized
    }
}
