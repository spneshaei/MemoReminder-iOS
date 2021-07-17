//
//  MemoryView.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/8/21.
//

import SwiftUI
import ActivityIndicatorView
import MapKit

// TODO: Only owner should be able to delete memories
// TODO: Do we have delete memory??
// TODO: Created date in memory page!

struct MemoryView: View {
    @EnvironmentObject var globalData: GlobalData
    
    @StateObject var viewModel = MemoryViewModel()
    
    @State var memory: Memory
    @State var numberOfLikes: Int
    @State var hasCurrentUserLiked: Bool
    @State var showActivityIndicatorView = false
    @State var showingLikeErrorAlert = false
    
    func likeMemory() async {
        do {
            main { showActivityIndicatorView = true }
            try await viewModel.likeMemory(memory: memory, globalData: globalData)
            main {
                memory.numberOfLikes += 1
                numberOfLikes += 1
                memory.hasCurrentUserLiked = true // TODO: Toggle? (before adding unlike, not needed)
                hasCurrentUserLiked = true // TODO: Toggle? (before adding unlike, not needed)
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
                if !memory.imageLink.isEmpty {
                    AsyncImage(url: URL(string: memory.imageLink)!)
                        .frame(maxHeight: 200)
                        .listRowSeparator(.hidden)
                        .onTapGesture(count: 2) {
                            async { await likeMemory() }
                        }
                }
                VStack(alignment: .leading, spacing: 5) {
                    Text("Description").font(.caption)
                    Text(memory.contents)
                }
                Text("\(numberOfLikes) likes and \(memory.comments.count) comments")
                    .listRowSeparator(.hidden)
                NavigationLink(destination: CommentsView(memory: memory)) {
                    Text("Show comments")
                }
                // TODO: Not lat/lon! Real loc!
                LocationRow(memory: memory)
                NavigationLink(destination: MemoryMapView(latitude: memory.latitude, longitude: memory.longitude)) {
                    Text("Show on the map")
                    // TODO: Map doesn't work???
                }
                
                
            }
            .alert("Error in liking the memory. Please try again", isPresented: $showingLikeErrorAlert) {
                Button("OK", role: .cancel) { }
            }
            .navigationBarTitle(Text(memory.title))
            .navigationBarItems(trailing: HStack(spacing: 15) {
                Button(action: {
                    // TODO: delete memory (and show only when needed!)
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                Button(action: {
                    withAnimation {
                        // TODO: edit memory (and show only when needed!)
                    }
                }) {
                    Image(systemName: "square.and.pencil")
                }
                Button(action: {
                    // TODO: We don't have unlike!!
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

// TODO: Date for everything (comments, memories, ...) in the system!

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
        MemoryView(memory: Memory.sample, numberOfLikes: Memory.sample.numberOfLikes, hasCurrentUserLiked: Memory.sample.hasCurrentUserLiked)
    }
}
