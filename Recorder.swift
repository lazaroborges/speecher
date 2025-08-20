import Foundation
import AVFoundation

actor Recorder {
    private var recorder: AVAudioRecorder?

    enum RecorderError: Error {
        case recordsDirectoryNotFound
    }

    func startRecording(toOutputFile url: URL, delegate: AVAudioRecorderDelegate?) async throws {
        let recordSettings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 16000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
#if !os(macOS)
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .default)
        try session.setActive(true)
#endif
        
        recorder = try AVAudioRecorder(url: url, settings: recordSettings)
        recorder?.delegate = delegate
        recorder?.record()
    }

    func stopRecording() async {
        recorder?.stop()
#if !os(macOS)
        try? AVAudioSession.sharedInstance().setActive(false)
#endif
        recorder = nil
    }
}
