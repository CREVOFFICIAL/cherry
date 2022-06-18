//
//  CherryService.swift
//  Cherry
//
//  Created by junyng on 2022/06/18.
//

import Foundation

class CherryService {
    private let assetFetcher: PhotoAssetFetcher
    private let imageLoader: _ImageLoader

    private(set) var fetchDate: Date?
    
    init(
        assetFetcher: PhotoAssetFetcher = .init(),
        imageLoader: _ImageLoader = .init()
    ) {
        self.assetFetcher = assetFetcher
        self.imageLoader = imageLoader
    }
    
    func fetchSimiliarImages(size: CGSize, count: Int) async throws -> [UIImage] {
        let assets = try await assetFetcher.fetch(request: .init(count: count))
        var images = [UIImage]()
        for asset in assets {
            if let image = await imageLoader.load(from: asset.id, size: size) {
                images.append(image)
            }
        }
        self.fetchDate = assets.last?.creationDate
        return images
    }
}
