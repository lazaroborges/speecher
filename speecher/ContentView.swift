import SwiftUI

struct ContentView: View {
    @StateObject var whisperState = WhisperState()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Speech Recognition")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40)
            
            // Recording status indicator
            HStack {
                Circle()
                    .fill(whisperState.isRecording ? Color.red : Color.gray)
                    .frame(width: 12, height: 12)
                Text(whisperState.isRecording ? "Recording..." : "Ready")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Record button
            Button(action: {
                Task {
                    await whisperState.toggleRecord()
                }
            }) {
                ZStack {
                    Circle()
                        .fill(whisperState.isRecording ? Color.red : Color.blue)
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: whisperState.isRecording ? "stop.fill" : "mic.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                }
            }
            .disabled(!whisperState.canTranscribe)
            .padding()
            
            // Transcribed text display
            VStack(alignment: .leading, spacing: 10) {
                Text("Transcription:")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                ScrollView {
                    Text(whisperState.transcribedText.isEmpty ? "Tap the microphone to start recording" : whisperState.transcribedText)
                        .font(.body)
                        .foregroundColor(whisperState.transcribedText.isEmpty ? .secondary : .primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                }
                .frame(maxHeight: 300)
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Model status
            HStack {
                Image(systemName: whisperState.isModelLoaded ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(whisperState.isModelLoaded ? .green : .red)
                Text(whisperState.isModelLoaded ? "Model loaded" : "Model not loaded")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground))
    }
}

#Preview {
    ContentView()
}