//
//  MemoriesView.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/8/21.
//

import SwiftUI

struct MemoriesView: View {
    var body: some View {
        NavigationView {
            
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
        MemoriesView()
    }
}
