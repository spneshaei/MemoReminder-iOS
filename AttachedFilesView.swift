//
//  AttachedFilesView.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/20/21.
//

import SwiftUI

struct AttachedFilesView: View {
    @State var memory: Memory
    @StateObject var viewModel = AttachedFilesViewModel()
    @ObservedObject var memoryViewModel: MemoryViewModel
    
    var body: some View {
        List(memory.attachedFileURLs, id: \.self) { attachedFileURL in
            if let _ = URL(string: attachedFileURL) {
                AttachmentCell(url: attachedFileURL)
            }
        }
        .navigationBarTitle("Attached Files")
    }
}

struct AttachmentCell: View {
    var url: String
    
    var imageSystemName: String {
        if url.hasSuffix("png") || url.hasSuffix("jpg") {
            return "photo"
        } else if url.hasSuffix("mp4") || url.hasSuffix("mov") {
            return "film"
        } else if url.hasSuffix("aac") || url.hasSuffix("mp3") {
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
        } else if url.hasSuffix("aac") || url.hasSuffix("mp3") {
            return "Voice"
        } else {
            return "File"
        }
    }
    
    var body: some View {
        HStack {
            Image(systemName: imageSystemName)
            Text(textName)
            Spacer()
        }
    }
}

struct AttachedFilesView_Previews: PreviewProvider {
    static var previews: some View {
        AttachedFilesView(memory: .sample, memoryViewModel: .sample)
    }
}
