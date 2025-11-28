# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Speecher is an iOS voice-to-text transcription app that runs entirely on-device using local Whisper models. It's designed to facilitate communication between speaking individuals and those who are deaf or hard of hearing, with 100% offline functionality and complete privacy.

## Build and Run Commands

### Building the Whisper Framework (First-time setup)
```bash
cd whisper.cpp
./build-xcframework.sh
```

### Downloading the Model (First-time setup)
```bash
cd whisper.cpp/models
./download-ggml-model.sh <model_size>
# Common sizes: tiny, base, small, medium (default), large-v3
```

After downloading, add `ggml-<model_size>.bin` to the Xcode project under `Resources/models/` and ensure it's added to the target.

### Building and Running
Open `speecher.xcodeproj` in Xcode and build/run normally (⌘+R). The project requires:
- iOS 16.4+ / macOS 13.3+
- Xcode 15+
- Whisper.xcframework must be linked (under "Frameworks, Libraries, and Embedded Content" with "Embed & Sign")

## Architecture

### Core Components

**WhisperState.swift** - Main state management and orchestration
- `@MainActor` class that owns the Whisper context and coordinates the transcription flow
- Manages model loading from bundle (`ggml-medium.bin` by default, searches multiple paths)
- Handles recording lifecycle: start → stop → transcribe → update UI
- Stores language preference in UserDefaults
- Default language is Portuguese (`pt`), configurable via UI dropdown

**LibWhisper.swift** - Whisper.cpp integration layer
- `WhisperContext` actor that wraps the C++ Whisper library
- `fullTranscribe(samples:language:)` - Processes audio with language-specific parameters
- Thread management: Uses `cpuCount() - 2` threads (leaves 2 high-efficiency cores free)
- GPU acceleration: Enabled on real devices via Metal (`flash_attn = true`), disabled on simulator
- Language handling: Supports explicit language codes or auto-detection when `language == "auto"`

**Recorder.swift** - Audio capture for batch processing
- `actor` that manages AVAudioRecorder for record-then-transcribe workflow
- Records at 16kHz mono (Whisper requirement)
- Outputs Linear PCM WAV format to temporary file
- Handles iOS audio session activation/deactivation

**StreamingRecorder.swift** - Real-time audio processing (experimental)
- Uses AVAudioEngine with installTap for continuous audio capture
- Implements chunk-based processing: 3s steps, 10s context window, 200ms overlap
- Manual resampling from hardware rate (typically 48kHz) to 16kHz target
- Provides `onAudioChunkReady` callback for integration with streaming transcription
- Note: This is not currently integrated into the main UI (ContentView uses batch Recorder)

**ContentView.swift** - SwiftUI interface with two-tab design
- Tab 0: Voice-to-text with microphone button and language selector
- Tab 1: Type-to-display mode (manual text input)
- Full-screen text display after transcription/typing completes
- Uses `@StateObject` for WhisperState lifecycle management

**RiffWaveUtils.swift** - WAV file decoder
- `decodeWaveFile()` converts PCM WAV to Float array for Whisper
- Skips 44-byte WAV header, converts Int16 samples to normalized Float [-1.0, 1.0]

**Language.swift** - Multi-language support structure
- Defines 42 supported languages (English, Portuguese, Spanish, French, German, Japanese, Chinese, etc.)
- Localized display names via `.localized` string extension
- Default language: Portuguese

**LocalizationManager.swift** - i18n system
- Supports English, Spanish, and Portuguese UI text
- Auto-detects system locale and falls back to English
- Uses `.lproj` bundles (en.lproj, es.lproj, pt.lproj)

### Data Flow

1. **Recording**: User taps mic → `WhisperState.toggleRecord()` → `Recorder.startRecording()` → writes to `recording.wav`
2. **Transcription**: Recording stops → `transcribeAudio()` → `decodeWaveFile()` → `WhisperContext.fullTranscribe()` → `getTranscription()`
3. **Display**: `transcribedText` published property updates → ContentView reacts via `onChange` → shows full-screen text

### Model Configuration

The app looks for the model file in multiple locations:
1. `Bundle.main.url(forResource: "ggml-medium", withExtension: "bin", subdirectory: "Resources/models")`
2. `Bundle.main.url(forResource: "ggml-medium", withExtension: "bin")` (root)
3. Without subdirectory specification

To change the model size, update the `modelUrl` property in WhisperState.swift (lines 21-41).

### Language Configuration

Language selection is persisted in UserDefaults with key `selectedLanguageCode`. The selected language is passed to `WhisperContext.fullTranscribe()` which sets the `params.language` C parameter for the Whisper model.

To change the default language from Portuguese, modify `Language.defaultLanguage` in Language.swift:60.

### Threading and Performance

- **Whisper processing**: Uses `max(1, min(8, cpuCount() - 2))` threads (LibWhisper.swift:25)
- **WhisperContext**: Swift actor ensuring thread-safe access to C++ context
- **WhisperState**: `@MainActor` to ensure UI updates on main thread
- **GPU**: Metal acceleration enabled on physical devices via `flash_attn = true`

### Localization

Add new UI strings to all three `.lproj/Localizable.strings` files (en, es, pt). Access via `String.localized` extension:
```swift
Text("recording_status".localized)
```

## Common Development Tasks

### Changing the Model Size
1. Download new model: `cd whisper.cpp/models && ./download-ggml-model.sh small`
2. Add to Xcode project under Resources/models/
3. Update WhisperState.swift line 25: change `"ggml-medium"` to `"ggml-small"`

### Adding a New Language
1. Add language to `Language.allCases` array in Language.swift
2. Add corresponding localization key to all `.lproj/Localizable.strings` files
3. Whisper model automatically supports the language if it's in the model's training data

### Integrating Streaming Mode
StreamingRecorder is implemented but not connected to UI. To integrate:
1. Replace `Recorder` with `StreamingRecorder` in WhisperState
2. Implement `onAudioChunkReady` callback to call `fullTranscribe()` on chunks
3. Handle incremental text updates in UI (append vs replace)

## Important Notes

- The app defaults to Portuguese because it was built for the Brazilian deaf/hard-of-hearing community
- All processing happens on-device with no network dependency
- Model files are large (~500MB for small, ~1.4GB for medium) and must be in the app bundle
- Audio is recorded at 16kHz mono Linear PCM to match Whisper's requirements
- GPU acceleration (Metal) significantly improves transcription speed on real devices
