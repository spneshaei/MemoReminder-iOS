//
//  HomeView.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/8/21.
//

import SwiftUI

@available(iOS 15.0, *)
struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var slideshowURLs: [String] {
        viewModel.friendsMemories
            .filter { !$0.imageLink.isEmpty }
            .map { $0.imageLink }
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
                        NavigationLink(destination: MemoryView(memory: memory)) {
                            MemoryCell(memory: memory)
                                .listRowSeparator(.hidden)
                        }
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
                .listStyle(PlainListStyle())
                
            }.navigationBarTitle("Home")
                .navigationBarItems(trailing: HStack(spacing: 20) {
                    NavigationLink(destination: SearchView()) {
                        Image(systemName: "magnifyingglass")
                    }
                    Button(action: {
                        // TODO: Add Memory page
                    }) {
                        Image(systemName: "plus.square")
                    }
                    
                })
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(viewModel: HomeViewModel.sample)
    }
}
