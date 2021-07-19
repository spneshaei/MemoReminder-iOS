//
//  HomeView.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/8/21.
//

import SwiftUI
import BottomSheet
import ActivityIndicatorView

struct HomeView: View {
    @EnvironmentObject var quickActions: QuickActionService
    @ObservedObject var viewModel: HomeViewModel
    @ObservedObject var memoriesViewModel: MemoriesViewModel
    @StateObject var tagsViewModel = TagsViewModel()
    @StateObject var addMemoryViewModel = AddMemoryViewModel()
    @EnvironmentObject var globalData: GlobalData
    @State var isBottomSheetPresented = false
    @State var memoryTitle = ""
    @State private var memoryContents = "Enter memory details"
    @State var showActivityIndicatorView = false
    @State var showingLoadingMemoriesErrorAlert = false
    @State var shouldPresentMemorySheet = false
    @State var isSearchViewPresented = false
    @State var isDeepLinkToHottestMemoryActive = false
    
    fileprivate func reloadData() async {
        do {
            main { showActivityIndicatorView = true }
            try await viewModel.loadTopMemories(globalData: globalData)
            try await memoriesViewModel.loadMemories(globalData: globalData)
            main { showActivityIndicatorView = false }
        } catch (let error) {
            print("eErr")
            print(error.localizedDescription)
            main {
                showActivityIndicatorView = false
                showingLoadingMemoriesErrorAlert = true
            }
        }
    }
    
    var slideshowURLs: [String] {
        viewModel.topMemories
            .filter { !$0.imageLink.isEmpty }
            .map { $0.imageLink }
    }
    
    fileprivate func handleQuickAction() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if let action = quickActions.action, action == .search {
                quickActions.action = nil
                isSearchViewPresented = true
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                
                List {
//                    AsyncSlideshow(imageURLs: slideshowURLs)
//                        .frame(height: 120)
//                        .listRowSeparator(.hidden)
                    HomeTopView(imageURLStrings: slideshowURLs)
                        .frame(height: 120)
                        .listRowSeparator(.hidden)
                    
                    if !memoriesViewModel.aYearAgoMemories.isEmpty {
                        Text("A year ago, these days!")
                            .font(.title2)
                            .fontWeight(.bold)
                            .listRowSeparator(.hidden)
                        
                        MemoryListInHomeView(memories: memoriesViewModel.aYearAgoMemories)
                    }
                    
                    Text("Explore top memories")
                        .font(.title2)
                        .fontWeight(.bold)
                        .listRowSeparator(.hidden)
                    
                    MemoryListInHomeView(memories: viewModel.topMemories)
                }
                .listStyle(PlainListStyle())
//                .sheet(isPresented: $shouldPresentMemorySheet) {
//                    MemoryView(memory: memoryToShowInMemorySheet, imageLink: memoryToShowInMemorySheet.imageLink, numberOfLikes: memoryToShowInMemorySheet.numberOfLikes, hasCurrentUserLiked: memoryToShowInMemorySheet.hasCurrentUserLiked)
//                }
                //                .alert("Error while loading top memories. Please pull to refresh to try again", isPresented: $showingLoadingMemoriesErrorAlert) {
                //                    Button("OK", role: .cancel) { }
                //                }
                .task { await reloadData() }
                .refreshable { await reloadData() }
                
            }
//            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
//                handleQuickAction()
//            }
//            .onAppear(perform: handleQuickAction)
            .navigationBarTitle("Home")
            .navigationBarItems(trailing: HStack(spacing: 20) {
                NavigationLink(destination: SearchView(), isActive: $isSearchViewPresented) {
                    Button(action: { isSearchViewPresented = true }) { Image(systemName: "magnifyingglass") }
                }
                
                NavigationLink(destination: AddMemoryView(memoryTitle: $memoryTitle, memoryContents: $memoryContents, showActivityIndicator: $showActivityIndicatorView, homeViewModel: viewModel, tagsViewModel: tagsViewModel, viewModel: addMemoryViewModel)) {
                    Image(systemName: "plus.square")
                }
                //                Button(action: {
                //                    isBottomSheetPresented = true
                //                }) {
                //                    Image(systemName: "plus.square")
                //                }
            })
            .bottomSheet(isPresented: $isBottomSheetPresented, height: 640) {
                AddMemoryView(memoryTitle: $memoryTitle, memoryContents: $memoryContents, showActivityIndicator: $showActivityIndicatorView, homeViewModel: viewModel, tagsViewModel: tagsViewModel, viewModel: addMemoryViewModel)
            }
            
            if let memory = viewModel.topMemories.first {
                NavigationLink(destination: MemoryView(memory: memory, imageLink: memory.imageLink, numberOfLikes: memory.numberOfLikes, hasCurrentUserLiked: memory.hasCurrentUserLiked), isActive: $isDeepLinkToHottestMemoryActive) {
                    EmptyView()
                }.buttonStyle(PlainButtonStyle())
            }
        }
        .onOpenURL { url in
            if url.absoluteString.hasSuffix("open-most-top") {
                isDeepLinkToHottestMemoryActive = true
            }
        }
    }
}

struct AddMemoryButton: ButtonStyle {
    // https://github.com/LucasMucGH/BottomSheet
    
    let colors: [Color]
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .background(LinearGradient(gradient: Gradient(colors: self.colors), startPoint: .topLeading, endPoint: .bottomTrailing))
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(viewModel: HomeViewModel.sample, memoriesViewModel: .sample)
            .environmentObject(GlobalData.sample)
            .environmentObject(QuickActionService())
    }
}

struct MemoryListInHomeView: View {
    @State var memories: [Memory]
    
    var body: some View {
        ForEach(memories) { memory in
            ZStack {
                MemoryCell(memory: memory, shouldShowProfilePicture: false)
                    .listRowSeparator(.hidden)
                NavigationLink(destination: MemoryView(memory: memory, imageLink: memory.imageLink, numberOfLikes: memory.numberOfLikes, hasCurrentUserLiked: memory.hasCurrentUserLiked)) {
                    EmptyView()
                }.buttonStyle(PlainButtonStyle())
            }
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        }
    }
}
