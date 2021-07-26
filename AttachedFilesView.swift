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
        case files, voice, photoLibrary, camera, video
    }
    
    @State var uploadFileState: UploadFileState = .notStarted
    @State var fileSourceSelection: FileSourceSelection = .files
    @State var showFileSourcePicker = false
    @State var showImagePicker = false
    @State var showActivityIndicatorView = false
    @State var showingUploadErrorAlert = false
    @State var isSelectingFileSheetPresented = false
    @State var isNavigationToVoiceRecordViewActive = false
    @State var isDeleteAllDownloadedFilesConfirmationDialogVisible = false
    @State var showVideoPicker = false
    
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
    
    func upload(video: Data) {
        let concurrentQueue = DispatchQueue(label: "MemoReminderUploadVideoAsAttachment", attributes: .concurrent)
        concurrentQueue.async {
            main {
                showActivityIndicatorView = true
                uploadFileState = .uploading
            }
            memoryViewModel.upload(memory: memory, data: video, globalData: globalData) { r in
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
    
    // https://stackoverflow.com/questions/50014062/remove-all-files-from-within-documentdirectory-in-swift
    func clearAllFiles() {
        let fileManager = FileManager.default
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        
        print("Directory: \(paths)")
        
        do
        {
            let fileName = try fileManager.contentsOfDirectory(atPath: paths)
            
            for file in fileName {
                // For each file in the directory, create full path and delete the file
                let filePath = URL(fileURLWithPath: paths).appendingPathComponent(file).absoluteURL
                try fileManager.removeItem(at: filePath)
            }
        }catch let error {
            print(error.localizedDescription)
        }
    }
    
    var body: some View {
        ZStack {
            List {
//                if uploadFileState == .uploading {
//                    ProgressView("Uploading - \(Double(round(100 * memoryViewModel.uploadAmount) / 100))%", value: memoryViewModel.uploadAmount, total: 100)
//                        .listRowSeparator(.hidden)
//                }
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
                            .accessibility(hint: Text("Add file"))
                    }
                }
            })
            NavigationLink(destination: VoiceRecordView(memory: memory, memoryViewModel: memoryViewModel), isActive: $isNavigationToVoiceRecordViewActive) {
                EmptyView()
            }
            .confirmationDialog("Select the appropriate action", isPresented: $showFileSourcePicker, titleVisibility: .visible) {
                Button("Record a voice file") {
                    fileSourceSelection = .voice
                    isNavigationToVoiceRecordViewActive = true
                }
                Button("Select PDF from the Files") {
                    fileSourceSelection = .files
                    isSelectingFileSheetPresented = true
                }
                Button("Select from the Photos") {
                    fileSourceSelection = .photoLibrary
                    showImagePicker = true
                }
                Button("Select from the Videos") {
                    fileSourceSelection = .video
                    showVideoPicker = true
                }
                Button("Take a new photo") {
                    fileSourceSelection = .camera
                    showImagePicker = true
                }
                Button("Cancel", role: .cancel) { }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePickerView(sourceType: fileSourceSelection == .photoLibrary ? .photoLibrary : .camera) { image in
                    upload(image: image)
                }
            }
            .alert("Error in uploading the attachment. Please try again", isPresented: $showingUploadErrorAlert) {
                Button("OK", role: .cancel) { }
            }
            .fileImporter(isPresented: $isSelectingFileSheetPresented, allowedContentTypes: [.pdf], allowsMultipleSelection: false) { result in
                guard let url = try? result.get().first else { return }
                upload(fileURL: url)
            }
            
            ActivityIndicatorView(isVisible: $showActivityIndicatorView, type: .equalizer)
                .frame(width: 100.0, height: 100.0)
                .foregroundColor(.orange)
        }
        .sheet(isPresented: $showVideoPicker) {
            VideoPickerView(sourceType: .photoLibrary) { video in
                upload(video: video)
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
