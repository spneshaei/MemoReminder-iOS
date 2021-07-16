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
    @State var shouldPresentMemorySheet = false
    @State var memoryToShowInMemorySheet = Memory.sample
    
    fileprivate func reloadData() async {
        do {
            main { showActivityIndicatorView = true }
            try await viewModel.loadMemories(globalData: globalData)
            main { showActivityIndicatorView = false }
        } catch {
            main {
                showingLoadingMemoriesErrorAlert = true
                showActivityIndicatorView = false
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                List(viewModel.memories) { memory in
                    MemoryCell(memory: memory)
                        .listRowSeparator(.hidden)
                        .onTapGesture {
                            memoryToShowInMemorySheet = memory
                            shouldPresentMemorySheet = true
                        }
                }
                .listStyle(PlainListStyle())
                .searchable(text: $viewModel.searchPredicate)
                .task { await reloadData() }
                .refreshable { await reloadData() }
                .alert("An error has occurred when trying to load memories. Please pull to refresh again.", isPresented: $showingLoadingMemoriesErrorAlert) {
                    Button("OK", role: .cancel) { }
                }
                .sheet(isPresented: $shouldPresentMemorySheet) {
                    MemoryView(memory: memoryToShowInMemorySheet)
                }
                
                ActivityIndicatorView(isVisible: $showActivityIndicatorView, type: .equalizer)
                    .frame(width: 100.0, height: 100.0)
                    .foregroundColor(.orange)
            }.navigationBarTitle("Memories")
        }
    }
}

struct MemoriesView_Previews: PreviewProvider {
    static var previews: some View {
        MemoriesView(viewModel: MemoriesViewModel.sample)
            .environmentObject(GlobalData.sample)
    }
}
