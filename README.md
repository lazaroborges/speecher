# Speecher - Edge Voice to Text Transcriber

**Speecher** is an edge-native voice-to-text transcription application designed to facilitate communication between speaking individuals and those who are deaf or hard of hearing. The app runs entirely on-device using local Whisper models for real-time speech recognition with zero cloud dependency.

## Features

- ✅ **100% Offline & Private** - All processing happens on-device, no internet connection required
- 🎤 **Real-time Edge Inference** - Convert speech to text instantly using local models
- 🇵🇹 **Portuguese Language Support** - Built for Portuguese speech recognition, other languages available through the Whisper CPP Model
- 📱 **Clean, Accessible Interface** - Large text display for easy reading
- 🔄 **Simple Recording Controls** - One-tap recording with visual feedback
- ⚡ **Metal GPU Acceleration** - Optimized edge performance on iOS devices
- 🔒 **Privacy-First** - No data leaves your device, complete edge computing solution

## Edge Computing Architecture

The app leverages edge computing principles with:
- **SwiftUI** - Modern iOS user interface
- **Whisper.cpp** - Local edge speech recognition engine
- **AVFoundation** - On-device audio recording and processing
- **Metal** - GPU acceleration for edge model inference
- **Local Storage** - Edge model deployment with no external dependencies

## Requirements

- iOS 16.4+ (iPhone 13+) / macOS 13.3+
- Xcode 15+
- ~1.5GB edge storage space for the medium Whisper model
- Microphone permissions

## Setup Instructions

### 1. Clone the Repository

```bash
git clone --recursive https://github.com/lazaroborges/speecher.git
cd speecher
```

### 2. Build the Edge Whisper Framework

First, build the Whisper.cpp XCFramework for edge deployment on iOS:

```bash
cd whisper.cpp
./build-xcframework.sh
```

This will create the necessary framework files optimized for edge computing.

### 3. Download and Deploy the Edge Model

Download the Portuguese-optimized medium model for edge inference:

```bash
cd whisper.cpp/models
./download-ggml-model.sh medium
```

This will download `ggml-medium.bin` (~1.4GB) for local edge deployment.

### 4. Add Edge Model to Xcode Project

1. Open `speecher.xcodeproj` in Xcode
2. Right-click on the `Resources/models/` folder in the project navigator
3. Select "Add Files to 'speecher'"
4. Navigate to `whisper.cpp/models/` and select `ggml-medium.bin`
5. Ensure "Add to target: speecher" is checked
6. Click "Add"

### 5. Add Whisper Edge Framework to Project

1. In Xcode, select your project in the navigator
2. Go to your target's "General" tab
3. Under "Frameworks, Libraries, and Embedded Content", click "+"
4. Click "Add Other..." → "Add Files..."
5. Navigate to `whisper.cpp/` and add the generated `whisper.xcframework`
6. Set "Embed & Sign" for the framework

### 6. Configure Permissions

The app requires microphone access for edge processing. The `Info.plist` should include:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>Speecher needs microphone access to transcribe your speech to text using edge computing.</string>
```

## Usage

1. **Launch the app** - The Whisper model will load automatically
2. **Tap the blue microphone button** - Start recording
3. **Speak clearly** - The recording indicator will show red
4. **Tap the red stop button** - End recording and process speech
5. **View transcription** - Large text appears in full-screen mode
6. **Record again or clear** - Use the control buttons to continue

## Edge Model Options

You can deploy different Whisper models based on your edge computing needs:

| Model | Size | Edge Speed | Accuracy | Edge Use Case |
|-------|------|------------|----------|---------------|
| `tiny` | ~39MB | Fastest | Basic | Edge testing/Development |
| `base` | ~142MB | Fast | Good | Quick edge transcription |
| `small` | ~466MB | Medium | Better | Balanced edge performance |
| `medium` | ~1.4GB | Slower | Best | Production edge use (default) |
| `large-v3` | ~2.9GB | Slowest | Excellent | Maximum edge accuracy |

To deploy a different edge model:

```bash
# Download the desired edge model
cd whisper.cpp/models
./download-ggml-model.sh small

# Update WhisperState.swift to use the new edge model
# Change "ggml-medium.bin" to "ggml-small.bin" in modelUrl
```

## Edge Computing File Structure

```
speecher/
├── ContentView.swift          # Main UI with edge recording interface
├── WhisperState.swift         # Edge speech recognition state management
├── LibWhisper.swift          # Whisper.cpp at the edge integration layer
├── Recorder.swift            # Edge audio recording functionality
├── RiffWaveUtils.swift       # WAV file processing for edge inference
├── speecherApp.swift         # Edge app entry point
└── Resources/
    └── models/               # Edge model storage
        └── ggml-medium.bin   # Deployed edge model file
```

## Edge Configuration

### Language Settings for Edge Inference

The app is configured for Portuguese edge processing by default. To change the language for edge inference, modify `LibWhisper.swift`:

```swift
// Line 35 in LibWhisper.swift
params.language = pt  // Change "pt" to your language code for edge processing
```

Supported model language codes: `en`, `es`, `fr`, `de`, `it`, `pt`, `ru`, `zh`, etc.

### Edge Performance Tuning

Adjust threading for optimal edge computing performance in `LibWhisper.swift`:

```swift
// Line 25 - Modify thread count based on edge device capabilities
let maxThreads = max(1, min(8, cpuCount() - 2))
```

## Troubleshooting Edge Deployment

### Edge Model Not Loading
- Verify `ggml-medium.bin` is properly deployed in the app bundle
- Check edge model file size (~1.4GB for medium model)
- Ensure edge model is added to Xcode target

### Poor Edge Recognition Quality
- Speak clearly and close to device during edge processing
- Minimize background noise for better edge inference
- Consider deploying a larger edge model (`large-v3`)
- Check microphone permissions for edge recording

### Edge Performance Issues
- Deploy a smaller edge model (`small` or `base`)
- Close other apps to free memory for edge computing
- Ensure device has sufficient storage for edge models

### Edge Build Errors
- Update Xcode to latest version for edge framework support
- Clean build folder (⌘+Shift+K)
- Verify whisper.xcframework is properly linked for edge deployment

## Contributing to Edge Computing

1. Fork the repository
2. Create a feature branch for edge improvements
3. Make your edge computing changes
4. Test thoroughly on edge devices
5. Submit a pull request

## License

This edge computing project uses the MIT License. The Whisper.cpp library is also under MIT License.

## Acknowledgments

- [OpenAI Whisper](https://github.com/openai/whisper) - Original speech recognition model
- [whisper.cpp](https://github.com/ggerganov/whisper.cpp) - Efficient C++ implementation for edge computing
- [ggerganov](https://github.com/ggerganov) - whisper.cpp author and edge computing pioneer

## Support

For edge computing issues and questions:
1. Check the edge troubleshooting section above
2. Search existing GitHub issues for edge-related problems
3. Create a new issue with detailed edge deployment information

---
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Made with ❤️ in Brazil for the deaf and hard of hearing community using computing**
