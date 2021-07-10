//
//  StickyHeader.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/8/21.
//

// https://levelup.gitconnected.com/scrollview-sticky-header-462b9300378e

import SwiftUI

struct StickyHeader<Content: View>: View {

    var minHeight: CGFloat
    var maxHeight: CGFloat
    var content: Content
    
    init(minHeight: CGFloat = 200, maxHeight: CGFloat = 200, @ViewBuilder content: () -> Content) {
        self.minHeight = minHeight
        self.maxHeight = maxHeight
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geo in
            if(geo.frame(in: .global).minY <= 0) {
                content
                    .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
            } else {
                content
                    .offset(y: -geo.frame(in: .global).minY)
                    .frame(width: geo.size.width, height: geo.size.height + geo.frame(in: .global).minY)
            }
        }.frame(minHeight: minHeight, maxHeight: maxHeight)
    }
}
