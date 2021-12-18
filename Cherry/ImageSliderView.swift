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
    private let selectedID: String
    
    @Environment(\.presentationMode) var presentationMode

    @State private var removeIDs = [String]()
    @State private var focusedID: String = ""
    @Binding private var assets: [PHAsset]
    
    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                GeometryReader { proxy in
                    TabView(selection: $focusedID) {
                        ForEach(assets, id: \.localIdentifier) { asset in
                            AsyncImage(
                                phasset: asset,
                                size: CGSize(width: proxy.size.width * UIScreen.main.scale,
                                             height: proxy.size.height * UIScreen.main.scale),
                                placeholder: { ProgressView() },
                                image: {
                                    Image(uiImage: $0)
                                        .resizable()
                                }
                            )
                                .aspectRatio(contentMode: .fit)
                                .tag(asset.localIdentifier)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 2) {
                            ForEach(assets, id: \.localIdentifier) { asset in
                                AsyncImage(
                                    phasset: asset,
                                    size: CGSize(width: 60 * UIScreen.main.scale,
                                                 height: 60 * UIScreen.main.scale),
                                    placeholder: { ProgressView() },
                                    image: {
                                        Image(uiImage: $0)
                                            .resizable()
                                    }
                                )
                                    .frame(width: 60, height: 60)
                                    .border(focusedID == asset.localIdentifier ? Color(UIColor.systemBlue) : Color.clear, width: 2)
                                    .overlay(
                                        VStack {
                                            if removeIDs.contains(asset.localIdentifier) {
                                                Image(systemName: "multiply")
                                                    .resizable()
                                                    .frame(width: 30, height: 30)
                                                    .foregroundColor(Color(UIColor.systemRed))
                                            }
                                        }
                                            .frame(width: 60, height: 60)
                                            .background(removeIDs.contains(asset.localIdentifier) ? .black.opacity(0.1) : .clear)
                                    )
                                    .onTapGesture {
                                        self.focusedID = asset.localIdentifier
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
                    .onAppear {
                        focusedID = selectedID
                        proxy.scrollTo(focusedID)
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
                    Button(action: {
                        Task {
                            await remove()
                        }
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(Color(UIColor.systemGray))
                    }
                }
            }
        }
    }
    
    init(assets: Binding<[PHAsset]>, title: String, selectedID: String) {
        self.title = title
        self._assets = assets
        self.selectedID = selectedID
    }
    
    @MainActor
    private func remove() async {
        Task {
            await removePhotos()
            await MainActor.run {
                withAnimation {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
    
    private func removePhotos() async {
        return await withCheckedContinuation { continuation in
            let assets = assets.filter { removeIDs.contains($0.localIdentifier) }
            PHPhotoLibrary.shared().performChanges ({
                PHAssetChangeRequest.deleteAssets(assets as NSArray)
            }) { success, _ in
                guard success else { return }
                continuation.resume()
            }
        }
    }
    
}
