//
//  MemoryCell.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/8/21.
//

import SwiftUI

struct MemoryCell: View {
    var memory: Memory
    
    var body: some View {
        HStack() {
            // TODO: These URLs are only the ending part and not complete
            if #available(iOS 15.0, *) {
                if !memory.creatorProfilePictureURL.isEmpty {
                    AsyncImage(url: URL(string: memory.creatorProfilePictureURL)!)
                }
            } else {
                // Fallback on earlier versions
            }
            VStack(alignment: .leading, spacing: 5) {
                Text(memory.title)
                    .font(.title2)
                Text("\(memory.creatorUsername) - \(memory.createdDate)")
                    .font(.body)
            }.padding()
            Spacer()
        }.padding()
    }
}

struct MemoryCell_Previews: PreviewProvider {
    static var previews: some View {
        MemoryCell(memory: Memory.sample)
    }
}
