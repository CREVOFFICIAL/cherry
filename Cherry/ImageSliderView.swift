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
    @Binding private var phassets: [PHAsset]
    
    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                GeometryReader { proxy in
                    TabView(selection: $focusedID) {
                        ForEach(phassets, id: \.localIdentifier) { asset in
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
                            ForEach(phassets, id: \.localIdentifier) { asset in
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
                                    .border(focusedID == asset.localIdentifier ? Color.black : Color.clear, width: 2)
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
                }
            }
        }
    }
    
    init(phassets: Binding<[PHAsset]>) {
        self._phassets = phassets
        self.focusedID = phassets.wrappedValue.first?.localIdentifier ?? ""
    }
}
