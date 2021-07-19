//
//  AddMemoryView.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/17/21.
//

import SwiftUI
import ActivityIndicatorView

struct AddMemoryView: View {
    @EnvironmentObject var globalData: GlobalData
    @Environment(\.presentationMode) var mode
    @State var isTagViewOpeningLinkActive = false
    @State var isMentionViewOpeningLinkActive = false
    @Binding var memoryTitle: String
    @Binding var memoryContents: String
    @Binding var showActivityIndicator: Bool
    @ObservedObject var homeViewModel: HomeViewModel
    @ObservedObject var tagsViewModel: TagsViewModel
    @ObservedObject var viewModel: AddMemoryViewModel
    @State var showActivityIndicatorView = false
    @State var showingAddMemoryErrorAlert = false
    
    fileprivate func addMemoryTapped() {
        async {
            do {
                main { showActivityIndicatorView = true }
                try await homeViewModel.addMemory(title: memoryTitle, contents: memoryContents, tags: tagsViewModel.selectedTags, mentionedUsers: viewModel.mentionedUsers, globalData: globalData)
                main {
                    mode.wrappedValue.dismiss()
                    showActivityIndicatorView = false
                    memoryTitle = ""
                    memoryContents = "Enter memory details"
                }
            } catch {
                showActivityIndicatorView = false
                showingAddMemoryErrorAlert = true
            }
        }
    }
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                TextField("Memory Title", text: $memoryTitle)
                    .font(.title2)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextEditor(text: $memoryContents)
                
                Spacer()
                
//                Text(tagsViewModel.selectedTags.isEmpty ? "No tags selected" : (tagsViewModel.selectedTags.count == 1 ? "Selected Tag: \(tagsViewModel.selectedTags.first!.name)" : "Selected Tags: \(2)"))
//                    .padding()
                
                HStack {
                    Text(viewModel.mentionedUsers.count == 0 ? "No user is mentioned" : "\(viewModel.mentionedUsers.count) \(viewModel.mentionedUsers.count == 1 ? "user is" : "users are") mentioned")
                    Spacer()
                    NavigationLink(destination: SearchView(shouldSelectUsers: true, usersSelected: $viewModel.mentionedUsers), isActive: $isMentionViewOpeningLinkActive) {
                        Button(action: { isMentionViewOpeningLinkActive = true }) {
                            Label("Add", systemImage: "plus")
                        }
                    }
                }
                
                HStack {
                    Text("")
                }
                
                HStack {
                    Text(tagsViewModel.selectedTags.count == 0 ? "No tag is set" : "\(tagsViewModel.selectedTags.count) \(tagsViewModel.selectedTags.count == 1 ? "tag is" : "tags are") set")
                    Spacer()
                    NavigationLink(destination: TagsView(viewModel: tagsViewModel), isActive: $isTagViewOpeningLinkActive) {
                        Button(action: { isTagViewOpeningLinkActive = true }) {
                            Label("Add", systemImage: "plus")
                        }
                    }
                }
                
                HStack {
                    Text("")
                }
                
                
                ChipsContent(selectedTags: tagsViewModel.selectedTags) { id in
                    tagsViewModel.selectedTags.removeAll { $0.id == id }
                }
                
                
                
            }
            .alert("Error while adding memory. Please try again", isPresented: $showingAddMemoryErrorAlert) {
                Button("OK", role: .cancel) { }
            }
            .navigationBarTitle(Text("Add Memory"))
            .navigationBarItems(trailing: Button(action: { addMemoryTapped() }, label: { Text("Submit").bold() }))
            .padding()
            
            ActivityIndicatorView(isVisible: $showActivityIndicator, type: .equalizer)
                .frame(width: 100.0, height: 100.0)
                .foregroundColor(.orange)
        }
    }
}

struct AddMemoryView_Previews: PreviewProvider {
    static var previews: some View {
        let memory = Memory.sample
        return NavigationView {
            AddMemoryView(memoryTitle: .constant(memory.title), memoryContents: .constant(memory.contents), showActivityIndicator: .constant(false), homeViewModel: .sample, tagsViewModel: .sample, viewModel: .sample)
        }
        .preferredColorScheme(.dark)
    }
}
