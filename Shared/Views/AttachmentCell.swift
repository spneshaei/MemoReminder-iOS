//
//  AttachmentCell.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/21/21.
//

import SwiftUI

struct AttachmentCell: View {
    @State var url: String
    
    @State var showSafari = false // https://stackoverflow.com/questions/56518029/how-do-i-use-sfsafariviewcontroller-with-swiftui
    
    var imageSystemName: String {
        if url.hasSuffix("png") || url.hasSuffix("jpg") {
            return "photo"
        } else if url.hasSuffix("mp4") || url.hasSuffix("mov") {
            return "film"
        } else if url.hasSuffix("m4a") || url.hasSuffix("mp3") {
            return "waveform"
        } else {
            return "doc"
        }
    }
    
    var textName: String {
        if url.hasSuffix("png") || url.hasSuffix("jpg") {
            return "Photo"
        } else if url.hasSuffix("mp4") || url.hasSuffix("mov") {
            return "Video"
        } else if url.hasSuffix("m4a") || url.hasSuffix("mp3") {
            return "Voice"
        } else {
            return "File"
        }
    }
    
    var body: some View {
        Button(action: {
            showSafari = true
        }) {
            HStack {
                Image(systemName: imageSystemName)
                Text(textName)
                Spacer()
            }
        }
        .sheet(isPresented: $showSafari) {
            if let url = URL(string: url) {
                SafariView(url: url)
            }
        }
    }
}

struct AttachmentCell_Previews: PreviewProvider {
    static var previews: some View {
        AttachmentCell(url: "")
    }
}
