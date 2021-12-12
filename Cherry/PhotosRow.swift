//
//  PhotosRow.swift
//  Cherry
//
//  Created by junyeong-cho on 2021/12/12.
//

import SwiftUI

struct PhotosRow<Content: View>: View {
    private let title: String
    private let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack {
            content
            Text(title)
                .font(.system(.callout))
        }
        .background(Color.white)
    }
}
