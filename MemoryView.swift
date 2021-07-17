//
//  MemoryView.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/8/21.
//

import SwiftUI
import ActivityIndicatorView
import MapKit
import URLImage
import ImagePickerView

struct MemoryView: View {
    @EnvironmentObject var globalData: GlobalData
    
    @StateObject var viewModel = MemoryViewModel()
    
    @State var memory: Memory
    @State var imageLink: String
    @State var numberOfLikes: Int
    @State var hasCurrentUserLiked: Bool
    @State var showActivityIndicatorView = false
    @State var showingLikeErrorAlert = false
    @State var showingUploadErrorAlert = false
    
    @State var showImagePicker: Bool = false
    @State var image: UIImage?
    
    enum UploadImageState {
        case notStarted, waitingToTapUpload, uploading
    }
    
    @State var uploadImageState: UploadImageState = .notStarted
    
    func uploadPhoto() async {
        do {
            main {
                showActivityIndicatorView = true
                uploadImageState = .uploading
            }
            let imageURL = try await viewModel.upload(memory: memory, image: image ?? UIImage(), globalData: globalData)
            main {
                memory.imageLink = imageURL
                imageLink = imageURL
                image = nil
                uploadImageState = .notStarted
                showActivityIndicatorView = false
            }
        } catch {
            main {
                image = nil
                uploadImageState = .notStarted
                showActivityIndicatorView = false
                showingUploadErrorAlert = true
            }
        }
    }
    
    func likeMemory() async {
        do {
            main { showActivityIndicatorView = true }
            try await viewModel.likeMemory(memory: memory, globalData: globalData)
            main {
                memory.numberOfLikes += 1
                numberOfLikes += 1
                memory.hasCurrentUserLiked = true
                hasCurrentUserLiked = true
                showActivityIndicatorView = false
            }
        } catch {
            main {
                showActivityIndicatorView = false
                showingLikeErrorAlert = true
            }
        }
    }
    
    var body: some View {
        ZStack {
            List {
                if !memory.imageLink.isEmpty && uploadImageState == .notStarted {
                    URLImage(URL(string: memory.imageLink)!) { urlImage in
                        urlImage.resizable()
                    }
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 200)
                    .listRowSeparator(.hidden)
                }
                if (uploadImageState == .waitingToTapUpload || uploadImageState == .uploading) {
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .listRowSeparator(.hidden)
                    }
                }
                VStack(alignment: .leading, spacing: 5) {
                    Text("Description").font(.caption)
                    Text(memory.contents)
                }
                Text("Created on \(memory.createdDate)")
                    .listRowSeparator(.hidden)
                Text("\(numberOfLikes) likes and \(memory.comments.count) comments")
                    .listRowSeparator(.hidden)
                NavigationLink(destination: CommentsView(memory: memory)) {
                    Text("Show comments")
                }
//                LocationRow(memory: memory)
//                NavigationLink(destination: MemoryMapView(latitude: memory.latitude, longitude: memory.longitude)) {
//                    Text("Show on the map")
//                }
            }
            .alert("Error in liking the memory. Please try again", isPresented: $showingLikeErrorAlert) {
                Button("OK", role: .cancel) { }
            }
            .alert("Error in uploading the image. Please try again", isPresented: $showingUploadErrorAlert) {
                Button("OK", role: .cancel) { }
            }
            .navigationBarTitle(Text(memory.title))
            .navigationBarItems(trailing: HStack(spacing: 15) {
//                Button(action: {
//                    // delete memory (and show only when needed!)
//                }) {
//                    Image(systemName: "trash")
//                        .foregroundColor(.red)
//                }
                
//                Button(action: {
//                    withAnimation {
//                        // edit memory (and show only when needed!)
//                    }
//                }) {
//                    Image(systemName: "square.and.pencil")
//                }
                if imageLink.isEmpty && memory.creatorUserID == globalData.userID && uploadImageState != .uploading {
                    Button(action: {
                        if uploadImageState == .waitingToTapUpload {
                            async { await uploadPhoto() }
                        } else {
                            showImagePicker = true
                            uploadImageState = .waitingToTapUpload
                        }
                    }) {
                        uploadImageState == .waitingToTapUpload ? Text("Upload").bold().erasedToAnyView() : Image(systemName: "arrow.up.circle").erasedToAnyView()
                    }
                    .sheet(isPresented: $showImagePicker) {
                        ImagePickerView(sourceType: .photoLibrary) { image in
                            self.image = image
                        }
                    }
                }
                
                Button(action: {
                    async { await likeMemory() }
                }) {
                    Image(systemName: hasCurrentUserLiked ? "heart.fill" : "heart")
                }
            })
            
            ActivityIndicatorView(isVisible: $showActivityIndicatorView, type: .equalizer)
                .frame(width: 100.0, height: 100.0)
                .foregroundColor(.orange)
        }
    }
}

struct MemoryMapView: View {
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    
    init(latitude: Double, longitude: Double) {
        region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    }
    
    var body: some View {
        Map(coordinateRegion: $region)
            .edgesIgnoringSafeArea(.all)
    }
}

struct LocationRow: View {
    var memory: Memory
    
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: "location")
            Text("Lat: \(memory.latitude) - Lon: \(memory.longitude)")
        }
    }
}

struct MemoryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MemoryView(memory: Memory.sample, imageLink: Memory.sample.imageLink, numberOfLikes: Memory.sample.numberOfLikes, hasCurrentUserLiked: Memory.sample.hasCurrentUserLiked)
        }
    }
}
