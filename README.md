# EasyLlama 🦙

**EasyLlama** is a lightweight, incredibly simple Swift wrapper built on top of [swift-llama-cpp](https://github.com/pgorzelany/swift-llama-cpp). It allows you to run local Large Language Models (LLMs) like Llama, Gemma, and Mistral natively on iOS and macOS completely offline.

Say goodbye to complex C++ bridging and massive configuration files. With EasyLlama, integrating a powerful AI into your app takes just 3 lines of code.

## Features
- **Incredibly Simple API:** Built with pure Swift, abstracting away the complexities of `llama.cpp`.
- **Combine & SwiftUI Ready:** The `EasyLlama` class is an `ObservableObject` and tracks the model status (`loading`, `loaded`, `generating`) for seamless UI updates.
- **Async/Await Support:** Generate text efficiently using modern Swift `AsyncStream`.
- **On-Device & Offline:** Everything runs 100% locally on Apple Silicon (using Metal for GPU acceleration).

## Installation

Add EasyLlama to your project using Swift Package Manager.

1. In Xcode, go to **File** -> **Add Package Dependencies...**
2. Paste the repository URL: `https://github.com/omidshz100/EasyLlama.git`
3. Add the package to your app target.

## Usage

### 1. Add your Model
Drag and drop your `.gguf` model file (e.g., `gemma-3-4b-it.Q4_K_M.gguf`) straight into your Xcode project. Make sure it is added to your app target so it gets bundled with the app.

### 2. Load the Model and Generate Text

```swift
import SwiftUI
import EasyLlama

struct ChatView: View {
    // EasyLlama is a singleton and ObservableObject!
    @StateObject private var llama = EasyLlama.shared
    
    var body: some View {
        VStack {
            Text("Status: \(llama.status)")
            
            Button("Ask Question") {
                Task {
                    // 1. Load the model (Only takes a few seconds)
                    try? await llama.loadModel(name: "gemma-3-4b-it.Q4_K_M")
                    
                    // 2. Generate text as a continuous stream!
                    let stream = try await llama.generate(prompt: "What is the capital of France?")
                    for try await token in stream {
                        print(token, terminator: "")
                    }
                }
            }
        }
    }
}
```

## Requirements
- **iOS 17.0+**
- **macOS 14.0+**

## License
This project is open-source and free to use.
