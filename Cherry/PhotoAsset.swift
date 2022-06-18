//
//  PhotoAsset.swift
//  Cherry
//
//  Created by junyng on 2022/06/18.
//

import Foundation

struct PhotoAsset: Equatable {
    typealias ID = String
    
    let id: ID
    let creationDate: Date?
    let modificationDate: Date?
    
    static func == (lhs: PhotoAsset, rhs: PhotoAsset) -> Bool {
        return lhs.id == rhs.id
    }
}
