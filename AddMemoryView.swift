//
//  AddMemoryView.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/17/21.
//

import SwiftUI
import ActivityIndicatorView

struct AddMemoryView: View {
    @State var isTagViewOpeningLinkActive = false
    @Binding var memoryTitle: String
    @Binding var memoryContents: String
    @Binding var showActivityIndicator: Bool
    var addMemoryTapped: () -> Void
    @ObservedObject var tagsViewModel: TagsViewModel
    
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
                
                NavigationLink(destination: TagsView(viewModel: tagsViewModel), isActive: $isTagViewOpeningLinkActive) {
                    Button(action: {
                        isTagViewOpeningLinkActive = true
                    }, label: {
                        Text("Add Tag")
                            .padding(.horizontal)
                    })
                        .buttonStyle(AddMemoryButton(colors: [Color(red: 0.22, green: 0.22, blue: 0.70), Color(red: 0.32, green: 0.32, blue: 1)])).clipShape(Capsule())
                        .scaleEffect(0.84)
                        
                }
                
                ScrollView {
                    ChipsContent(viewModel: tagsViewModel)
                }
                
                
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
            AddMemoryView(memoryTitle: .constant(memory.title), memoryContents: .constant(memory.contents), showActivityIndicator: .constant(false), addMemoryTapped: { }, tagsViewModel: .sample)
        }
        .preferredColorScheme(.dark)
    }
}
