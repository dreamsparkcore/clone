//
//  ContentView.swift
//  Cal AI
//
//  Created by Alex Slater on 19/8/25.
//

import SwiftUI
import AVFoundation
import UIKit
import PhotosUI

// MARK: - Main View

struct HomeView: View {
    @State private var showSourceMenu = false
    @State private var showCamera = false
    @State private var showPhotoPicker = false

    @State private var isAnalyzing = false
    @State private var capturedImage: UIImage?
    @State private var result: AnalysisResult?
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            HStack {
                Image("calai")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40)
            }
            Spacer()

            if let img = capturedImage {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 350)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.bottom, 10)
            }

            if isAnalyzing {
                ProgressView("Analyzing…")
                    .padding(.bottom, 8)
            }

            if let r = result {
                VStack(spacing: 6) {
                    Text(r.foodName)
                        .font(.headline)
                    Text("\(r.calories) kcal (estimate)")
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 10)
            }

            if let err = errorMessage {
                Text(err)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
            }

            Button {
                errorMessage = nil
                result = nil
                showSourceMenu = true
            } label: {
                Image(systemName: "camera.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80)
                    .foregroundColor(.red)
            }
        }
        .confirmationDialog("Add a photo", isPresented: $showSourceMenu, titleVisibility: .visible) {
            Button("Take Photo") { showCamera = true }
            Button("Choose from Library") { showPhotoPicker = true }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $showCamera) {
            CameraPicker(image: $capturedImage) { image in
                Task { await analyze(image: image) }
            }
        }
        .sheet(isPresented: $showPhotoPicker) {
            PhotoLibraryPicker { image in
                self.capturedImage = image
                Task { await analyze(image: image) }
            }
        }
        .padding()
    }

    // MARK: - Analyze with ChatGPT API

    private func analyze(image: UIImage) async {
        isAnalyzing = true
        defer { isAnalyzing = false }

        do {
            let analysis = try await OpenAIClient.shared.analyzeFood(from: image)
            self.result = analysis
        } catch {
            self.errorMessage = (error as? LocalizedError)?.errorDescription
                ?? "Failed to analyze the image. \(error.localizedDescription)"
        }
    }
}

// MARK: - Result Model

struct AnalysisResult: Codable {
    let foodName: String
    let calories: Int
}

// MARK: - OpenAI Client (no external packages)

final class OpenAIClient {
    static let shared = OpenAIClient()

    // TODO: Move to secure storage (e.g., Keychain)
    private let apiKey: String = "open-ai-key-here"
    private init() {}

    /// Sends an image to the Chat Completions API and asks for strict JSON back.
    func analyzeFood(from image: UIImage) async throws -> AnalysisResult {
        guard let jpegData = image.jpegData(compressionQuality: 0.85) else {
            throw SimpleError("Could not convert image to JPEG.")
        }
        let base64 = jpegData.base64EncodedString()
        let dataURL = "data:image/jpeg;base64,\(base64)"

        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let systemPrompt = """
        You are a nutrition assistant. Look at the photo and identify the SINGLE most likely primary food item and estimate total calories for the visible serving. Respond ONLY as a compact JSON object with keys: "food_name" (string) and "calories" (integer). No extra text.
        """

        let userText = """
        Identify the main food and estimate calories for the visible portion. If multiple items, pick the dominant one.
        """

        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "response_format": ["type": "json_object"],
            "messages": [
                [
                    "role": "system",
                    "content": [
                        ["type": "text", "text": systemPrompt]
                    ]
                ],
                [
                    "role": "user",
                    "content": [
                        ["type": "text", "text": userText],
                        ["type": "image_url", "image_url": ["url": dataURL]]
                    ]
                ]
            ],
            "temperature": 0.2
        ]

        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            let serverText = String(data: data, encoding: .utf8) ?? "<no body>"
            throw SimpleError("API error. Status: \((resp as? HTTPURLResponse)?.statusCode ?? -1). Body: \(serverText)")
        }

        // Decode model response
        let decoded = try JSONDecoder().decode(ChatCompletionsResponse.self, from: data)

        // Extract the JSON string from either a plain string or a parts array
        let jsonString: String
        if let msg = decoded.choices.first?.message {
            switch msg.content {
            case .string(let s):
                jsonString = s
            case .parts(let parts):
                if let s = parts.first(where: { ($0.text?.isEmpty == false) })?.text {
                    jsonString = s
                } else {
                    throw SimpleError("No text content returned.")
                }
            }
        } else {
            throw SimpleError("Empty response.")
        }

        struct ModelJSON: Decodable { let food_name: String; let calories: Int }
        guard let jsonData = jsonString.data(using: .utf8) else { throw SimpleError("Bad JSON encoding.") }
        let modelOut = try JSONDecoder().decode(ModelJSON.self, from: jsonData)

        return AnalysisResult(foodName: modelOut.food_name, calories: modelOut.calories)
    }
}

// MARK: - Minimal types to parse Chat Completions response (Decodable-only)

struct ChatCompletionsResponse: Decodable {
    let choices: [Choice]

    struct Choice: Decodable {
        let message: Message
    }

    struct Message: Decodable {
        let content: MessageContent

        private enum CodingKeys: String, CodingKey { case content }

        init(from decoder: Decoder) throws {
            // Try keyed container first ({"content": ...})
            let keyed = try decoder.container(keyedBy: CodingKeys.self)
            if let str = try? keyed.decode(String.self, forKey: .content) {
                content = .string(str)
                return
            }
            if let parts = try? keyed.decode([ContentPart].self, forKey: .content) {
                content = .parts(parts)
                return
            }
            // Fallback to single-value container if shape differs
            if let single = try? decoder.singleValueContainer() {
                if let str = try? single.decode(String.self) {
                    content = .string(str)
                    return
                }
                if let parts = try? single.decode([ContentPart].self) {
                    content = .parts(parts)
                    return
                }
            }
            throw DecodingError.typeMismatch(
                String.self,
                .init(codingPath: decoder.codingPath, debugDescription: "Unsupported content shape")
            )
        }
    }

    enum MessageContent {
        case string(String)
        case parts([ContentPart])
    }

    struct ContentPart: Decodable {
        let type: String?
        let text: String?
    }
}

// MARK: - Camera Picker (UIKit bridge)

struct CameraPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var onCapture: (UIImage) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraPicker
        init(_ parent: CameraPicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            picker.dismiss(animated: true)
            if let img = info[ .originalImage ] as? UIImage {
                parent.image = img
                parent.onCapture(img)
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

// MARK: - Photo Library Picker (PHPicker)

struct PhotoLibraryPicker: UIViewControllerRepresentable {
    var onPick: (UIImage) -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoLibraryPicker
        init(_ parent: PhotoLibraryPicker) { self.parent = parent }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let provider = results.first?.itemProvider else { return }

            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { object, _ in
                    if let image = object as? UIImage {
                        DispatchQueue.main.async {
                            self.parent.onPick(image)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Simple Error

struct SimpleError: LocalizedError {
    let message: String
    init(_ message: String) { self.message = message }
    var errorDescription: String? { message }
}

// MARK: - Preview
