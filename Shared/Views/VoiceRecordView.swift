//
//  VoiceRecordView.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/20/21.
//

// https://github.com/bbaars/SwiftUI-Sound-Visualizer

import SwiftUI
import AVFoundation
import ActivityIndicatorView

let numberOfSamples: Int = 10

struct VoiceRecordView: View {
    @Environment(\.presentationMode) var mode
    @EnvironmentObject var globalData: GlobalData
    let memory: Memory
    @ObservedObject var memoryViewModel: MemoryViewModel
    @ObservedObject private var viewModel = VoiceRecordViewModel()
    @ObservedObject private var mic = MicrophoneMonitor(numberOfSamples: numberOfSamples)
    
    enum RecordingStatus {
        case notStarted, recording, stoppedAndAudioNotPlaying, stoppedAndAudioPlaying
    }
    
    @State var recordingStatus: RecordingStatus = .notStarted
    @State var showActivityIndicatorView = false
    @State var showingUploadErrorAlert = false
    
    func upload(fileURL: URL) {
        let concurrentQueue = DispatchQueue(label: "MemoReminderUploadVoiceAsAttachment", attributes: .concurrent)
        concurrentQueue.async {
            main {
                showActivityIndicatorView = true
            }
            memoryViewModel.upload(memory: memory, fileURL: fileURL, globalData: globalData, isVoice: true) { r in
                if let resultString = r {
                    let result = JSON(parseJSON: resultString)
                    let fileURL = result["file"].stringValue
                    main {
                        memory.attachedFileURLs.append(fileURL)
                        showActivityIndicatorView = false
                        mode.wrappedValue.dismiss()
                        recordingStatus = .notStarted
                    }
                } else {
                    main {
                        showActivityIndicatorView = false
                        showingUploadErrorAlert = true
                    }
                }
            }
        }
    }
    
    func uploadButtonTapped() {
        upload(fileURL: getDocumentsDirectory().appendingPathComponent("voice.m4a"))
    }
    
    private func normalizeSoundLevel(level: Float) -> CGFloat {
        let level = max(0.2, CGFloat(level) + 50) / 2 // between 0.1 and 25
        
        return CGFloat(level * (300 / 25)) // scaled to max at 300 (our height of our bar)
    }
    
    var buttonLabel: some View {
        recordingStatus == .notStarted ? Label("Start recording", systemImage: "play") :
                (recordingStatus == .recording ? Label("Stop recording", systemImage: "stop") :
                    (recordingStatus == .stoppedAndAudioNotPlaying ? Label("Play the recorded voice", systemImage: "play.fill") : Label("Stop the recorded voice", systemImage: "stop.fill")))
    }
    
    fileprivate func mainButtonTapped() {
        switch recordingStatus {
        case .notStarted:
            mic.startMonitoring()
            withAnimation { recordingStatus = .recording }
        case .recording:
            mic.stopMonitoring()
            withAnimation { recordingStatus = .stoppedAndAudioNotPlaying }
        case .stoppedAndAudioNotPlaying:
            viewModel.playAudio()
            withAnimation { recordingStatus = .stoppedAndAudioPlaying }
        case .stoppedAndAudioPlaying:
            viewModel.stopAudio()
            withAnimation { recordingStatus = .stoppedAndAudioNotPlaying }
        }
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 10) {
                HStack(spacing: 4) {
                    ForEach(mic.soundSamples, id: \.self) { level in
                        BarView(value: self.normalizeSoundLevel(level: level))
                            .opacity(recordingStatus == .recording ? 1 : 0)
                    }
                }
                
                Button(action: mainButtonTapped) { buttonLabel }
                .buttonStyle(AddMemoryButton(colors: [Color(red: 0.22, green: 0.22, blue: 0.70), Color(red: 0.32, green: 0.32, blue: 1)])).clipShape(Capsule())
            }
            
            ActivityIndicatorView(isVisible: $showActivityIndicatorView, type: .equalizer)
                .frame(width: 100.0, height: 100.0)
                .foregroundColor(.orange)
        }
        .alert("Error in uploading the voice. Please try again", isPresented: $showingUploadErrorAlert) {
            Button("OK", role: .cancel) { }
        }
        .navigationBarTitle("Record Voice")
        .navigationBarItems(trailing: HStack {
            if recordingStatus == .stoppedAndAudioNotPlaying || recordingStatus == .stoppedAndAudioPlaying {
                Button(action: uploadButtonTapped) { Text("Upload").bold() }
            }
        })
        .onAppear(perform: mic.setupMonitor)
    }
}

struct VoiceRecordView_Previews: PreviewProvider {
    static var previews: some View {
        VoiceRecordView(memory: .sample, memoryViewModel: .sample)
            .environmentObject(GlobalData.sample)
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
                    .frame(width: (UIScreen.main.bounds.width - CGFloat(numberOfSamples) * 4) / CGFloat(numberOfSamples), height: value)
            }
        }
    }
}

class MicrophoneMonitor: ObservableObject {
    
    private var audioRecorder = AVAudioRecorder()
    private var timer: Timer?
    
    private var currentSample: Int
    private let numberOfSamples: Int
    
    @Published public var soundSamples: [Float]
    
    init(numberOfSamples: Int) {
        self.numberOfSamples = numberOfSamples
        self.soundSamples = [Float](repeating: .zero, count: numberOfSamples)
        self.currentSample = 0
    }
    
    func setupMonitor() {
        let audioSession = AVAudioSession.sharedInstance()
        if audioSession.recordPermission != .granted {
            audioSession.requestRecordPermission { (isGranted) in
                if !isGranted {
                    fatalError("You must allow audio recording for this feature to work")
                }
            }
        }
        
        let url = getDocumentsDirectory().appendingPathComponent("voice.m4a")
        let recorderSettings: [String:Any] = [
            AVFormatIDKey: NSNumber(value: kAudioFormatAppleLossless),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: url, settings: recorderSettings)
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [])
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func startMonitoring() {
        audioRecorder.isMeteringEnabled = true
        audioRecorder.record()
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { (timer) in
            self.audioRecorder.updateMeters()
            self.soundSamples[self.currentSample] = self.audioRecorder.averagePower(forChannel: 0)
            self.currentSample = (self.currentSample + 1) % self.numberOfSamples
        })
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        audioRecorder.stop()
    }
    
    deinit {
        stopMonitoring()
    }
}

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let documentsDirectory = paths[0]
    return documentsDirectory
}
