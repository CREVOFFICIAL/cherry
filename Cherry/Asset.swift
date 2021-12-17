//
//  Asset.swift
//  Cherry
//
//  Created by junyeong-cho on 2021/12/17.
//

import Photos

struct Asset: Identifiable, Hashable {
    let id: String
    let creationDate: Date
    let mediaType: MediaType
    
    init(phasset: PHAsset) {
        self.id = phasset.localIdentifier
        self.creationDate = phasset.creationDate!
        
        switch phasset.mediaType {
        case .image:
            self.mediaType = .image
        case .video:
            self.mediaType = .video
        case .audio:
            self.mediaType = .audio
        case .unknown:
            self.mediaType = .unknown
        @unknown default:
            self.mediaType = .unknown
        }
    }
    
    enum MediaType: Equatable {
        case audio
        case image
        case video
        case unknown
    }
}

extension Asset {
    func convert() -> PHAsset? {
        let options = PHFetchOptions()
        options.fetchLimit = 1
        return PHAsset.fetchAssets(withLocalIdentifiers: [id], options: options).firstObject
    }
}
