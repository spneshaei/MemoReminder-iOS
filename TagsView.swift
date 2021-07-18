//
//  TagsVieq.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/18/21.
//

import SwiftUI

struct TagsView: View {
    @Environment(\.presentationMode) var mode
    @EnvironmentObject var globalData: GlobalData
    @ObservedObject var viewModel: TagsViewModel
    @State var showActivityIndicatorView = false
    @State var showingLoadingTagsErrorAlert = false
    
    fileprivate func reloadData() async {
        do {
            main { showActivityIndicatorView = true }
            try await viewModel.loadTags(globalData: globalData)
            main { showActivityIndicatorView = false }
        } catch {
            main {
                showActivityIndicatorView = false
                showingLoadingTagsErrorAlert = true
            }
        }
    }
    
    var body: some View {
        List(viewModel.unselectedTags) { tag in
            Chips(title: tag.name, hexColor: tag.color)
                .onTapGesture {
                    viewModel.selectedTags.append(tag)
                    self.mode.wrappedValue.dismiss()
                }
                .listRowSeparator(.hidden)
        }
        .task { async { await reloadData() }}
        .refreshable { async { await reloadData() }}
    }
}

struct TagsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TagsView(viewModel: .sample)
        }
    }
}
