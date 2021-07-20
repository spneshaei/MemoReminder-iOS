//
//  AttachedFilesView.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/20/21.
//

import SwiftUI
import SafariServices

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
    @State var url: String
    
    @State var showSafari = false // https://stackoverflow.com/questions/56518029/how-do-i-use-sfsafariviewcontroller-with-swiftui
    
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

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {
    }

}

struct AttachedFilesView_Previews: PreviewProvider {
    static var previews: some View {
        AttachedFilesView(memory: .sample, memoryViewModel: .sample)
    }
}
