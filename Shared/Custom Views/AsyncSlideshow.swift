//
//  AsyncSlideshow.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/8/21.
//

import SwiftUI
import URLImage
import ActivityIndicatorView

@available(iOS 15.0, *)
struct AsyncSlideshow: View {
    @State var imageURLs: [String]
    
    var body: some View {
        GeometryReader { geometry in
            ImageSlideshow(numberOfImages: imageURLs.count) {
                ForEach(imageURLs, id: \.self) { imageURL in
                    if URL(string: imageURL) != nil {
                        AsyncImage(url: URL(string: imageURL)!) { image in
                            image
                        } placeholder: {
                            ActivityIndicatorView(isVisible: .constant(true), type: .default)
                                .frame(width: 30.0, height: 30.0)
                                .foregroundColor(.orange)
                        }
                            .scaledToFit()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                    }
                }
            }
        }
    }
}

@available(iOS 15.0, *)
struct AsyncSlideshow_Previews: PreviewProvider {
    static var previews: some View {
        AsyncSlideshow(imageURLs: [])
    }
}
