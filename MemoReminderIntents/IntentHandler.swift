//
//  IntentHandler.swift
//  MemoReminderIntents
//
//  Created by Seyyed Parsa Neshaei on 7/19/21.
//

import Intents

class IntentHandler: INExtension {
    
    // https://andrewgraham.dev/demystifying-siri-part-5-intents-extensions/
    override func handler(for intent: INIntent) -> Any {
        guard intent is ViewHottestMemoriesIntent else {
            fatalError("Unhandled intent type: \(intent)")
        }
        
        return ViewHottestMemoriesIntentHandler()
    }
    
}
