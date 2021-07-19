//
//  HomeTopView.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/17/21.
//

import SwiftUI
import Grid
import URLImage

struct HomeTopView: View {
    @State var imageURLStrings: [String]
    
    var imageURLs: [URL] {
        var urls: [URL] = []
        imageURLStrings.forEach { imageURLString in
            if let url = URL(string: imageURLString) {
                urls.append(url)
            }
        }
        return urls
    }
    
    var body: some View {
        ScrollView {
            Grid(imageURLs, id: \.self) { imageURL in
                AsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    Color.purple.opacity(0)
                }
            }
        }
        .gridStyle(
            StaggeredGridStyle(.horizontal, tracks: 2, spacing: 4)
        )
    }
}

struct HomeTopView_Previews: PreviewProvider {
    static var previews: some View {
        HomeTopView(imageURLStrings: [])
    }
}
