//
//  AttachedFilesView.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/20/21.
//

import SwiftUI

struct AttachedFilesView: View {
    @StateObject var viewModel = AttachedFilesViewModel()
    @ObservedObject var memoryViewModel: MemoryViewModel
    
    var body: some View {
        Text("Hello, World!")
    }
}

struct AttachedFilesView_Previews: PreviewProvider {
    static var previews: some View {
        AttachedFilesView(memoryViewModel: .sample)
    }
}
