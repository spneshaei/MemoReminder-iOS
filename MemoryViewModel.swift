//
//  MemoryViewModel.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/16/21.
//

import SwiftUI

class MemoryViewModel: ObservableObject {
    var isSample = false // Not used! ...
    
    func deleteMemory(memory: Memory, globalData: GlobalData) async throws {
        guard !isSample else { return }
        try await Rester.rest(endPoint: "post/\(memory.id)/?token=\(globalData.token)", body: "", method: .delete)
    }
    
    func likeMemory(memory: Memory, globalData: GlobalData) async throws {
        guard !isSample else { return }
        let body: JSON = [
            "post": memory.id
        ]
        guard let bodyString = body.rawString() else { return }
        try await Rester.rest(endPoint: "post-like/?token=\(globalData.token)", body: bodyString, method: .post)
    }
    
    func upload(memory: Memory, image: UIImage, globalData: GlobalData) async throws -> String {
        guard !isSample else { return "" }
        let resultString = try await Rester.upload(endPoint: "post-file/?token=\(globalData.token)&post=\(memory.id)", body: "", data: image.pngData() ?? Data(), method: .post)
        return JSON(parseJSON: resultString)["file"].stringValue
    }
    
    func editMemoryDetails(id: Int, contents: String, globalData: GlobalData) async throws {
        guard !isSample else { return }
        let body: JSON = [
            "text": contents
        ]
        guard let bodyString = body.rawString() else { return }
        try await Rester.rest(endPoint: "post/\(id)/?token=\(globalData.token)", body: bodyString, method: .patch)
    }
}
