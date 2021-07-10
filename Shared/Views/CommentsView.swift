//
//  CommentsView.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/8/21.
//

import SwiftUI

struct CommentsView: View {
    var memory: Memory
    
    var body: some View {
        Text(memory.title)
    }
}

struct CommentsView_Previews: PreviewProvider {
    static var previews: some View {
        CommentsView(memory: Memory.sample)
    }
}
