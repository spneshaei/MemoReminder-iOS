//
//  VoiceRecordView.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/20/21.
//

// https://github.com/bbaars/SwiftUI-Sound-Visualizer

import SwiftUI
import AVFoundation

let numberOfSamples: Int = 10

struct VoiceRecordView: View {
    @ObservedObject private var mic = MicrophoneMonitor(numberOfSamples: numberOfSamples)
    
    private func normalizeSoundLevel(level: Float) -> CGFloat {
        let level = max(0.2, CGFloat(level) + 50) / 2 // between 0.1 and 25
        
        return CGFloat(level * (300 / 25)) // scaled to max at 300 (our height of our bar)
    }
    
    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 4) {
                ForEach(mic.soundSamples, id: \.self) { level in
                    BarView(value: self.normalizeSoundLevel(level: level))
                }
            }
            
            Button("Start recording") {
                
            }
            .buttonStyle(AddMemoryButton(colors: [Color(red: 0.22, green: 0.22, blue: 0.70), Color(red: 0.32, green: 0.32, blue: 1)])).clipShape(Capsule())
        }
    }
}

struct VoiceRecordView_Previews: PreviewProvider {
    static var previews: some View {
        VoiceRecordView()
    }
}

struct BarView: View {
    var value: CGFloat

    var body: some View {
        ZStack {
            GeometryReader { geo in
                RoundedRectangle(cornerRadius: 20)
                    .fill(LinearGradient(gradient: Gradient(colors: [Color(red: 0.22, green: 0.22, blue: 0.70), Color(red: 0.32, green: 0.32, blue: 1)]/*[.orange, .red]*/),
                                         startPoint: .top,
                                         endPoint: .bottom))
                    .frame(width: (geo.size.width - CGFloat(numberOfSamples) * 4) / CGFloat(numberOfSamples), height: value)
            }
        }
    }
}

class MicrophoneMonitor: ObservableObject {
    
    // 1
    private var audioRecorder: AVAudioRecorder
    private var timer: Timer?
    
    private var currentSample: Int
    private let numberOfSamples: Int
    
    // 2
    @Published public var soundSamples: [Float]
    
    init(numberOfSamples: Int) {
        self.numberOfSamples = numberOfSamples // In production check this is > 0.
        self.soundSamples = [Float](repeating: .zero, count: numberOfSamples)
        self.currentSample = 0
        
        // 3
        let audioSession = AVAudioSession.sharedInstance()
        if audioSession.recordPermission != .granted {
            audioSession.requestRecordPermission { (isGranted) in
                if !isGranted {
                    fatalError("You must allow audio recording for this demo to work")
                }
            }
        }
        
        // 4
        let url = URL(fileURLWithPath: "/dev/null", isDirectory: true)
        let recorderSettings: [String:Any] = [
            AVFormatIDKey: NSNumber(value: kAudioFormatAppleLossless),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue
        ]
        
        // 5
        do {
            audioRecorder = try AVAudioRecorder(url: url, settings: recorderSettings)
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [])
            
            startMonitoring()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    // 6
    private func startMonitoring() {
        audioRecorder.isMeteringEnabled = true
        audioRecorder.record()
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { (timer) in
            // 7
            self.audioRecorder.updateMeters()
            self.soundSamples[self.currentSample] = self.audioRecorder.averagePower(forChannel: 0)
            self.currentSample = (self.currentSample + 1) % self.numberOfSamples
        })
    }
    
    // 8
    deinit {
        timer?.invalidate()
        audioRecorder.stop()
    }
}
