//
//  ImageSliderView.swift
//  Cherry
//
//  Created by junyeong-cho on 2021/12/13.
//

import Photos
import SwiftUI

struct ImageSliderView: View {
    
    @State private var focusedID: String
    @State private(set) var phassets = [PHAsset]()
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                TabView(selection: $focusedID) {
                    ForEach(phassets, id: \.localIdentifier) { asset in
                        AsyncImage(
                            phasset: asset,
                            placeholder: { ProgressView() },
                            image: {
                                Image(uiImage: $0)
                                    .resizable()
                            }
                        )
                            .tag(asset.localIdentifier)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 2) {
                            ForEach(phassets, id: \.localIdentifier) { asset in
                                AsyncImage(
                                    phasset: asset,
                                    placeholder: { ProgressView() },
                                    image: {
                                        Image(uiImage: $0)
                                            .resizable()
                                    }
                                )
                                    .frame(width: 50, height: 50)
                                    .border(focusedID == asset.localIdentifier ? Color.black : Color.clear, width: 2)
                                    .onTapGesture {
                                        self.focusedID = asset.localIdentifier
                                    }
                            }
                        }
                    }
                    .onChange(of: focusedID) { id in
                        withAnimation {
                            proxy.scrollTo(id)
                        }
                    }
                }
            }
        }
    }
    
    init(phassets: [PHAsset]) {
        self.phassets = phassets
        self.focusedID = phassets.first?.localIdentifier ?? ""
    }

    private func deletePhoto() {
        guard let asset = phassets.first(where: { $0.localIdentifier == focusedID }) else { return }
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets([asset] as NSArray)
        }, completionHandler: nil)
    }
}

struct ImageSliderView_Previews: PreviewProvider {
    static var previews: some View {
        ImageSliderView(phassets: [])
    }
}
