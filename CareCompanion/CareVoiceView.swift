
import SwiftUI
import Combine
import Speech
import AVFoundation
import Supabase

// MARK: - Voice Manager

@MainActor
final class CareVoiceManager: ObservableObject {

    @Published var transcript = ""
    @Published var aiResponse = ""
    @Published var isRecording = false
    @Published var isThinking = false
    @Published var isSpeaking = false
    @Published var errorMessage = ""

    private let speechRecognizer = SFSpeechRecognizer(
        locale: Locale(identifier: "en-US")
    )

    private let audioEngine = AVAudioEngine()
    private let speechSynthesizer = AVSpeechSynthesizer()

    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    // MARK: - Permissions

    func requestPermissions() async -> Bool {

        let speechAllowed = await withCheckedContinuation {
            (continuation: CheckedContinuation<Bool, Never>) in

            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(
                    returning: status == .authorized
                )
            }
        }

        guard speechAllowed else {
            errorMessage = "Speech recognition permission is required."
            return false
        }

        let microphoneAllowed = await AVAudioApplication
            .requestRecordPermission()

        guard microphoneAllowed else {
            errorMessage = "Microphone permission is required."
            return false
        }

        return true
    }

    // MARK: - Start Recording

    func startRecording() async {

        guard !isRecording else { return }

        let allowed = await requestPermissions()
        guard allowed else { return }

        stopSpeaking()
        stopRecording()

        transcript = ""
        aiResponse = ""
        errorMessage = ""

        guard let speechRecognizer,
              speechRecognizer.isAvailable else {
            errorMessage = "Speech recognition is unavailable."
            return
        }

        do {

            let audioSession = AVAudioSession.sharedInstance()

            try audioSession.setCategory(
                .playAndRecord,
                mode: .default,
                options: [
                    .defaultToSpeaker,
                    .allowBluetoothHFP
                ]
            )

            try audioSession.setActive(true)

            let request = SFSpeechAudioBufferRecognitionRequest()
            request.shouldReportPartialResults = true

            recognitionRequest = request

            let inputNode = audioEngine.inputNode
            let format = inputNode.outputFormat(forBus: 0)

            inputNode.installTap(
                onBus: 0,
                bufferSize: 1024,
                format: format
            ) { buffer, _ in
                request.append(buffer)
            }

            recognitionTask = speechRecognizer.recognitionTask(
                with: request
            ) { [weak self] result, error in

                Task { @MainActor in

                    guard let self else { return }

                    if let result {
                        self.transcript = result.bestTranscription
                            .formattedString
                    }

                    if let error,
                       self.isRecording {
                        self.errorMessage = error.localizedDescription
                        self.stopRecording()
                    }
                }
            }

            audioEngine.prepare()
            try audioEngine.start()

            isRecording = true

        } catch {
            errorMessage = "Unable to start recording: \(error.localizedDescription)"
            stopRecording()
        }
    }

    // MARK: - Stop Recording

    func stopRecording() {

        if audioEngine.isRunning {
            audioEngine.stop()
        }

        audioEngine.inputNode.removeTap(onBus: 0)

        recognitionRequest?.endAudio()
        recognitionTask?.cancel()

        recognitionTask = nil
        recognitionRequest = nil

        isRecording = false
    }

    // MARK: - Ask AI

    func askAI() async {

        let question = transcript.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !question.isEmpty else {
            errorMessage = "Record a question or type one first."
            return
        }

        stopRecording()
        stopSpeaking()

        isThinking = true
        errorMessage = ""
        aiResponse = ""

        defer {
            isThinking = false
        }

        do {

            let response: VoiceAIResponse = try await
                SupabaseManager.client.functions.invoke(
                    "care-ai",
                    options: FunctionInvokeOptions(
                        body: [
                            "message": """
                            You are Care Companion, a supportive AI
                            assistant helping people find healthcare,
                            education, family resources, and community
                            services.

                            Answer clearly and concisely.
                            Do not claim to be a doctor.
                            For immediate emergencies, advise contacting
                            local emergency services.

                            User question:
                            \(question)
                            """
                        ]
                    )
                )

            aiResponse = response.reply
            speak(response.reply)

        } catch {
            errorMessage = "AI request failed: \(error.localizedDescription)"
        }
    }

    // MARK: - Text to Speech

    func speak(_ text: String) {

        guard !text.isEmpty else { return }

        speechSynthesizer.stopSpeaking(at: .immediate)

        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.48
        utterance.pitchMultiplier = 1.0
        utterance.voice = AVSpeechSynthesisVoice(
            language: "en-US"
        )

        speechSynthesizer.speak(utterance)
        isSpeaking = true
    }

    func stopSpeaking() {
        speechSynthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
    }

    func clearConversation() {
        stopRecording()
        stopSpeaking()

        transcript = ""
        aiResponse = ""
        errorMessage = ""
        isThinking = false
    }
}

// MARK: - AI Response Model

private struct VoiceAIResponse: Decodable {
    let reply: String
}

// MARK: - Voice AI Screen

struct CareVoiceView: View {

    @StateObject private var voice = CareVoiceManager()

    private let teal = Color(
        red: 0.05,
        green: 0.58,
        blue: 0.53
    )

    var body: some View {

        ScrollView {

            VStack(spacing: 24) {

                header

                recordingCard

                questionCard

                if !voice.aiResponse.isEmpty {
                    responseCard
                }

                if !voice.errorMessage.isEmpty {
                    errorCard
                }

                clearButton

                Text(
                    "Care Companion AI provides general information, " +
                    "not professional medical advice. " +
                    "For emergencies, contact local emergency services."
                )
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            }
            .padding(20)
        }
        .background(
            Color(red: 0.96, green: 0.98, blue: 0.97)
                .ignoresSafeArea()
        )
        .navigationTitle("Voice AI")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            voice.stopRecording()
            voice.stopSpeaking()
        }
    }

    // MARK: - Header

    private var header: some View {

        VStack(spacing: 12) {

            Image(systemName: "waveform.circle.fill")
                .font(.system(size: 75))
                .foregroundStyle(teal)

            Text("Talk to Care Companion")
                .font(.title.bold())
                .multilineTextAlignment(.center)

            Text(
                "Ask your questions using your voice. " +
                "Care Companion can listen and respond."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }

    // MARK: - Recording Card

    private var recordingCard: some View {

        VStack(spacing: 18) {

            Image(
                systemName: voice.isRecording
                    ? "waveform"
                    : "mic.fill"
            )
            .font(.system(size: 45))
            .foregroundStyle(
                voice.isRecording ? .red : teal
            )
            .frame(width: 110, height: 110)
            .background(
                voice.isRecording
                    ? Color.red.opacity(0.10)
                    : teal.opacity(0.10)
            )
            .clipShape(Circle())

            Text(
                voice.isRecording
                    ? "Listening..."
                    : "Ready to listen"
            )
            .font(.headline)

            Button {

                Task {
                    if voice.isRecording {
                        voice.stopRecording()
                    } else {
                        await voice.startRecording()
                    }
                }

            } label: {

                Label(
                    voice.isRecording
                        ? "Stop Recording"
                        : "Start Recording",
                    systemImage: voice.isRecording
                        ? "stop.fill"
                        : "mic.fill"
                )
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    voice.isRecording ? Color.red : teal
                )
                .foregroundStyle(.white)
                .clipShape(
                    RoundedRectangle(cornerRadius: 14)
                )
            }
        }
        .padding(22)
        .frame(maxWidth: .infinity)
        .background(.white)
        .clipShape(
            RoundedRectangle(cornerRadius: 20)
        )
    }

    // MARK: - Question Card

    private var questionCard: some View {

        VStack(alignment: .leading, spacing: 14) {

            Label(
                "Your Question",
                systemImage: "text.bubble.fill"
            )
            .font(.headline)

            TextEditor(text: $voice.transcript)
                .frame(height: 120)
                .scrollContentBackground(.hidden)
                .padding(8)
                .background(
                    Color.gray.opacity(0.07)
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 12)
                )

            Text(
                "Your recorded words will appear here. " +
                "You can also type or edit your question."
            )
            .font(.caption)
            .foregroundStyle(.secondary)

            Button {

                Task {
                    await voice.askAI()
                }

            } label: {

                HStack(spacing: 10) {

                    if voice.isThinking {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "sparkles")
                    }

                    Text(
                        voice.isThinking
                            ? "Thinking..."
                            : "Ask Care AI"
                    )
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(teal)
                .foregroundStyle(.white)
                .clipShape(
                    RoundedRectangle(cornerRadius: 14)
                )
            }
            .disabled(
                voice.isThinking ||
                voice.transcript.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ).isEmpty
            )
        }
        .padding(20)
        .background(.white)
        .clipShape(
            RoundedRectangle(cornerRadius: 20)
        )
    }

    // MARK: - Response Card

    private var responseCard: some View {

        VStack(alignment: .leading, spacing: 16) {

            Label(
                "Care AI Response",
                systemImage: "sparkles"
            )
            .font(.headline)
            .foregroundStyle(teal)

            Text(voice.aiResponse)
                .font(.body)
                .textSelection(.enabled)

            HStack(spacing: 12) {

                Button {
                    voice.speak(voice.aiResponse)
                } label: {
                    Label(
                        "Read Aloud",
                        systemImage: "speaker.wave.2.fill"
                    )
                }

                Spacer()

                Button {
                    voice.stopSpeaking()
                } label: {
                    Label(
                        "Stop",
                        systemImage: "stop.circle"
                    )
                }
            }
            .font(.subheadline.bold())
            .foregroundStyle(teal)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .clipShape(
            RoundedRectangle(cornerRadius: 20)
        )
    }

    // MARK: - Error Card

    private var errorCard: some View {

        Label(
            voice.errorMessage,
            systemImage: "exclamationmark.triangle.fill"
        )
        .font(.subheadline)
        .foregroundStyle(.red)
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Color.red.opacity(0.08)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 12)
        )
    }

    // MARK: - Clear Button

    private var clearButton: some View {

        Button {
            voice.clearConversation()
        } label: {
            Label(
                "New Conversation",
                systemImage: "arrow.clockwise"
            )
            .font(.subheadline.bold())
            .foregroundStyle(teal)
        }
        .padding(.top, 6)
    }
}

#Preview {
    NavigationStack {
        CareVoiceView()
    }
}
