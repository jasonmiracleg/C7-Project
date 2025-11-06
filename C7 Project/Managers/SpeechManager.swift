//
//  SpeechManager.swift
//  C7 Project
//
//  Created by Jason Miracle Gunawan on 27/10/25.
//

import Foundation
import AVFoundation
import Speech

@Observable
class SpeechManager {
    
    var isRecording: Bool = false
    var transcript: String = ""
    
    // Speech Object
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    
    // Timing
    private var recordingStart: Date?
    private var recordingEnd: Date?
    
    deinit {
        stopRecording()
    }
    
    // MARK: - Permissions
    func requestPermissions(completion: @escaping (Bool) -> Void) {
        let group = DispatchGroup()
        var speechGranted = false
        var audioGranted = false
        
        group.enter()
        SFSpeechRecognizer.requestAuthorization { status in
            speechGranted = (status == .authorized)
            group.leave()
        }
        
        group.enter()
        
        AVAudioApplication.requestRecordPermission { granted in
            audioGranted = granted
            group.leave()
        }
        
        group.notify(queue: .main) {
            completion(speechGranted && audioGranted)
        }
    }
    
    // MARK: - Recording Lifecycle
    func startRecording() throws {
        
        stopRecording()
        
        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            throw NSError(domain: "SpeechRecognizer", code: -1, userInfo: [NSLocalizedDescriptionKey: "Speech Recognizer not Available"])
        }
        
        transcript = ""
        
        // Configure Audio Session
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest?.shouldReportPartialResults = true
        
        let inputNode = audioEngine.inputNode
        let inputFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: inputFormat) { [weak self] buffer, when in
            self?.recognitionRequest?.append(buffer)
        }
        
        // Start Recording
        audioEngine.prepare()
        try audioEngine.start()
        
        recordingStart = Date()
        isRecording = true
        
        recognitionTask = recognizer.recognitionTask(with: recognitionRequest!) { [weak self] result, error in
            guard let self = self else { return }
            
            if let result = result {
                DispatchQueue.main.async {
                    self.transcript = result.bestTranscription.formattedString
                }
            }
            
            if let error =  error {
                print("Recognition error:", error.localizedDescription)
                self.stopRecording()
            }
            
            if result?.isFinal == true {
            }
        }
    }
    
    func stopRecording() {
        guard isRecording else { return }
        
        if audioEngine.isRunning {
            audioEngine.inputNode.removeTap(onBus: 0)
            audioEngine.stop()
        }
        
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask = nil
        
        isRecording = false
    }
    
    // Helpers to Computer Recording Durations
    private var currentRecordingDuration: TimeInterval {
        guard let start = recordingStart else { return 0 }
        return Date().timeIntervalSince(start)
    }
    
    private var finalRecordingDuration: TimeInterval {
        guard let start = recordingStart else { return 0 }
        let end = recordingEnd ?? Date()
        return end.timeIntervalSince(start)
    }
}
