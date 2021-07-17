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
    @ObservedObject var viewModel: HomeViewModel
    @EnvironmentObject var globalData: GlobalData
    @State var isBottomSheetPresented = false
    @State var memoryTitle = ""
    @State private var memoryContents = "Enter memory details"
    @State var showActivityIndicatorView = false
    @State var showingAddMemoryErrorAlert = false
    @State var showingLoadingMemoriesErrorAlert = false
    @State var showingAddMemorySuccessAlert = false
    @State var shouldPresentMemorySheet = false
    @State var memoryToShowInMemorySheet = Memory.sample
    
    fileprivate func reloadData() async {
        do {
            main { showActivityIndicatorView = true }
            try await viewModel.loadTopMemories(globalData: globalData)
            main { showActivityIndicatorView = false }
        } catch {
            main {
                showActivityIndicatorView = false
                showingLoadingMemoriesErrorAlert = true
            }
        }
    }
    
    var slideshowURLs: [String] {
        viewModel.friendsMemories
            .filter { !$0.imageLink.isEmpty }
            .map { $0.imageLink }
    }
    
    fileprivate func addMemoryTapped() {
        async {
            do {
                main { showActivityIndicatorView = true }
                try await viewModel.addMemory(title: memoryTitle, contents: memoryContents, globalData: globalData)
                main {
                    showActivityIndicatorView = false
                    showingAddMemorySuccessAlert = true
                    isBottomSheetPresented = false
                    memoryTitle = ""
                    memoryContents = "Enter memory details"
                }
            } catch {
                showActivityIndicatorView = false
                showingAddMemoryErrorAlert = true
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    AsyncSlideshow(imageURLs: slideshowURLs)
                        .frame(height: 120)
                        .listRowSeparator(.hidden)
                    
                    Text("Explore top memories")
                        .font(.title2)
                        .fontWeight(.bold)
                        .listRowSeparator(.hidden)
                    
                    ForEach(viewModel.topMemories) { memory in
                        MemoryCell(memory: memory)
                            .listRowSeparator(.hidden)
                            .onTapGesture {
                                memoryToShowInMemorySheet = memory
                                shouldPresentMemorySheet = true
                            }
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
                .listStyle(PlainListStyle())
                .sheet(isPresented: $shouldPresentMemorySheet) {
                    MemoryView(memory: memoryToShowInMemorySheet, numberOfLikes: memoryToShowInMemorySheet.numberOfLikes, hasCurrentUserLiked: memoryToShowInMemorySheet.hasCurrentUserLiked)
                }
                .alert("Error while adding memory. Please try again", isPresented: $showingAddMemoryErrorAlert) {
                    Button("OK", role: .cancel) { }
                }
                .alert("Error while loading top memories. Please pull to refresh to try again", isPresented: $showingLoadingMemoriesErrorAlert) {
                    Button("OK", role: .cancel) { }
                }
                .task { await reloadData() }
                .refreshable { await reloadData() }
                
            }
            .navigationBarTitle("Home")
            .navigationBarItems(trailing: HStack(spacing: 20) {
                NavigationLink(destination: SearchView()) {
                    Image(systemName: "magnifyingglass")
                }
                Button(action: {
                    isBottomSheetPresented = true
                }) {
                    Image(systemName: "plus.square")
                }
            })
            .bottomSheet(isPresented: $isBottomSheetPresented, height: 640) { // TODO: Not very good with keyboard!
                ScrollView {
                    ZStack {
                        VStack(alignment: .leading) {
                            Text("Add memory").font(.title).bold()
                            TextField("Memory Title", text: $memoryTitle).font(.title)
                            TextEditor(text: $memoryContents)
                            
                            Spacer()
                            
                            Button(action: {
                                addMemoryTapped()
                            }, label: {
                                Text("Add Memory")
                                    .padding(.horizontal)
                            })
                                .buttonStyle(AddMemoryButton(colors: [Color(red: 0.70, green: 0.22, blue: 0.22), Color(red: 1, green: 0.32, blue: 0.32)])).clipShape(Capsule())
                        }.padding()
                        ActivityIndicatorView(isVisible: $showActivityIndicatorView, type: .equalizer)
                            .frame(width: 100.0, height: 100.0)
                            .foregroundColor(.orange)
                    }
                }
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
        HomeView(viewModel: HomeViewModel.sample)
            .environmentObject(GlobalData.sample)
    }
}
