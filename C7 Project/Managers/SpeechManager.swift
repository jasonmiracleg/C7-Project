//
//  SpeechManager.swift
//  C7 Project
//
//  Updated to use WhisperKit instead of Apple Speech framework
//

import Foundation
import AVFoundation
import WhisperKit
internal import CoreML

@Observable
class SpeechManager {
    
    var isRecording: Bool = false
    var transcript: String = ""
    var isModelLoading: Bool = false
    var modelLoadError: String?
    
    // Callback for transcript updates
    var onTranscriptUpdate: ((String) -> Void)?
    
    // Audio Engine
    private let audioEngine = AVAudioEngine()
    
    // WhisperKit
    private var whisperKit: WhisperKit?
    private var audioBuffers: [AVAudioPCMBuffer] = []
    private let processingQueue = DispatchQueue(label: "com.whisperkit.processing")
    
    // Timing
    private var recordingStart: Date?
    private var recordingEnd: Date?
    
    // Audio settings to match WhisperKit expectations
    private let sampleRate: Double = 16000.0
    
    deinit {
        stopRecording()
    }
    
    // MARK: - Model Loading
    func loadModel() async {
        await MainActor.run {
            isModelLoading = true
            modelLoadError = nil
        }
        
        do {
            // Load WhisperKit with base model in CoreML format
            whisperKit = try await WhisperKit(
                model: "base",
                downloadBase: nil,
                modelFolder: nil,
                computeOptions: ModelComputeOptions(
                    audioEncoderCompute: .cpuAndGPU,
                    textDecoderCompute: .cpuAndGPU
                ),
                verbose: true,
                logLevel: .info
            )
            
            await MainActor.run {
                isModelLoading = false
            }
            print("✅ WhisperKit model loaded successfully")
        } catch {
            await MainActor.run {
                isModelLoading = false
                modelLoadError = "Failed to load model: \(error.localizedDescription)"
            }
            print("❌ Failed to load WhisperKit: \(error)")
        }
    }
    
    // MARK: - Permissions
    func requestPermissions(completion: @escaping (Bool) -> Void) {
        AVAudioApplication.requestRecordPermission { granted in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    // MARK: - Recording Lifecycle
    func startRecording() throws {
        guard whisperKit != nil else {
            throw NSError(domain: "WhisperKit", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "WhisperKit model not loaded"])
        }
        
        stopRecording()
        
        transcript = ""
        audioBuffers.removeAll()
        
        // Configure Audio Session
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        let inputNode = audioEngine.inputNode
        let inputFormat = inputNode.outputFormat(forBus: 0)
        
        // Create converter format for 16kHz mono (WhisperKit expects this)
        guard let converterFormat = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: sampleRate,
            channels: 1,
            interleaved: false
        ) else {
            throw NSError(domain: "AudioFormat", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "Failed to create converter format"])
        }
        
        // Create audio converter
        guard let converter = AVAudioConverter(from: inputFormat, to: converterFormat) else {
            throw NSError(domain: "AudioConverter", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "Failed to create audio converter"])
        }
        
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 4096, format: inputFormat) { [weak self] buffer, when in
            guard let self = self else { return }
            
            // Convert to 16kHz mono format
            guard let convertedBuffer = self.convertBuffer(buffer, using: converter, to: converterFormat) else {
                return
            }
            
            self.processingQueue.async {
                self.audioBuffers.append(convertedBuffer)
            }
        }
        
        // Start Recording
        audioEngine.prepare()
        try audioEngine.start()
        
        recordingStart = Date()
        isRecording = true
        
        print("🎙️ Recording started")
    }
    
    func stopRecording() {
        guard isRecording else { return }
        
        if audioEngine.isRunning {
            audioEngine.inputNode.removeTap(onBus: 0)
            audioEngine.stop()
        }
        
        recordingEnd = Date()
        isRecording = false
        
        print("⏹️ Recording stopped")
        
        // Process accumulated audio buffers
        Task {
            await transcribeAudio()
        }
    }
    
    // MARK: - Audio Processing
    private func convertBuffer(
        _ buffer: AVAudioPCMBuffer,
        using converter: AVAudioConverter,
        to format: AVAudioFormat
    ) -> AVAudioPCMBuffer? {
        
        let capacity = AVAudioFrameCount(
            Double(buffer.frameLength) * format.sampleRate / buffer.format.sampleRate
        )
        
        guard let convertedBuffer = AVAudioPCMBuffer(
            pcmFormat: format,
            frameCapacity: capacity
        ) else {
            return nil
        }
        
        var error: NSError?
        let inputBlock: AVAudioConverterInputBlock = { inNumPackets, outStatus in
            outStatus.pointee = .haveData
            return buffer
        }
        
        converter.convert(to: convertedBuffer, error: &error, withInputFrom: inputBlock)
        
        if let error = error {
            print("❌ Conversion error: \(error)")
            return nil
        }
        
        return convertedBuffer
    }
    
    private func transcribeAudio() async {
        guard let whisperKit = whisperKit else { return }
        
        // Combine all audio buffers into a single array
        let audioArray = processingQueue.sync { () -> [Float] in
            var combined: [Float] = []
            
            for buffer in audioBuffers {
                guard let channelData = buffer.floatChannelData else { continue }
                let frameLength = Int(buffer.frameLength)
                let samples = Array(UnsafeBufferPointer(start: channelData[0], count: frameLength))
                combined.append(contentsOf: samples)
            }
            
            return combined
        }
        
        guard !audioArray.isEmpty else {
            print("⚠️ No audio data to transcribe")
            return
        }
        
        print("🔄 Transcribing \(audioArray.count) audio samples...")
        
        do {
            let results: [TranscriptionResult] = try await whisperKit.transcribe(
                audioArray: audioArray,
                decodeOptions: DecodingOptions(
                    withoutTimestamps: false,
                    wordTimestamps: false
                )
            )
            
            // Extract transcript from all results and clean special tokens
            let transcribedText = results
                .flatMap { $0.segments }
                .map { $0.text }
                .joined(separator: " ")
                .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            // Remove WhisperKit special tokens
            let cleanedText = cleanSpecialTokens(transcribedText)
            
            await MainActor.run {
                self.transcript = cleanedText
                print("✅ Transcription complete: \(cleanedText)")
            }
            
        } catch {
            print("❌ Transcription error: \(error)")
            await MainActor.run {
                self.transcript = ""
            }
        }
    }
    
    // MARK: - Helpers
    private func cleanSpecialTokens(_ text: String) -> String {
        // Remove all WhisperKit special tokens
        let pattern = "<\\|[^|]+\\|>"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(text.startIndex..., in: text)
        let cleanedText = regex?.stringByReplacingMatches(
            in: text,
            options: [],
            range: range,
            withTemplate: ""
        ) ?? text
        
        return cleanedText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
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
