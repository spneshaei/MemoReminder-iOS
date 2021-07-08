//
//  MemoriesView.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/8/21.
//

import SwiftUI

struct MemoriesView: View {
    @ObservedObject var viewModel: MemoriesViewModel
    
    var body: some View {
        NavigationView {
            List(viewModel.memories) { memory in
                NavigationLink(destination: MemoryView(memory: memory)) {
                    MemoryCell(memory: memory)
                }
            }
        }.navigationBarTitle("My Memories")
        .toolbar {
            Button(action: {
                // TODO: Add Memory page
            }) {
                Image(systemName: "plus.square")
            }
        }
    }
}

struct MemoriesView_Previews: PreviewProvider {
    static var previews: some View {
        MemoriesView(viewModel: MemoriesViewModel.sample)
    }
}
