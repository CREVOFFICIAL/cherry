//
//  ImageSliderView.swift
//  Cherry
//
//  Created by junyeong-cho on 2021/12/13.
//

import Photos
import SwiftUI

struct ImageSliderView: View {
    
    private let title: String
    
    @State private var removeIDs = [String]()
    @State private var focusedID: String
    @Binding private var assets: [Asset]
    
    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                GeometryReader { proxy in
                    TabView(selection: $focusedID) {
                        ForEach(assets, id: \.id) { asset in
                            AsyncImage(
                                phasset: asset.convert()!,
                                size: CGSize(width: proxy.size.width * UIScreen.main.scale,
                                             height: proxy.size.height * UIScreen.main.scale),
                                placeholder: { ProgressView() },
                                image: {
                                    Image(uiImage: $0)
                                        .resizable()
                                }
                            )
                                .aspectRatio(contentMode: .fit)
                                .tag(asset.id)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 2) {
                            ForEach(assets, id: \.id) { asset in
                                AsyncImage(
                                    phasset: asset.convert()!,
                                    size: CGSize(width: 60 * UIScreen.main.scale,
                                                 height: 60 * UIScreen.main.scale),
                                    placeholder: { ProgressView() },
                                    image: {
                                        Image(uiImage: $0)
                                            .resizable()
                                    }
                                )
                                    .frame(width: 60, height: 60)
                                    .border(focusedID == asset.id ? Color(UIColor.systemBlue) : Color.clear, width: 2)
                                    .overlay(
                                        VStack {
                                            if removeIDs.contains(asset.id) {
                                                Image(systemName: "multiply")
                                                    .resizable()
                                                    .frame(width: 30, height: 30)
                                                    .foregroundColor(Color(UIColor.systemRed))
                                            }
                                        }
                                            .frame(width: 60, height: 60)
                                            .background(removeIDs.contains(asset.id) ? .black.opacity(0.1) : .clear)
                                    )
                                    .onTapGesture {
                                        self.focusedID = asset.id
                                    }
                            }
                        }
                    }
                    .frame(height: 60)
                    .onChange(of: focusedID) { id in
                        withAnimation {
                            proxy.scrollTo(id)
                        }
                    }
                }
            }
            .navigationBarTitle(title)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Image(systemName: removeIDs.contains(focusedID) ? "checkmark.rectangle" : "plus.rectangle")
                        .foregroundColor(Color(UIColor.systemBlue))
                        .onTapGesture {
                            if removeIDs.contains(focusedID) {
                                removeIDs.removeAll(where: { $0 == focusedID })
                            } else {
                                removeIDs.append(focusedID)
                            }
                        }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button(action: removePhotos) {
                        Image(systemName: "trash")
                            .foregroundColor(Color(UIColor.systemGray))
                    }
                }
            }
        }
    }
    
    init(assets: Binding<[Asset]>, title: String, selectedAsset: Asset) {
        self._assets = assets
        self.focusedID = selectedAsset.id
        self.title = title
    }
    
    private func removePhotos() {
        let phassets = assets.filter { removeIDs.contains($0.id) }.compactMap { $0.convert() }
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(phassets as NSArray)
        }, completionHandler: nil)
    }
}
