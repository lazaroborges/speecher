import Foundation
import SwiftUI
import AVFoundation

@MainActor
class WhisperState: NSObject, ObservableObject, AVAudioRecorderDelegate {
    @Published var isModelLoaded = false
    @Published var transcribedText = ""
    @Published var isRecording = false
    @Published var canTranscribe = false
    @Published var selectedLanguage: Language = Language.defaultLanguage {
        didSet {
            saveLanguagePreference()
        }
    }
    
    private var whisperContext: WhisperContext?
    private var recorder = Recorder()
    private var recordedFile: URL? = nil
    
    private var modelUrl: URL? {
        // Try multiple potential paths for the model file
        let possiblePaths = [
            // First try the Resources/models subdirectory
            Bundle.main.url(forResource: "ggml-medium", withExtension: "bin", subdirectory: "Resources/models"),
            // Then try the main bundle root
            Bundle.main.url(forResource: "ggml-medium", withExtension: "bin"),
            // Try without subdirectory specification
            Bundle.main.url(forResource: "ggml-medium", withExtension: "bin", subdirectory: nil)
        ]
        
        for path in possiblePaths {
            if let url = path, FileManager.default.fileExists(atPath: url.path) {
                print("Found model at: \(url.path)")
                return url
            }
        }
        
        print("Model file not found in any of the expected locations")
        return nil
    }
    
    override init() {
        super.init()
        loadLanguagePreference()
        loadModel()
    }
    
    private func loadLanguagePreference() {
        let savedLanguageCode = UserDefaults.standard.string(forKey: "selectedLanguageCode") ?? "pt"
        selectedLanguage = Language.allCases.first { $0.code == savedLanguageCode } ?? Language.defaultLanguage
        print("Loaded language preference: \(selectedLanguage.name) (\(selectedLanguage.code))")
    }
    
    private func saveLanguagePreference() {
        UserDefaults.standard.set(selectedLanguage.code, forKey: "selectedLanguageCode")
        print("Saved language preference: \(selectedLanguage.name) (\(selectedLanguage.code))")
    }
    
    func loadModel() {
        do {
            whisperContext = nil
            
            if let modelUrl {
                print("Attempting to load model from: \(modelUrl.path)")
                whisperContext = try WhisperContext.createContext(path: modelUrl.path())
                isModelLoaded = true
                canTranscribe = true
                print("Model loaded successfully")
            } else {
                print("Could not locate model file. Please ensure ggml-medium.bin is added to your Xcode project bundle.")
                isModelLoaded = false
                canTranscribe = false
            }
        } catch {
            print("Error loading model: \(error.localizedDescription)")
            isModelLoaded = false
            canTranscribe = false
        }
    }
    
    private func transcribeAudio(_ url: URL) async {
        if (!canTranscribe) {
            return
        }
        guard let whisperContext else {
            return
        }
        
        do {
            canTranscribe = false
            let data = try decodeWaveFile(url)
            
            await whisperContext.fullTranscribe(samples: data, language: selectedLanguage.code)
            let text = await whisperContext.getTranscription()
            
            // Update the transcribed text on the main thread
            transcribedText = text
        } catch {
            print("Error transcribing: \(error.localizedDescription)")
        }
        
        canTranscribe = true
    }
    
    func toggleRecord() async {
        if isRecording {
            await recorder.stopRecording()
            isRecording = false
            if let recordedFile {
                await transcribeAudio(recordedFile)
            }
        } else {
            requestRecordPermission { granted in
                if granted {
                    Task {
                        do {
                            let file = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                                .appending(path: "recording.wav")
                            try await self.recorder.startRecording(toOutputFile: file, delegate: self)
                            self.isRecording = true
                            self.recordedFile = file
                        } catch {
                            print("Recording error: \(error.localizedDescription)")
                            self.isRecording = false
                        }
                    }
                }
            }
        }
    }
    
    private func requestRecordPermission(response: @escaping (Bool) -> Void) {
#if os(macOS)
        response(true)
#else
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            response(granted)
        }
#endif
    }
    
    // MARK: AVAudioRecorderDelegate
    
    nonisolated func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error {
            Task {
                await handleRecError(error)
            }
        }
    }
    
    private func handleRecError(_ error: Error) {
        print("Recording error: \(error.localizedDescription)")
        isRecording = false
    }
    
    nonisolated func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        Task {
            await onDidFinishRecording()
        }
    }
    
    private func onDidFinishRecording() {
        isRecording = false
    }
}
