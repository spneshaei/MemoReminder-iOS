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
                Image("login-5").edgesIgnoringSafeArea(.all)
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
                        }
                    }
                }
                
            }.navigationBarTitle("Home")
            .toolbar {
                Button(action: {
                    // TODO: Add Memory page
                }) {
                    Image(systemName: "plus.square")
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(viewModel: HomeViewModel.sample)
    }
}
