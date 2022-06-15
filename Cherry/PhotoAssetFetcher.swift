//
//  AssetFetcher.swift
//  Cherry
//
//  Created by junyng on 2022/06/15.
//

import Photos

struct PhotoAsset: Equatable {
    typealias ID = String
    
    let id: ID
    let creationDate: Date?
    let modificationDate: Date?
    
    static func == (lhs: PhotoAsset, rhs: PhotoAsset) -> Bool {
        return lhs.id == rhs.id
    }
}

class PhotoAssetFetcher {
    struct Request {
        enum SortOrder {
            case latest
            case past
        }
        let count: Int = 20
        let sortOrder: SortOrder = .latest
        let date: Date = .init()
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

struct _ImageLoader {
    func load(from id: PhotoAsset.ID) async -> UIImage {
        return .init()
    }
}
