//
//  GalleryView.swift
//  Cherry
//
//  Created by junyeong-cho on 2021/12/12.
//

import SwiftUI
import Photos

struct GalleryView: View {
    
    private let rowCount: Int = 5
    private let spacing: CGFloat = 2
    private let padding: CGFloat = 8
    
    @ObservedObject var viewModel = PhotoLibrary()
    
    var body: some View {
        GeometryReader { proxy in
            if viewModel.authorizationStatus == .authorized {
                ScrollView {
                    let side = (proxy.size.width - (spacing * CGFloat(rowCount - 1)) - padding * 2) / CGFloat(rowCount)
                    let item = GridItem(.fixed(side), spacing: spacing)
                    
                    LazyVGrid(columns: Array(repeating: item, count: rowCount), alignment: .leading) {
                        ForEach(viewModel.keys, id: \.self) { date in
                            if let assets = viewModel.assets[date], !assets.isEmpty {
                                Section(date) {
                                    ForEach(assets, id: \.id) { asset in
                                        NavigationLink(
                                            destination: ImageSliderView(
                                                assets: viewModel.binding(for: date),
                                                title: date
                                            )
                                        ) {
                                            AsyncImage(
                                                phasset: asset.convert()!,
                                                size: CGSize(width: side * UIScreen.main.scale,
                                                             height: side * UIScreen.main.scale),
                                                placeholder: {
                                                    ProgressView()
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
                                .font(.system(.callout))
                                .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding([.leading, .trailing], padding)
                }
            } else {
                VStack {
                    Spacer()
                    VStack(spacing: 16) {
                        Text("Cherry App can't access the photo libary.\nGo to Settings and allow Photos App access permission")
                            .font(.system(.callout))
                            .multilineTextAlignment(.center)
                        Button(action: gotoPrivacySettings) {
                            Text("Go to Settings")
                                .font(.system(.callout))
                                .foregroundColor(Color(UIColor.systemBlue))
                                .padding(6)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color(UIColor.systemBlue), lineWidth: 1)
                                )
                        }
                    }
                    Spacer()
                }
                .frame(maxWidth: proxy.size.width)
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

private extension GalleryView {
    func gotoPrivacySettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else { return }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
