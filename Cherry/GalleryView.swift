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
                    ForEach(viewModel.keys, id: \.self) { date in
                        if let assets = viewModel.assets[date], !assets.isEmpty {
                            NavigationLink(destination:
                                            ImageSliderView(phassets: viewModel.binding(for: date), title: date)
                            ) {
                                PhotosRow(title: date) {
                                    LazyVGrid(columns: columns) {
                                        ForEach(assets, id: \.localIdentifier) { asset in
                                            AsyncImage(
                                                phasset: asset,
                                                size: CGSize(width: floor(proxy.size.width / 5) * UIScreen.main.scale,
                                                             height: floor(proxy.size.width / 5) * UIScreen.main.scale),
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
            }
            .navigationBarTitleDisplayMode(.inline)
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
