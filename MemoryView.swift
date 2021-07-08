//
//  MemoryView.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/8/21.
//

import SwiftUI

struct MemoryView: View {
    var memory: Memory
    
    var body: some View {
        Text(memory.title)
    }
}

struct MemoryView_Previews: PreviewProvider {
    static var previews: some View {
        MemoryView(memory: Memory.sample)
    }
}
