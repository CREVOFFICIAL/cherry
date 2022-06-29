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
    
    var body: some View {
        Group {
            if viewModel.hasAuthorization {
                GalleryGrid()
                    .environmentObject(viewModel)
            } else {
                AuthorizationView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, C.padding)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(R.string.navigationTitle)
            }
        }
        .task {
            await viewModel.load()
        }
    }
}

struct GalleryGrid: View {
    
    @EnvironmentObject var viewModel: PhotoLibrary
    
    var body: some View {
        let side: CGFloat = C.side
        let item = GridItem(.fixed(side), spacing: C.spacing)
        let columns = Array(repeating: item, count: C.rowCount)
        
        ScrollView {
            LazyVGrid(columns: columns, alignment: .leading) {
                ForEach(viewModel.keys, id: \.self) { date in
                    if let assets = viewModel.assets[date], !assets.isEmpty {
                        Section(date) {
                            ForEach(assets, id: \.localIdentifier) { asset in
                                NavigationLink(
                                    destination: PhotoSliderView(
                                        assets: viewModel.binding(for: date),
                                        title: date,
                                        selectedID: asset.localIdentifier
                                    )
                                ) {
                                    AsyncImage(
                                        phasset: asset,
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
                    } else {
                        EmptyView()
                    }
                }
            }
        }
    }
}

struct AuthorizationView: View {
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .center)) {
            VStack(spacing: 16) {
                Text(R.string.photoPermission)
                    .font(.system(.callout))
                    .multilineTextAlignment(.center)
                Button(action: openSettings) {
                    Text(R.string.openSettings)
                        .font(.system(.callout))
                        .foregroundColor(Color(UIColor.systemBlue))
                        .padding(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color(UIColor.systemBlue), lineWidth: 1)
                        )
                }
            }
        }
    }
}

private extension AuthorizationView {
    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else { return }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

fileprivate struct C {
    static let side: CGFloat = 60
    static let rowCount: Int = 5
    static let spacing: CGFloat = 2
    static let padding: CGFloat = 8
}

fileprivate struct R {
    struct string {
        static let navigationTitle = "🍒 Cherry"
        static let photoPermission = "Cherry App can't access the photo libary.\nGo to Settings and allow Photos App access permission"
        static let openSettings = "Go to Settings"
    }
}
