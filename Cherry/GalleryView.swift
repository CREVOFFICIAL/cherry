//
//  GalleryView.swift
//  Cherry
//
//  Created by junyeong-cho on 2021/12/12.
//

import SwiftUI
import Photos

struct GalleryView: View {
    
    private let photosRowCount: Int = 5
    private let spacing: CGFloat = 2
    private let padding: CGFloat = 8
    
    @ObservedObject var viewModel = PhotoLibrary()
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                let side = (proxy.size.width - (spacing * CGFloat(photosRowCount - 1)) - padding * 2) / CGFloat(photosRowCount)
                let item = GridItem(.fixed(side), spacing: spacing)
                VStack {
                    ForEach(viewModel.keys, id: \.self) { date in
                        // album
                        if let assets = viewModel.assets[date], !assets.isEmpty {
                            NavigationLink(
                                destination:
                                    ImageSliderView(
                                        assets: viewModel.binding(for: date),
                                        title: date
                                    )
                            ) {
                                PhotosRow(title: date) {
                                    LazyVGrid(columns: Array(repeating: item, count: photosRowCount)) {
                                        ForEach(assets, id: \.id) { asset in
                                            AsyncImage(
                                                phasset: asset.convert()!,
                                                size: CGSize(width: side * UIScreen.main.scale,
                                                             height: side * UIScreen.main.scale),
                                                placeholder: {
                                                    ProgressView()
                                                        .frame(width: side, height: side)
                                                },
                                                image: {
                                                    Image(uiImage: $0)
                                                        .resizable()
                                                }
                                            )
                                                .frame(width: side, height: side)
                                                .clipped()
                                        }
                                    }
                                }
                                .padding(padding)
                            }
                            Divider()
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
