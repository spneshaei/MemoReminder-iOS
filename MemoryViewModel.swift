//
//  MemoryViewModel.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/16/21.
//

import SwiftUI

class MemoryViewModel: ObservableObject {
    var isSample = false // Not used! ...
    
    func upload(memory: Memory, image: UIImage, globalData: GlobalData) async throws -> String {
        guard !isSample else { return "" }
        let resultString = try await Rester.upload(endPoint: "post-file/?token=\(globalData.token)&post=\(memory.id)", body: "", data: image.pngData() ?? Data(), method: .post)
        return JSON(parseJSON: resultString)["file"].stringValue
    }
}
