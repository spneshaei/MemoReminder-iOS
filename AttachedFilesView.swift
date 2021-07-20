//
//  AttachedFilesView.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/20/21.
//

import SwiftUI
import SafariServices
import ImagePickerView
import ActivityIndicatorView

struct AttachedFilesView: View {
    @EnvironmentObject var globalData: GlobalData
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
    @State var showImagePicker = false
    @State var showActivityIndicatorView = false
    @State var showingUploadErrorAlert = false
    @State var isSelectingFileSheetPresented = false
    
    func upload(fileURL: URL) {
        let concurrentQueue = DispatchQueue(label: "MemoReminderUploadFileAsAttachment", attributes: .concurrent)
        concurrentQueue.async {
            main {
                showActivityIndicatorView = true
                uploadFileState = .uploading
            }
            memoryViewModel.upload(memory: memory, fileURL: fileURL, globalData: globalData) { r in
                if let resultString = r {
                    let result = JSON(parseJSON: resultString)
                    let fileURL = result["file"].stringValue
                    main {
                        memory.attachedFileURLs.append(fileURL)
                        uploadFileState = .notStarted
                        showActivityIndicatorView = false
                    }
                } else {
                    main {
                        uploadFileState = .notStarted
                        showActivityIndicatorView = false
                        showingUploadErrorAlert = true
                    }
                }
            }
        }
    }
    
    func upload(image: UIImage) {
        let concurrentQueue = DispatchQueue(label: "MemoReminderUploadPhotoAsAttachment", attributes: .concurrent)
        concurrentQueue.async {
            main {
                showActivityIndicatorView = true
                uploadFileState = .uploading
            }
            memoryViewModel.upload(memory: memory, image: image, globalData: globalData) { r in
                if let resultString = r {
                    let result = JSON(parseJSON: resultString)
                    let imageURL = result["file"].stringValue
                    main {
                        memory.attachedFileURLs.append(imageURL)
                        uploadFileState = .notStarted
                        showActivityIndicatorView = false
                    }
                } else {
                    main {
                        uploadFileState = .notStarted
                        showActivityIndicatorView = false
                        showingUploadErrorAlert = true
                    }
                }
            }
        }
    }
    
    var body: some View {
        ZStack {
            List {
                if uploadFileState == .uploading {
                    ProgressView("Uploading - \(Double(round(100 * memoryViewModel.uploadAmount) / 100))%", value: memoryViewModel.uploadAmount, total: 100)
                        .listRowSeparator(.hidden)
                }
                ForEach(memory.attachedFileURLs, id: \.self) {  attachedFileURL in
                    if let _ = URL(string: attachedFileURL) {
                        AttachmentCell(url: attachedFileURL)
                    }
                }
            }
            .navigationBarTitle("Attached Files")
            .navigationBarItems(trailing: HStack {
                if uploadFileState == .notStarted {
                    Button(action: { showFileSourcePicker = true }) {
                        Image(systemName: "plus")
                    }
                }
            })
            .confirmationDialog("Select the appropriate option", isPresented: $showFileSourcePicker, titleVisibility: .visible) {
                Button("Record a voice file") {
                    fileSourceSelection = .voice
                    // TODO: Voice
    //                showImagePicker = true
                }
                Button("Select from the Files") {
                    fileSourceSelection = .files
                    isSelectingFileSheetPresented = true
                }
                Button("Select from the Photos") {
                    fileSourceSelection = .photoLibrary
                    showImagePicker = true
                }
                Button("Take a new photo") {
                    fileSourceSelection = .camera
                    showImagePicker = true
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePickerView(sourceType: fileSourceSelection == .photoLibrary ? .photoLibrary : .camera) { image in
                    upload(image: image)
                }
            }
            .alert("Error in uploading the attachment. Please try again", isPresented: $showingUploadErrorAlert) {
                Button("OK", role: .cancel) { }
            }
            .fileImporter(isPresented: $isSelectingFileSheetPresented, allowedContentTypes: [], allowsMultipleSelection: false) { result in
                guard let url = try? result.get().first else { return }
                upload(fileURL: url)
            }
            
            ActivityIndicatorView(isVisible: $showActivityIndicatorView, type: .equalizer)
                .frame(width: 100.0, height: 100.0)
                .foregroundColor(.orange)
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
            .environmentObject(GlobalData.sample)
    }
}
