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

struct PhotoAssetFetcher {
    struct Request {
        enum SortOrder {
            case latest
            case past
        }
        let count: Int = 20
        let sortOrder: SortOrder = .latest
    }
    
    func fetch(request: Request) -> [PhotoAsset] {
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = request.count
        switch request.sortOrder {
        case .latest:
            fetchOptions.sortDescriptors = [
                NSSortDescriptor(key: FetchingKey.creationDate,
                                 ascending: true)]
        case .past:
            fetchOptions.sortDescriptors = [
                NSSortDescriptor(key: FetchingKey.creationDate,
                                 ascending: false)]
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
}

extension PhotoAssetFetcher {
    private struct FetchingKey {
        static let creationDate = "creationDate"
    }
}

struct _ImageLoader {
    func load(from id: PhotoAsset.ID) async -> UIImage {
        return .init()
    }
}
