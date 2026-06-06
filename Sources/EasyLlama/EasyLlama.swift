import Foundation
import Combine
import SwiftLlama

@MainActor
public class EasyLlama: ObservableObject {
    public static let shared = EasyLlama()
    
    @Published public var status: String = "notLoaded"
    private var llamaService: LlamaService?
    
    // We keep track of the generation task so we can cancel it
    private var generationTask: Task<Void, Error>?
    private var isCancelled = false
    
    public init() {}
    
    public func loadModel(name: String, batchSize: UInt32 = 512, maxTokenCount: UInt32 = 2048, useGPU: Bool = true) async throws {
        // If already loaded, skip
        guard llamaService == nil else { return }
        
        await MainActor.run { self.status = "loading" }
        
        // Find the model in the main bundle
        guard let modelUrl = Bundle.main.url(forResource: name, withExtension: "gguf") else {
            await MainActor.run { self.status = "failedLoading" }
            throw NSError(domain: "EasyLlama", code: 404, userInfo: [NSLocalizedDescriptionKey: "GGUF model file '\(name).gguf' not found in App Bundle. Please drag and drop it into Xcode."])
        }
        
        let config = LlamaConfig(
            batchSize: batchSize,
            maxTokenCount: maxTokenCount,
            useGPU: useGPU
        )
        
        let service = LlamaService(modelUrl: modelUrl, config: config)
        self.llamaService = service
        await MainActor.run { self.status = "loaded" }
    }
    
    public func generate(prompt: String, systemPrompt: String = "You are a helpful assistant.", temperature: Float = 0.7, topP: Float = 0.9, topK: Int32 = 40) async throws -> AsyncStream<String> {
        guard let service = llamaService else {
            throw NSError(domain: "EasyLlama", code: 400, userInfo: [NSLocalizedDescriptionKey: "Model is not loaded."])
        }
        
        await MainActor.run { self.status = "generating" }
        self.isCancelled = false
        
        let messages = [
            LlamaChatMessage(role: .system, content: systemPrompt),
            LlamaChatMessage(role: .user, content: prompt)
        ]
        
        let samplingConfig = LlamaSamplingConfig(
            temperature: temperature,
            seed: UInt32.random(in: 0...10000),
            topP: topP,
            topK: topK,
            minKeep: 1
        )
        
        let internalStream = try await service.streamCompletion(of: messages, samplingConfig: samplingConfig)
        
        return AsyncStream { continuation in
            generationTask = Task {
                for try await token in internalStream {
                    if isCancelled { break }
                    continuation.yield(token)
                }
                continuation.finish()
                Task { @MainActor in self.status = "loaded" }
            }
        }
    }
    
    public func stop() { 
        self.isCancelled = true
        generationTask?.cancel()
        Task { @MainActor in self.status = "loaded" }
    }
    
    public func unloadModel() {
        self.llamaService = nil
        Task { @MainActor in self.status = "notLoaded" }
    }
}
