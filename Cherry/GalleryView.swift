//
//  GalleryView.swift
//  Cherry
//
//  Created by junyeong-cho on 2021/12/12.
//

import SwiftUI
import Photos

struct GalleryView: View {
    
    @ObservedObject var viewModel = PhotoLibrary()
    
    private let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 5)
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.keys, id: \.self) { key in
                        NavigationLink(destination: ImageSliderView(phassets: viewModel.binding(for: key))) {
                            PhotosRow(title: key) {
                                LazyVGrid(columns: columns) {
                                    ForEach(viewModel.assets[key] ?? [], id: \.localIdentifier) { asset in
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
            }
            .task {
                await viewModel.load()
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("🍒 Cherry")
                }
            }
        }
    }
}
