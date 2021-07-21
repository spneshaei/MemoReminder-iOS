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
    @State var isNavigationToVoiceRecordViewActive = false
    @State var isDeleteAllDownloadedFilesConfirmationDialogVisible = false
    
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
                        memory.attachments.append(Attachment(memory: memory, url: fileURL))
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
                        memory.attachments.append(Attachment(memory: memory, url: imageURL))
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
                ForEach(memory.attachments) {  attachment in
                    if let _ = URL(string: attachment.url) {
                        AttachmentCell(url: attachment.url)
                    }
                }
            }
            .navigationBarTitle("Attached Files")
            .navigationBarItems(trailing: HStack {
                if uploadFileState == .notStarted {
                    Button(action: { showFileSourcePicker = true }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    Button(action: { showFileSourcePicker = true }) {
                        Image(systemName: "plus")
                    }
                }
            })
            .confirmationDialog("Are you sure you want to delete all the downloaded files?", isPresented: $isDeleteAllDownloadedFilesConfirmationDialogVisible, titleVisibility: .visible) {
                Button("Yes", role: .destructive) {
                    clearAllFiles()
                }
                Button("No", role: .cancel) { }
            }
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
