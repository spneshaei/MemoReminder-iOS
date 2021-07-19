//
//  ViewHottestMemoriesIntentHandler.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/19/21.
//

// https://andrewgraham.dev/demystifying-siri-part-5-intents-extensions/

import Foundation

class ViewHottestMemoriesIntentHandler: NSObject, ViewHottestMemoriesIntentHandling {
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    func handle(intent: ViewHottestMemoriesIntent, completion: @escaping (ViewHottestMemoriesIntentResponse) -> Void) {
        var arrayOfMemoryDescriptions: [String] = []
        if let defaults = UserDefaults(suiteName: "group.com.spneshaei.MemoReminder"), let topMemories = try? decoder.decode([Memory].self, from: defaults.data(forKey: "HomeViewModel_topMemories") ?? Data()) {
            for i in 0..<5 {
                if topMemories.count > i {
                    let memory = topMemories[i]
                    arrayOfMemoryDescriptions.append("\(memory.title) by \(memory.creatorFirstName)")
                }
            }
            completion(ViewHottestMemoriesIntentResponse.success(spokenResult: "The hottest memories: " + arrayOfMemoryDescriptions.joined(separator: ", ")))
        }
    }
    
    
}
