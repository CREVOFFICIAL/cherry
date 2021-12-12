//
//  GalleryView.swift
//  Cherry
//
//  Created by junyeong-cho on 2021/12/12.
//

import SwiftUI

struct GalleryView: View {
    private let sections: [Section] = .sections
    private let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 5)
    
    var body: some View {
        GeometryReader { proxy in
            List {
                ForEach(0..<sections.count) { section in
                    PhotosRow(title: Date().description) {
                        LazyVGrid(columns: columns, spacing: 0) {
                            ForEach(0..<sections[section].count) { item in
                                Image(uiImage: sections[section][item])
                                    .resizable()
                                    .frame(width: floor(proxy.size.width / 5), height: floor(proxy.size.width / 5))
                            }
                        }
                    }
                }
                .listRowSeparator(.hidden)
            }
            .refreshable {
                // TODO: reload logic
            }
            .background(Color.secondary)
        }
    }
}

typealias Section = [UIImage]

extension Array where Element == Section {
    static let sections: [Section] = [
        .images,
        .images,
        .images,
        .images
    ]
}

extension Array where Element == UIImage {
    static let images = [
        UIImage(systemName: "person.fill")!,
        UIImage(systemName: "person.fill")!,
        UIImage(systemName: "person.fill")!,
        UIImage(systemName: "person.fill")!,
        UIImage(systemName: "person.fill")!
    ]
}
