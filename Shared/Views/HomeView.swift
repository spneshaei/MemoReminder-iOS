//
//  HomeView.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/8/21.
//

import SwiftUI
import BottomSheet
import ActivityIndicatorView
import Intents

struct HomeView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @EnvironmentObject var quickActions: QuickActionService
    @ObservedObject var viewModel: HomeViewModel
    @ObservedObject var memoriesViewModel: MemoriesViewModel
    @StateObject var tagsViewModel = TagsViewModel()
    @StateObject var addMemoryViewModel = AddMemoryViewModel()
    @EnvironmentObject var globalData: GlobalData
    @State var memoryTitle = ""
    @State private var memoryContents = "Enter memory details"
    @State var showActivityIndicatorView = false
    @State var showingLoadingMemoriesErrorAlert = false
    @State var shouldPresentMemorySheet = false
    @State var isSearchViewPresented = false
    @State var isDeepLinkToHottestMemoryActive = false
    @State var currentTopSliderImageIndex = 0
    
    fileprivate func reloadData() async {
        do {
            main { showActivityIndicatorView = true }
            try await memoriesViewModel.loadMemories(globalData: globalData)
            try await viewModel.loadTopMemories(globalData: globalData)
            try await viewModel.loadMentionedMemories(globalData: globalData)
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
    
    var topMemoriesWithImages: [Memory] {
        viewModel.topMemories
            .filter { !$0.imageLink.isEmpty }
    }
    
    func topMemoriesWithImages(index: Int) -> Memory? {
        let topMemoriesWithImages = self.topMemoriesWithImages
        guard topMemoriesWithImages.count > index else { return nil }
        return topMemoriesWithImages[index]
    }
    
    var slideshowURLs: [String] {
        topMemoriesWithImages
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
    
    var slideshowURLObjects: [URL] {
        var result: [URL] = []
        for string in slideshowURLs {
            if let url = URL(string: string) {
                result.append(url)
            }
        }
        return result
    }
    
    func donateViewHottestMemoryShortcut() {
        let intent = ViewHottestMemoriesIntent()
        let interaction = INInteraction(intent: intent, response: nil)
        interaction.donate(completion: nil)
    }
    
    var body: some View {
        ZStack {
            
            List {
//                    AsyncSlideshow(imageURLs: slideshowURLs)
//                        .frame(height: 120)
//                        .listRowSeparator(.hidden)
                
//                    AsyncSlideshow(imageURLs: slideshowURLs)
//                        .frame(height: 120)
//                        .listRowSeparator(.hidden)
                
                if let topMemoryWithImage = topMemoriesWithImages(index: currentTopSliderImageIndex) {
                    NavigationLink(destination: MemoryView(memory: topMemoryWithImage, imageLink: topMemoryWithImage.imageLink, numberOfLikes: topMemoryWithImage.numberOfLikes, hasCurrentUserLiked: topMemoryWithImage.hasCurrentUserLiked)) {
                        AsyncImagesPagingView(imageURLs: slideshowURLObjects, index: $currentTopSliderImageIndex)
                    }
                }
                
                if !viewModel.nearReminders.isEmpty {
                    Group {
                        Text("Don't forget!")
                            .font(.title2)
                            .fontWeight(.bold)
                            .listRowSeparator(.hidden)
                        
                        ForEach(viewModel.nearReminders) { reminder in
                            NotificationReminderCell(reminder: reminder)
                                .listRowSeparator(.hidden)
                        }
                        .listRowSeparator(.hidden)
                    }
                }
                
                if !memoriesViewModel.aYearAgoMemories.isEmpty {
                    Group {
                        Text("A year ago, these days!")
                            .font(.title2)
                            .fontWeight(.bold)
                            .listRowSeparator(.hidden)
                        
                        MemoryListInHomeView(memories: memoriesViewModel.aYearAgoMemories)
                    }
                }
                
                if !viewModel.topMemories.isEmpty {
                    Group {
                        Text("Explore top memories")
                            .font(.title2)
                            .fontWeight(.bold)
                            .listRowSeparator(.hidden)
                        
                        MemoryListInHomeView(memories: viewModel.topMemories)
                    }
                }
                
                if !viewModel.mentionedMemories.isEmpty {
                    Text("You where mentioned in")
                        .font(.title2)
                        .fontWeight(.bold)
                        .listRowSeparator(.hidden)
                    
                    MemoryListInHomeView(memories: viewModel.mentionedMemories)
                }
                
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
            
            if let memory = viewModel.topMemories.first {
                NavigationLink(destination: MemoryView(memory: memory, imageLink: memory.imageLink, numberOfLikes: memory.numberOfLikes, hasCurrentUserLiked: memory.hasCurrentUserLiked), isActive: $isDeepLinkToHottestMemoryActive) {
                    EmptyView()
                }.buttonStyle(PlainButtonStyle())
            }
        }
//            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
//                handleQuickAction()
//            }
//            .onAppear(perform: handleQuickAction)
        .onAppear(perform: donateViewHottestMemoryShortcut)
        .navigationBarTitle("Home")
        .navigationBarItems(trailing: HStack(spacing: 20) {
            NavigationLink(destination: UsersView(), isActive: $isSearchViewPresented) {
                Button(action: { isSearchViewPresented = true }) { Image(systemName: "person.crop.circle.badge.plus") }
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
//        .bottomSheet(isPresented: $isBottomSheetPresented, height: 640) {
//            AddMemoryView(memoryTitle: $memoryTitle, memoryContents: $memoryContents, showActivityIndicator: $showActivityIndicatorView, homeViewModel: viewModel, tagsViewModel: tagsViewModel, viewModel: addMemoryViewModel)
//        }
        .onOpenURL { url in
            if url.absoluteString.hasSuffix("open-most-top") {
                isDeepLinkToHottestMemoryActive = true
            }
        }
//        .navigationViewStyle(.stack)
//        .if(horizontalSizeClass == .regular) { view in
//            view.navigationViewStyle(.columns)
//        }
        
    }
}

extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
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
    @Environment(\.colorScheme) var colorScheme
    var isDarkMode: Bool { colorScheme == .dark }
    
    @State var memories: [Memory]
    
    var body: some View {
        ForEach(memories) { memory in
            ZStack {
                MemoryCell(memory: memory, shouldShowProfilePicture: false)
                    .listRowSeparator(.hidden)
                NavigationLink(destination: MemoryView(memory: memory, imageLink: memory.imageLink, numberOfLikes: memory.numberOfLikes, hasCurrentUserLiked: memory.hasCurrentUserLiked)) {
                    EmptyView()
                }
                .buttonStyle(PlainButtonStyle())
            }
            .listRowBackground(isDarkMode ? Color.black : Color.white)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        }
    }
}
