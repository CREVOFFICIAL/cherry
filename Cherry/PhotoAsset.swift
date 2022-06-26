//
//  PhotoAsset.swift
//  Cherry
//
//  Created by junyng on 2022/06/18.
//

import Foundation

struct PhotoAsset: Equatable, Hashable {
    typealias ID = String
    
    let id: ID
    var creationDate: Date?
    var modificationDate: Date?
    
    static func == (lhs: PhotoAsset, rhs: PhotoAsset) -> Bool {
        return lhs.id == rhs.id
    }
}
