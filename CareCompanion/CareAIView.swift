
import SwiftUI
import Supabase

// MARK: - Chat Message

struct CareChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let isWelcome: Bool

    init(
        text: String,
        isUser: Bool,
        isWelcome: Bool = false
    ) {
        self.text = text
        self.isUser = isUser
        self.isWelcome = isWelcome
    }
}

// MARK: - AI Response

struct CareAIResponse: Decodable {
    let reply: String
}

// MARK: - Care Companion AI

struct CareAIView: View {

    @ObservedObject private var languageManager =
        LanguageManager.shared

    @ObservedObject private var locationManager =
        CareLocationManager.shared

    @State private var messages: [CareChatMessage] = []

    @State private var question = ""
    @State private var isSending = false

    @State private var showMap = false
    @State private var mapQuery = "Healthcare clinics"
    @State private var mapLocation = ""

    @State private var detectedSearch: CareSearchIntent?

    private let teal = Color.teal

    var body: some View {

        VStack(spacing: 0) {

            chatHistory

            Divider()

            quickActions

            inputBar
        }
        .navigationTitle(languageManager.text("ai"))
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
        .navigationDestination(isPresented: $showMap) {

            CareMapView(
                initialQuery: mapQuery,
                initialLocation: mapLocation
            )
        }
        .task {

            if !locationManager.hasLocation {
                await locationManager.loadProfile()
            }
        }
        .onAppear {

            if messages.isEmpty {

                messages.append(
                    CareChatMessage(
                        text: welcomeMessage,
                        isUser: false,
                        isWelcome: true
                    )
                )
            }
        }
    }

    // MARK: - Welcome Message

    private var welcomeMessage: String {

        switch languageManager.language {

        case "sw":
            return """
            Habari! Mimi ni msaidizi wako wa Care Companion.
            Ninaweza kukusaidia kupata huduma za afya,
            chakula, makazi ya dharura na huduma za jamii.
            """

        case "es":
            return """
            ¡Hola! Soy tu asistente de Care Companion.
            Puedo ayudarte a encontrar atención médica,
            alimentos, refugios y recursos comunitarios.
            """

        case "fr":
            return """
            Bonjour ! Je suis votre assistant Care Companion.
            Je peux vous aider à trouver des soins,
            de la nourriture et des abris d'urgence.
            """

        case "ar":
            return """
            مرحبًا! أنا مساعد Care Companion.
            يمكنني مساعدتك في العثور على الرعاية الصحية
            والغذاء وملاجئ الطوارئ والخدمات المجتمعية.
            """

        case "pt":
            return """
            Olá! Sou seu assistente Care Companion.
            Posso ajudar a encontrar saúde, alimentos
            e abrigos de emergência.
            """

        case "hi":
            return """
            नमस्ते! मैं आपका Care Companion सहायक हूँ।
            मैं स्वास्थ्य सेवाएँ, भोजन सहायता और
            आपातकालीन आश्रय खोजने में मदद कर सकता हूँ।
            """

        case "zh":
            return """
            你好！我是 Care Companion AI 助手。
            我可以帮助你寻找医疗服务、
            食物援助和紧急避难所。
            """

        case "de":
            return """
            Hallo! Ich bin dein Care Companion.
            Ich helfe dir, medizinische Versorgung,
            Lebensmittelhilfe und Notunterkünfte zu finden.
            """

        case "tr":
            return """
            Merhaba! Ben Care Companion asistanınızım.
            Sağlık hizmetleri, gıda yardımı ve
            acil barınaklar bulmanıza yardımcı olabilirim.
            """

        case "ru":
            return """
            Здравствуйте! Я помощник Care Companion.
            Я помогу найти медицинскую помощь,
            продовольственную поддержку и убежища.
            """

        case "ja":
            return """
            こんにちは！Care Companion AIです。
            医療サービス、食料支援、
            緊急避難所を探すお手伝いをします。
            """

        default:
            return """
            Hello! I'm your Care Companion AI Assistant.
            Ask me about healthcare, food assistance,
            emergency shelters, or community resources.
            """
        }
    }

    // MARK: - Chat History

    private var chatHistory: some View {

        ScrollViewReader { proxy in

            ScrollView {

                LazyVStack(spacing: 14) {

                    ForEach(messages) { message in

                        messageBubble(message)
                            .id(message.id)
                    }

                    if isSending {

                        HStack {

                            ProgressView("Thinking...")

                            Spacer()
                        }
                        .padding()
                    }
                }
                .padding()
            }
            .onChange(of: messages.count) { _, _ in

                if let last = messages.last {

                    withAnimation {

                        proxy.scrollTo(
                            last.id,
                            anchor: .bottom
                        )
                    }
                }
            }
        }
    }

    // MARK: - Message Bubble

    private func messageBubble(
        _ message: CareChatMessage
    ) -> some View {

        HStack {

            if message.isUser {
                Spacer(minLength: 40)
            }

            Text(message.text)
                .textSelection(.enabled)
                .padding(14)
                .background(
                    message.isUser
                    ? teal
                    : Color(.secondarySystemGroupedBackground)
                )
                .foregroundStyle(
                    message.isUser
                    ? Color.white
                    : Color.primary
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 16)
                )

            if !message.isUser {
                Spacer(minLength: 40)
            }
        }
    }

    // MARK: - Quick Map Actions

    private var quickActions: some View {

        ScrollView(
            .horizontal,
            showsIndicators: false
        ) {

            HStack(spacing: 10) {

                if let search = detectedSearch {

                    quickAction(
                        "📍 \(search.service)",
                        icon: "map.fill"
                    ) {

                        openMap(
                            search.service,
                            location: search.location
                        )
                    }
                }

                quickAction(
                    languageManager.text("healthcare"),
                    icon: "cross.case.fill"
                ) {
                    openMap("Healthcare clinics")
                }

                quickAction(
                    languageManager.text("food"),
                    icon: "fork.knife"
                ) {
                    openMap("Food banks")
                }

                quickAction(
                    languageManager.text("maternal"),
                    icon: "heart.fill"
                ) {
                    openMap("Maternity hospitals")
                }

                quickAction(
                    languageManager.text("shelters"),
                    icon: "house.fill"
                ) {
                    openMap("Emergency shelters")
                }

                quickAction(
                    languageManager.text("map"),
                    icon: "map.fill"
                ) {
                    openMap("Community support")
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
    }

    private func quickAction(
        _ title: String,
        icon: String,
        action: @escaping () -> Void
    ) -> some View {

        Button(action: action) {

            Label(
                title,
                systemImage: icon
            )
            .font(.caption.bold())
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
        }
        .buttonStyle(.bordered)
        .tint(.teal)
    }

    // MARK: - Message Input

    private var inputBar: some View {

        HStack(spacing: 12) {

            TextField(
                "Ask Care Companion...",
                text: $question,
                axis: .vertical
            )
            .lineLimit(1...4)
            .textFieldStyle(.roundedBorder)

            Button {

                Task {
                    await sendMessage()
                }

            } label: {

                Image(
                    systemName: "arrow.up.circle.fill"
                )
                .font(.system(size: 34))
                .foregroundStyle(teal)
            }
            .disabled(
                isSending ||
                question.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ).isEmpty
            )
        }
        .padding()
        .background(Color(.systemBackground))
    }

    // MARK: - Smart Location Map

    private func openMap(
        _ query: String,
        location: String = ""
    ) {

        mapQuery = query

        // Use the location from the user's question.
        // If none was given, use their Supabase profile.

        mapLocation = location.isEmpty
            ? locationManager.locationText
            : location

        showMap = true
    }

    // MARK: - Send Message

    @MainActor
    private func sendMessage() async {

        let text = question.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !text.isEmpty, !isSending else {
            return
        }

        messages.append(
            CareChatMessage(
                text: text,
                isUser: true
            )
        )

        detectedSearch = CareSearchIntent.detect(
            from: text
        )

        question = ""
        isSending = true

        defer {
            isSending = false
        }

        let recentMessages = messages
            .filter { !$0.isWelcome }
            .suffix(10)

        let history = recentMessages.map { message in

            let role = message.isUser
                ? "User"
                : "Assistant"

            return "\(role): \(message.text)"
        }
        .joined(separator: "\n")

        let savedLocation = locationManager.hasLocation
            ? locationManager.locationText
            : "Not provided"

        let requestText = """
        You are Care Companion, a worldwide
        healthcare and community assistance AI.

        Respond in \(languageManager.languageName).
        Use the selected language unless the
        user explicitly requests another language.

        The user's saved profile location is:
        \(savedLocation)

        Use this location when the user asks
        about nearby services without naming
        another city or country.

        If the user specifies a different
        location, use their requested location.

        If no location is known, ask for
        the user's city and country.

        You help users with:
        - Hospitals and healthcare clinics
        - Food banks and food assistance
        - Maternal care
        - Senior support
        - Family and foster care
        - Pharmacies
        - Mental health services
        - Emergency shelters
        - Tornadoes, hurricanes and floods
        - Community resources worldwide

        Do not invent addresses, phone numbers,
        opening hours or shelter availability.

        For emergencies, recommend contacting
        local emergency services and following
        official alerts and evacuation guidance.

        Conversation:
        \(history)

        Respond to the latest user message.
        """

        guard requestText.count <= 8000 else {

            messages.append(
                CareChatMessage(
                    text: """
                    This conversation is getting long.
                    Please start a new chat to continue.
                    """,
                    isUser: false
                )
            )
            return
        }

        do {

            let response: CareAIResponse =
                try await SupabaseManager.client.functions.invoke(
                    "care-ai",
                    options: FunctionInvokeOptions(
                        body: ["message": requestText]
                    )
                )

            messages.append(
                CareChatMessage(
                    text: response.reply,
                    isUser: false
                )
            )

        } catch {

            print("Care AI error:", error)

            messages.append(
                CareChatMessage(
                    text: """
                    Sorry, I couldn't connect to the AI service.
                    Please try again.
                    """,
                    isUser: false
                )
            )
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CareAIView()
    }
}
