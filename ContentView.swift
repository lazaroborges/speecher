import SwiftUI
import Foundation

struct ContentView: View {
    @StateObject var whisperState = WhisperState()
    @State private var showFullScreenText = false
    @State private var currentTab = 0 // 0 = transcription, 1 = typing
    @State private var typedText = ""
    @State private var showFullScreenTypedText = false
    
    var body: some View {
        TabView(selection: $currentTab) {
            // Transcription Screen (Tab 0)
            transcriptionView
                .tag(0)
            
            // Typing Screen (Tab 1)
            typingView
                .tag(1)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .background(Color.black)
        .ignoresSafeArea()
        .overlay(
            // Navigation indicators
            VStack {
                if (currentTab == 0 && showFullScreenText) || (currentTab == 1 && showFullScreenTypedText) {
                    Spacer()
                }
                
                HStack {
                    Spacer()
                    HStack(spacing: 8) {
                        Circle()
                            .fill(currentTab == 0 ? Color.blue : Color.gray.opacity(0.4))
                            .frame(width: 8, height: 8)
                        Circle()
                            .fill(currentTab == 1 ? Color.blue : Color.gray.opacity(0.4))
                            .frame(width: 8, height: 8)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, ((currentTab == 0 && showFullScreenText) || (currentTab == 1 && showFullScreenTypedText)) ? 50 : 0)
                    .padding(.top, !((currentTab == 0 && showFullScreenText) || (currentTab == 1 && showFullScreenTypedText)) ? 60 : 0)
                }
                
                if !((currentTab == 0 && showFullScreenText) || (currentTab == 1 && showFullScreenTypedText)) {
                    Spacer()
                }
            }
        )
    }
    
    private var transcriptionView: some View {
        ZStack {
            if showFullScreenText && !whisperState.transcribedText.isEmpty {
                // Full screen transcribed text view
                fullScreenTextView(
                    text: whisperState.transcribedText,
                    onRecordAgain: {
                        showFullScreenText = false
                        Task {
                            await whisperState.toggleRecord()
                        }
                    },
                    onClear: {
                        showFullScreenText = false
                    }
                )
            } else {
                // Simplified recording interface
                VStack {
                    Spacer()
                    
                    // Screen indicator
                    Text("Voice to Text")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 20)
                    
                    // Recording button container
                    VStack(spacing: 20) {
                        // Recording status indicator (only show when recording)
                        if whisperState.isRecording {
                            HStack {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 12, height: 12)
                                Text("recording_status".localized)
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
                    
                    // Language selection dropdown at the bottom
                    VStack(spacing: 12) {
                        Text("language_label".localized)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Menu {
                            ForEach(Language.allCases, id: \.id) { language in
                                Button(action: {
                                    whisperState.selectedLanguage = language
                                }) {
                                    HStack {
                                        Text(language.name)
                                        if language.id == whisperState.selectedLanguage.id {
                                            Spacer()
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Text(whisperState.selectedLanguage.name)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color(UIColor.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .frame(maxWidth: 280)
                    }
                    .padding(.bottom, 30)
                    
                    // Swipe hint
                    HStack {
                        Spacer()
                        HStack(spacing: 4) {
                            Text("Swipe for typing")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Image(systemName: "arrow.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 10)
                    }
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
        .onChange(of: whisperState.transcribedText) { oldValue, newValue in
            // When transcription completes (text becomes non-empty) and we're not recording, show full screen
            if !newValue.isEmpty && !whisperState.isRecording {
                showFullScreenText = true
            }
        }
    }
    
    private var typingView: some View {
        ZStack {
            if showFullScreenTypedText && !typedText.isEmpty {
                // Full screen typed text view
                fullScreenTextView(
                    text: typedText,
                    onRecordAgain: {
                        showFullScreenTypedText = false
                        typedText = ""
                    },
                    onClear: {
                        showFullScreenTypedText = false
                    }
                )
            } else {
                // Typing interface
                VStack {
                    Spacer()
                    
                    // Screen indicator
                    Text("Type to Display")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 20)
                    
                    // Typing area
                    VStack(spacing: 20) {
                        // Text input
                        TextField("Type your message here...", text: $typedText, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.body)
                            .lineLimit(3...10)
                            .padding(.horizontal)
                        
                        // Display button
                        Button(action: {
                            if !typedText.isEmpty {
                                showFullScreenTypedText = true
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(typedText.isEmpty ? Color.gray : Color.blue)
                                    .frame(width: 120, height: 120)
                                
                                Image(systemName: "text.bubble.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white)
                            }
                        }
                        .disabled(typedText.isEmpty)
                    }
                    .padding()
                    
                    Spacer()
                    
                    // Swipe hint
                    HStack {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.left")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("Swipe for voice")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.leading, 20)
                        .padding(.bottom, 10)
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(UIColor.systemBackground))
            }
        }
    }
    
    // Reusable full screen text view
    private func fullScreenTextView(text: String, onRecordAgain: @escaping () -> Void, onClear: @escaping () -> Void) -> some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Close button and record again button
                HStack {
                    Button(currentTab == 0 ? "record_again".localized : "Type Again") {
                        onRecordAgain()
                    }
                    .font(.body)
                    .foregroundColor(.blue)

                    Spacer()

                    Button("clear".localized) {
                        onClear()
                    }
                    .font(.body)
                    .foregroundColor(.white)
                }
                .padding()
                .padding(.top)

                // Large text display
                ScrollView {
                    Text(text)
                        .font(.system(size: min(UIScreen.main.bounds.width / 15, 60), weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}