//
//  AddTagView.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/18/21.
//

import SwiftUI
import ActivityIndicatorView

struct AddTagView: View {
    @Environment(\.presentationMode) var mode
    @EnvironmentObject var globalData: GlobalData
    @ObservedObject var viewModel: TagsViewModel
    @State var tagName = ""
    @State var tagColor = CGColor(red: 1, green: 216/255, blue: 0, alpha: 1)
    @State var showActivityIndicatorView = false
    @State var showingAddTagErrorAlert = false
    
    func addTagTapped() {
        async {
            do {
                main { showActivityIndicatorView = true }
                try await viewModel.addTag(name: tagName, color: tagColor, globalData: globalData)
                main {
                    showActivityIndicatorView = false
                    self.mode.wrappedValue.dismiss()
                    tagName = ""
                    tagColor = CGColor(red: 1, green: 216/255, blue: 0, alpha: 1)
                }
            } catch {
                showActivityIndicatorView = false
                showingAddTagErrorAlert = true
            }
        }
    }
    
    var body: some View {
        ZStack {
            Form {
                TextField("Tag name", text: $tagName)
                ColorPicker("Color", selection: $tagColor)
            }
            .navigationBarTitle(Text("Add Tag"))
            .navigationBarItems(trailing: Button(action: { addTagTapped() }, label: { Text("Add").bold() }))
            .alert("Error while adding tag. Please try again", isPresented: $showingAddTagErrorAlert) {
                Button("OK", role: .cancel) { }
            }
            
            ActivityIndicatorView(isVisible: $showActivityIndicatorView, type: .equalizer)
                .frame(width: 100.0, height: 100.0)
                .foregroundColor(.orange)
        }
    }
}

struct AddTagView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AddTagView(viewModel: .sample)
        }
    }
}
