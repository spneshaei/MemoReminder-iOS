//
//  ImageSlideshow.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/8/21.
//

import SwiftUI
import Combine

struct ImageSlideshow<Content: View>: View {
    private var numberOfImages: Int
    private var content: Content
    @State private var currentIndex = 0
    
    private let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    
    init(numberOfImages: Int, @ViewBuilder content: () -> Content) {
        self.numberOfImages = numberOfImages
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geometry in
            // 2
            ZStack(alignment: .bottom) {
                HStack(spacing: 0) {
                    // 3
                    self.content
                }
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .leading)
                .offset(x: CGFloat(self.currentIndex) * -geometry.size.width, y: 0)
                .onReceive(self.timer) { _ in
                    self.currentIndex = (self.currentIndex + 1) % 3
                }
                HStack(spacing: 3) {
                    ForEach(0..<self.numberOfImages, id: \.self) { index in
                        Circle()
                          .frame(width: index == self.currentIndex ? 10 : 8,
                                 height: index == self.currentIndex ? 10 : 8)
                          .foregroundColor(index == self.currentIndex ? Color("yellow") : .white)
                          .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                          .padding(.bottom, 8)
                    }
                }
            }
        }
    }
}

struct ImageSlideshow_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            ImageSlideshow(numberOfImages: 3) {
                Image("logo-4")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                Image("Second-Bg")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                Image("wave")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
            }
        }.frame(width: UIScreen.main.bounds.width, height: 300, alignment: .center)
    }
}
