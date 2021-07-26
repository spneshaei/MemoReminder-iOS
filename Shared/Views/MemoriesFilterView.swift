//
//  FilterView.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/19/21.
//

import SwiftUI

struct MemoriesFilterView: View {
    @ObservedObject var memoriesViewModel: MemoriesViewModel
    
    var body: some View {
        Form {
            Toggle("Filter based on date", isOn: $memoriesViewModel.isDateSelected)
            if memoriesViewModel.isDateSelected {
                DatePicker("Select date", selection: $memoriesViewModel.selectedDate, displayedComponents: .date)
            }
            Toggle("Show only my own memories", isOn: $memoriesViewModel.showOnlyMyOwnMemories)
        }
        .navigationBarTitle("Filter Memories")
    }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        MemoriesFilterView(memoriesViewModel: .sample)
    }
}
