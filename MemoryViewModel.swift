//
//  MemoryViewModel.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/16/21.
//

import SwiftUI

class MemoryViewModel: ObservableObject {
    var isSample = false // Not used! ...
    
    func likeMemory(memory: Memory, globalData: GlobalData) async throws {
        guard !isSample else { return }
        let body: JSON = [
            "post": memory.id
        ]
        guard let bodyString = body.rawString() else { return }
        try await Rester.rest(endPoint: "post-like/?token=\(globalData.token)", body: bodyString, method: .post)
    }
}
