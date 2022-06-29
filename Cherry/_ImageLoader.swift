//
//  _ImageLoader.swift
//  Cherry
//
//  Created by junyng on 2022/06/18.
//

import Photos

struct _ImageLoader {
    typealias CacheKey = NSString
    
    private let cache: NSCache<CacheKey, UIImage>
    
    init(cache: NSCache<CacheKey, UIImage> = _ImageLoader.cache) {
        self.cache = cache
    }
    
    func load(from id: PhotoAsset.ID, size: CGSize) async -> UIImage? {
        let cacheKey = id as NSString
        if let cached = cache.object(forKey: cacheKey) {
            return cached
        }
        
        guard let image = await requestImage(from: id, size: size) else { return nil }
        cache.setObject(image, forKey: cacheKey)
        return image
    }
    
    private func requestImage(from id: PhotoAsset.ID, size: CGSize) async -> UIImage? {
        return await withCheckedContinuation { continuation in
            guard let asset = PHAsset.fetchAssets(withLocalIdentifiers: [id],
                                                  options: nil).firstObject else {
                return continuation.resume(returning: nil)
            }
            
            let manager = PHImageManager()
            let options = PHImageRequestOptions()
            options.isSynchronous = true
            options.deliveryMode = .highQualityFormat
            manager.requestImage(
                for: asset,
                   targetSize: size,
                   contentMode: .aspectFit,
                   options: options) { image, _ in
                       continuation.resume(with: .success(image))
                   }
        }
    }
}

extension _ImageLoader {
    static var cache: NSCache<CacheKey, UIImage> {
        let cache = NSCache<CacheKey, UIImage>()
        cache.name = "imageloader.cache"
        cache.countLimit = 200
        return cache
    }
}
