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
    
    enum UploadFileState {
        case notStarted, uploading
    }
    
    enum FileSourceSelection {
        case files, voice, photoLibrary, camera
    }
    
    @State var uploadFileState: UploadFileState = .notStarted
    @State var fileSourceSelection: FileSourceSelection = .files
    @State var showFileSourcePicker = false
    
    var body: some View {
        List(memory.attachedFileURLs, id: \.self) { attachedFileURL in
            if let _ = URL(string: attachedFileURL) {
                AttachmentCell(url: attachedFileURL)
            }
        }
        .navigationBarTitle("Attached Files")
        .navigationBarItems(trailing: Button(action: { showFileSourcePicker = true }) {
            Image(systemName: "plus")
        })
        .confirmationDialog("Select the appropriate option", isPresented: $showFileSourcePicker, titleVisibility: .visible) {
            Button("Record a voice file") {
                fileSourceSelection = .voice
                // TODO: Voice
//                showImagePicker = true
            }
            Button("Select from the Files") {
                fileSourceSelection = .files
                // TODO: Files
//                showImagePicker = true
            }
            Button("Select from the Photos") {
                fileSourceSelection = .photoLibrary
                // TODO: Photos
//                showImagePicker = true
            }
            Button("Take a new photo") {
                fileSourceSelection = .camera
                // TODO: Camera
//                showImagePicker = true
            }
        }
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
