//
//  GalleryView.swift
//  Cherry
//
//  Created by junyeong-cho on 2021/12/12.
//

import SwiftUI

struct GalleryView: View {
    
    @ObservedObject var photosViewModel = PhotosViewModel()
    
    private let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 5)
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                LazyVStack {
                    ForEach(photosViewModel.assets.groupedByDate().sorted { $0.key > $1.key }, id: \.key) { key, value in
                        PhotosRow(title: key) {
                            LazyVGrid(columns: columns) {
                                ForEach(value, id: \.localIdentifier) { asset in
                                    AsyncImage(
                                        phasset: asset,
                                        placeholder: { ProgressView() },
                                        image: {
                                            Image(uiImage: $0)
                                                .resizable()
                                        }
                                    )
                                        .frame(width: floor(proxy.size.width / 5), height: floor(proxy.size.width / 5))
                                }
                            }
                        }
                    }
                }
            }
            .task {
                await photosViewModel.load()
            }
        }
    }
}
