//
//  TagsVieq.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/18/21.
//

import SwiftUI
import ActivityIndicatorView

struct TagsView: View {
    @Environment(\.presentationMode) var mode
    @EnvironmentObject var globalData: GlobalData
    @ObservedObject var viewModel: TagsViewModel
    @State var showActivityIndicatorView = false
    @State var showingLoadingTagsErrorAlert = false
    @State var isAddTagViewOpeningLinkActive = false
    
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
        ZStack {
            VStack {
                List {
                    Text("Tap on a tag chip to select it")
                    ForEach(viewModel.unselectedTags) { tag in
                        HStack {
                            Chips(title: tag.name, hexColor: tag.color, onTap: {
                                viewModel.selectedTags.append(tag)
                                self.mode.wrappedValue.dismiss()
                            })
                            .listRowSeparator(.hidden)
                            .padding(2)
                        }
                    }
                }
                .task { async { await reloadData() }}
                .refreshable { async { await reloadData() }}
            }
            .navigationBarTitle("Select a tag")
            .navigationBarItems(trailing: NavigationLink(destination: AddTagView(viewModel: viewModel), isActive: $isAddTagViewOpeningLinkActive) {
                Button(action: {
                    isAddTagViewOpeningLinkActive = true
                }, label: {
                    Image(systemName: "plus")
                        .padding(.horizontal)
                })
//                    .buttonStyle(AddMemoryButton(colors: [Color(red: 0.22, green: 0.22, blue: 0.70), Color(red: 0.32, green: 0.32, blue: 1)])).clipShape(Capsule())
//                    .scaleEffect(0.84)
            })
            
            ActivityIndicatorView(isVisible: $showActivityIndicatorView, type: .equalizer)
                .frame(width: 100.0, height: 100.0)
                .foregroundColor(.orange)
        }
    }
}

struct TagsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TagsView(viewModel: .sample)
                .environmentObject(GlobalData.sample)
        }
    }
}
