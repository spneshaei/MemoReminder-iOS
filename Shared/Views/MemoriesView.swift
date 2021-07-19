//
//  MemoriesView.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/8/21.
//

import SwiftUI
import ActivityIndicatorView

struct MemoriesView: View {
    @EnvironmentObject var globalData: GlobalData
    @ObservedObject var viewModel: MemoriesViewModel
    @State var showActivityIndicatorView = false
    @State var showingLoadingMemoriesErrorAlert = false
    @State var isNavigationLinkToFilterActive = false
    
    fileprivate func reloadData() async {
        do {
            main { showActivityIndicatorView = true }
            try await viewModel.loadMemories(globalData: globalData)
            main { showActivityIndicatorView = false }
        } catch {
            main {
                showActivityIndicatorView = false
                showingLoadingMemoriesErrorAlert = true
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                List(viewModel.filteredMemories(globalData: globalData)) { memory in
                    ZStack {
                        MemoryCell(memory: memory, shouldShowProfilePicture: false)
                            .listRowSeparator(.hidden)
                        NavigationLink(destination: MemoryView(memory: memory, imageLink: memory.imageLink, numberOfLikes: memory.numberOfLikes, hasCurrentUserLiked: memory.hasCurrentUserLiked)) {
                            EmptyView()
                        }.buttonStyle(PlainButtonStyle())
                            .listRowSeparator(.hidden)
                    }
                    .listRowSeparator(.hidden)
                }
                .listStyle(PlainListStyle())
                .searchable(text: $viewModel.searchPredicate)
                .task { await reloadData() }
                .refreshable { await reloadData() }
                .alert("An error has occurred when trying to load memories. Please pull to refresh again.", isPresented: $showingLoadingMemoriesErrorAlert) {
                    Button("OK", role: .cancel) { }
                }
                .navigationBarTitle("Memories Feed")
                //                .sheet(isPresented: $shouldPresentMemorySheet) {
                //                    MemoryView(memory: memoryToShowInMemorySheet)
                //                }
                
                ActivityIndicatorView(isVisible: $showActivityIndicatorView, type: .equalizer)
                    .frame(width: 100.0, height: 100.0)
                    .foregroundColor(.orange)
            }
            .navigationBarItems(trailing: NavigationLink(destination: FilterView(memoriesViewModel: viewModel), isActive: $isNavigationLinkToFilterActive) {
                Button(action: {
                    isNavigationLinkToFilterActive = true
                }) { Image(systemName: viewModel.hasFilter ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle") }
            })
        }
    }
}

struct MemoriesView_Previews: PreviewProvider {
    static var previews: some View {
        MemoriesView(viewModel: MemoriesViewModel.sample)
            .environmentObject(GlobalData.sample)
    }
}
