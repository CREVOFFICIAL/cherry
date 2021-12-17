//
//  PhotosRow.swift
//  Cherry
//
//  Created by junyeong-cho on 2021/12/12.
//

import SwiftUI

struct PhotosRow<Content: View>: View {
    private let title: String
    private let alignment: HorizontalAlignment
    private let content: Content

    init(title: String, alignment: HorizontalAlignment = .leading, @ViewBuilder content: () -> Content) {
        self.title = title
        self.alignment = alignment
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: alignment) {
            Text(title)
                .font(.system(.callout))
                .foregroundColor(.gray)
            content
        }
        .background(Color.white)
    }
}
