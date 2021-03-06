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
import SwiftLocation

struct MemoryView: View {
    @Environment(\.presentationMode) var mode
    @EnvironmentObject var globalData: GlobalData
    
    @StateObject var viewModel = MemoryViewModel()
    
    @State var memory: Memory
    @State var imageLink: String
    @State var numberOfLikes: Int
    @State var hasCurrentUserLiked: Bool
    @State var showActivityIndicatorView = false
    @State var showingLikeErrorAlert = false
    @State var showingUploadErrorAlert = false
    @State var shouldEditMemoryErrorAlert = false
    @State var showChooseMapConfirmationDialog = false
    
    @State var showImagePicker = false
    @State var showImageSourcePicker = false
    @State var imageSourceSelection: UIImagePickerController.SourceType = .photoLibrary
    @State var image: UIImage?
    @State var editMode = false
    @State var showDeleteMemoryConfirmationAlert = false
    @State var showDeleteMemoryErrorAlert = false
    @State var isLoadingLocation = false
    @State var shouldShowLocationAccessDeniedAlert = false
    
    enum UploadImageState {
        case notStarted, waitingToTapUpload, uploading
    }
    
    @State var uploadImageState: UploadImageState = .notStarted
    
    @State var cityCountryName = "Loading location details..."
    
    func uploadPhoto() {
        let concurrentQueue = DispatchQueue(label: "MemoReminderUploadPhoto", attributes: .concurrent)
        concurrentQueue.async {
            main {
                showActivityIndicatorView = true
                uploadImageState = .uploading
            }
            viewModel.upload(memory: memory, image: image ?? UIImage(), globalData: globalData) { r in
                if let resultString = r {
                    let result = JSON(parseJSON: resultString)
                    let imageURL = result["file"].stringValue
                    main {
                        memory.imageLink = imageURL
                        imageLink = imageURL
                        image = nil
                        uploadImageState = .notStarted
                        showActivityIndicatorView = false
                    }
                } else {
                    main {
                        image = nil
                        uploadImageState = .notStarted
                        showActivityIndicatorView = false
                        showingUploadErrorAlert = true
                    }
                }
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
    
    fileprivate func doneTapped() async {
        do {
            main { showActivityIndicatorView = true }
            try await viewModel.editMemoryDetails(id: memory.id, contents: memory.contents, latitude: memory.latitude, longitude: memory.longitude, privacyStatus: memory.privacyStatus, globalData: globalData)
            main {
                showActivityIndicatorView = false
                withAnimation { editMode = false }
            }
        } catch {
            main {
                showActivityIndicatorView = false
                shouldEditMemoryErrorAlert = true
            }
        }
    }
    
    fileprivate func deleteMemory() async {
        main { showActivityIndicatorView = true }
        do {
            try await viewModel.deleteMemory(memory: memory, globalData: globalData)
            main {
                showActivityIndicatorView = false
                self.mode.wrappedValue.dismiss()
            }
        } catch {
            main {
                showActivityIndicatorView = false
                showDeleteMemoryErrorAlert = true
            }
        }
        
    }
    
    // https://medium.com/swift-productions/launch-google-to-show-route-swift-580aca80cf88
    func showAppleMaps() {
        let coordinate = CLLocationCoordinate2DMake(memory.latitude, memory.longitude)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary: nil))
        mapItem.name = memory.title
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
    
    // https://medium.com/swift-productions/launch-google-to-show-route-swift-580aca80cf88
    func showGoogleMaps() {
        if let url = URL(string: "comgooglemaps://?daddr=\(memory.latitude),\(memory.longitude))&directionsmode=driving&zoom=14&views=traffic") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func setMemoryLocationDataToCurrentLocation() {
        guard SwiftLocation.authorizationStatus != .denied else {
            shouldShowLocationAccessDeniedAlert = true
            return
        }
        isLoadingLocation = true
        SwiftLocation.gpsLocation().then {
            memory.latitude = $0.location?.coordinate.latitude ?? 0.0
            memory.longitude = $0.location?.coordinate.longitude ?? 0.0
            isLoadingLocation = false
        }
    }
    
    fileprivate func fetchLocationName() {
        CLLocation(latitude: memory.latitude, longitude: memory.longitude).fetchCityAndCountry { city, country, error in
            guard let city = city, let country = country, error == nil else { return }
            main { cityCountryName = city + ", " + country }
        }
    }
    
    var body: some View {
        let latitudeBinding = Binding<String>(get: { String(memory.latitude) }, set: {
            memory.latitude = Double($0) ?? 0.0
            fetchLocationName()
        })
        let longitudeBinding = Binding<String>(get: { String(memory.longitude) }, set: {
            memory.longitude = Double($0) ?? 0.0
            fetchLocationName()
        })
        let followingsOnlyBinding = Binding<Bool>(get: { memory.privacyStatus == .privateStatus }, set: { memory.privacyStatus = $0 ? .privateStatus : .publicStatus })
        
        return ZStack {
            List {
                if !memory.imageLink.isEmpty && uploadImageState == .notStarted {
                    Group {
                        HStack {
                            Spacer()
                                .alert("Error in editing the memory. Please try again", isPresented: $shouldEditMemoryErrorAlert) {
                                    Button("OK", role: .cancel) { }
                                }
                            AsyncImage(url: URL(string: memory.imageLink)) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                Color.purple.opacity(0)
                            }
                            .frame(maxHeight: 200)
                            Spacer()
                        }
                        .frame(maxHeight: 200)
                        Text("").listRowSeparator(.hidden)
                    }
                }
                if (uploadImageState == .waitingToTapUpload || uploadImageState == .uploading) {
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .listRowSeparator(.hidden)
                        Text("").listRowSeparator(.hidden)
                    }
                }
                VStack(alignment: .leading, spacing: 5) {
                    if editMode {
                        TextField("Enter memory description", text: $memory.contents)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    } else {
                        Text("Description").font(.caption)
                        Text(memory.contents)
                    }
                }
                if let date = memory.createdDate.components(separatedBy: "T").first {
                    Text("Created on \(date)")
                        .listRowSeparator(.hidden)
                }
                Group {
                    NavigationLink(destination: UsersView(viewModel: UsersViewModel(predeterminedUsers: memory.usersMentioned))) {
                        Text(memory.usersMentioned.count == 0 ? "No user is mentioned" : "\(memory.usersMentioned.count) \(memory.usersMentioned.count == 1 ? "user is" : "users are") mentioned")
                    }
                    Text("**\(numberOfLikes)** likes and **\(memory.comments.count)** comments")
                        .listRowSeparator(.hidden)
                        .alert("Error in liking the memory. Please try again", isPresented: $showingLikeErrorAlert) {
                            Button("OK", role: .cancel) { }
                        }
                    NavigationLink(destination: CommentsView(memory: memory)) {
                        Text("Show comments")
                    }
                }
                
                NavigationLink(destination: AttachedFilesView(memory: memory, memoryViewModel: viewModel)) {
                    HStack {
                        Image(systemName: "paperclip")
                        Text("Attached Files")
                        Spacer()
                    }
                }
                
                if editMode {
                    HStack {
                        Text("Latitude:")
                            .listRowSeparator(.hidden)
                        TextField("Enter latitude", text: latitudeBinding)
                            .listRowSeparator(.hidden)
                    }
                    .listRowSeparator(.hidden)
                    HStack {
                        Text("Longitude:")
                            .listRowSeparator(.hidden)
                        TextField("Enter latitude", text: longitudeBinding)
                            .listRowSeparator(.hidden)
                    }
                    .listRowSeparator(.hidden)
                    Button(action: {
                        if !isLoadingLocation {
                            setMemoryLocationDataToCurrentLocation()
                        }
                    }) {
                        HStack {
                            if isLoadingLocation {
                                ActivityIndicatorView(isVisible: $isLoadingLocation, type: .default)
                                    .frame(width: 20, height: 20)
                            } else {
                                Image(systemName: "location.fill.viewfinder")
                                    .frame(width: 20, height: 20)
                            }
                            Text("Set to the current location")
                            Spacer()
                        }
                    }
                } else {
                    if memory.latitude != 0 || memory.longitude != 0 {
                        Group {
                            LocationRow(memory: memory)
                                .listRowSeparator(.hidden)
                            HStack(spacing: 5) {
                                Image(systemName: "location.fill")
                                Text(cityCountryName)
                            }
                            Button(action:
                                    { showChooseMapConfirmationDialog = true }) {
                                Text("Show on the map")
                            }
                                    .confirmationDialog("Select a map service", isPresented: $showChooseMapConfirmationDialog, titleVisibility: .visible) {
                                        Button("Apple Maps") { showAppleMaps() }
                                        Button("Google Maps") { showGoogleMaps() }
                                        Button("Cancel", role: .cancel) { }
                                    }
                        }
                    }
                }
                if editMode {
                    Toggle("Show the memory only for followings", isOn: followingsOnlyBinding)
                        .listRowSeparator(.hidden)
                    Text("When on, the memory will not be shown on the home tab's feed for other people.").font(.footnote)
                }
                ChipsContent(selectedTags: memory.tags) { _ in }
                .frame(minHeight: 150)
                .alert("Error in uploading the image. Please try again", isPresented: $showingUploadErrorAlert) {
                    Button("OK", role: .cancel) { }
                }
            }
            .alert("Error in deleting the memory. Please try again", isPresented: $showDeleteMemoryErrorAlert) {
                Button("OK", role: .cancel) { }
            }
            .navigationBarTitle(Text(memory.title))
            .navigationBarItems(leading: HStack {
                if editMode {
                    Button(action: {
                        withAnimation { editMode = false }
                    }) { Text("Cancel").bold() }
                }
            }, trailing: HStack(spacing: 15) {
                if memory.creatorUserID == globalData.userID && !showActivityIndicatorView {
                    Button(action: {
                        showDeleteMemoryConfirmationAlert = true
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .confirmationDialog("Are you sure you want to delete the \(memory.title) memory?", isPresented: $showDeleteMemoryConfirmationAlert, titleVisibility: .visible) {
                        Button("Yes", role: .destructive) {
                            async { await deleteMemory() }
                        }
                        Button("No", role: .cancel) { }
                    }
                }
                if imageLink.isEmpty && memory.creatorUserID == globalData.userID && uploadImageState != .uploading {
                    Button(action: {
                        if uploadImageState == .waitingToTapUpload {
                            uploadPhoto()
                        } else {
                            showImageSourcePicker = true
                            uploadImageState = .waitingToTapUpload
                        }
                    }) {
                        uploadImageState == .waitingToTapUpload ? Text("Upload").bold().erasedToAnyView() : Image(systemName: "arrow.up.circle").erasedToAnyView()
                    }
                    .confirmationDialog("Where do you want to select memory's photo from?", isPresented: $showImageSourcePicker, titleVisibility: .visible) {
                        Button("Camera") {
                            imageSourceSelection = .camera
                            showImagePicker = true
                        }
                        Button("Photo Library") {
                            imageSourceSelection = .photoLibrary
                            showImagePicker = true
                        }
                    }
                    .sheet(isPresented: $showImagePicker) {
                        ImagePickerView(sourceType: imageSourceSelection) { image in
                            self.image = image
                        }
                    }
                }
                
                Button(action: {
                    if !hasCurrentUserLiked {
                        async { await likeMemory() }
                    }
                }) {
                    Image(systemName: hasCurrentUserLiked ? "heart.fill" : "heart")
                }
                
                if memory.creatorUserID == globalData.userID {
                    Button(action: {
                        guard !showActivityIndicatorView else { return }
                        if editMode == false {
                            withAnimation {
                                editMode = true
                            }
                        } else {
                            async { await doneTapped() }
                        }
                    }) {
                        if editMode {
                            Text("Done")
                                .fontWeight(.bold)
                        } else {
                            Image(systemName: "square.and.pencil")
                        }
                    }
                }
            })
            
            ActivityIndicatorView(isVisible: $showActivityIndicatorView, type: .equalizer)
                .frame(width: 100.0, height: 100.0)
                .foregroundColor(.orange)
        }
        .alert("You've previously denied the app's access to your location. Please grant the app access to your location by opening the Settings app.", isPresented: $shouldShowLocationAccessDeniedAlert) {
            Button("OK", role: .cancel) {
                self.mode.wrappedValue.dismiss()
            }
        }
        .onAppear(perform: fetchLocationName)
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
                .environmentObject(GlobalData.sample)
        }
    }
}

extension CLLocation {
    func fetchCityAndCountry(completion: @escaping (_ city: String?, _ country:  String?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(self) { completion($0?.first?.locality, $0?.first?.country, $1) }
    }
}
