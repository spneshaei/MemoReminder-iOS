//
//  MemoryView.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/8/21.
//

import SwiftUI

// TODO: Only owner should be able to delete memories

struct MemoryView: View {
    var memory: Memory
    
    func likeMemory() {
        
    }
    
    var body: some View {
        List {
            if !memory.imageLink.isEmpty {
                AsyncImage(url: URL(string: memory.imageLink)!)
                    .frame(maxHeight: 200)
                    .listRowSeparator(.hidden)
                    .onTapGesture(count: 2) {
                        likeMemory()
                    }
            }
            VStack(alignment: .leading, spacing: 5) {
                Text("Description").font(.caption)
                Text(memory.contents)
            }
            Text("\(memory.numberOfLikes) likes and \(memory.commentIDs.count) comments")
                .listRowSeparator(.hidden)
            NavigationLink(destination: CommentsView(memory: memory)) {
                Text("Show comments")
            }
            // TODO: Not lat/lon! Real loc!
            LocationRow(memory: memory)
            
            
        }.navigationBarTitle(Text(memory.title))
            .navigationBarItems(trailing: HStack(spacing: 15) {
                Button(action: {
                    // TODO
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                Button(action: {
                    withAnimation {
                        // TODO
                    }
                }) {
                    Image(systemName: "square.and.pencil")
                }
            })
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
            MemoryView(memory: Memory.sample)
        }
    }
}
