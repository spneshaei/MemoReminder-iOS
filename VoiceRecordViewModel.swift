//
//  VoiceRecordViewModel.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/20/21.
//

import SwiftUI
import AVFoundation

class VoiceRecordViewModel: ObservableObject {
    private var voice: AVAudioPlayer?
    
    func playAudio() {
        let url = getDocumentsDirectory().appendingPathComponent("voice.m4a")
        do {
            voice = try AVAudioPlayer(contentsOf: url)
            voice?.play()
        } catch {
            print("Error in playing / opening voice file...")
        }
    }
    
    func stopAudio() {
        voice?.stop()
    }
}
