import SwiftUI

struct ContentView: View {
    @StateObject var whisperState = WhisperState()
    @State private var showFullScreenText = false
    
    var body: some View {
        ZStack {
            if showFullScreenText && !whisperState.transcribedText.isEmpty {
                // Full screen transcribed text view
                ZStack {
                    Color.black
                        .ignoresSafeArea()
                    
                    VStack {
                        // Close button and record again button
                        HStack {
                            Button("Record Again") {
                                showFullScreenText = false
                                Task {
                                    await whisperState.toggleRecord()
                                }
                            }
                            .foregroundColor(.blue)
                            .padding()
                            
                            Spacer()
                            
                            Button("Close") {
                                showFullScreenText = false
                            }
                            .foregroundColor(.white)
                            .padding()
                        }
                        
                        Spacer()
                        
                        // Large transcribed text
                        ScrollView {
                            Text(whisperState.transcribedText)
                                .font(.system(size: min(UIScreen.main.bounds.width / 15, 60), weight: .medium))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding()
                        }
                        
                        Spacer()
                    }
                }
            } else {
                // Simplified recording interface
                VStack {
                    Spacer()
                    
                    // Recording button container
                    VStack(spacing: 20) {
                        // Recording status indicator (only show when recording)
                        if whisperState.isRecording {
                            HStack {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 12, height: 12)
                                Text("Recording...")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
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
                                    .frame(width: 120, height: 120)
                                
                                Image(systemName: whisperState.isRecording ? "stop.fill" : "mic.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white)
                            }
                        }
                        .disabled(!whisperState.canTranscribe)
                    }
                    .padding()
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(UIColor.systemBackground))
            }
        }
        .onChange(of: whisperState.isRecording) { oldValue, newValue in
            // When recording stops and we have transcribed text, show full screen
            if oldValue == true && newValue == false && !whisperState.transcribedText.isEmpty {
                showFullScreenText = true
            }
        }
    }
}

#Preview {
    ContentView()
}