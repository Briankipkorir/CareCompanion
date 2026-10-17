
import SwiftUI
import Combine

@MainActor
final class LanguageManager: ObservableObject {

    static let shared = LanguageManager()

    @Published var language: String {
        didSet {
            UserDefaults.standard.set(
                language,
                forKey: "careLanguage"
            )
        }
    }

    let languages: [(code: String, name: String)] = [
        ("en", "English"),
        ("sw", "Kiswahili"),
        ("es", "Español"),
        ("fr", "Français"),
        ("ar", "العربية"),
        ("pt", "Português"),
        ("hi", "हिन्दी"),
        ("zh", "中文"),
        ("de", "Deutsch"),
        ("tr", "Türkçe"),
        ("ru", "Русский"),
        ("ja", "日本語")
    ]

    private init() {
        language = UserDefaults.standard.string(
            forKey: "careLanguage"
        ) ?? "en"
    }

    var languageName: String {
        languages.first {
            $0.code == language
        }?.name ?? "English"
    }

    func text(_ key: String) -> String {
        let translations = Self.translations[key]
            ?? [:]

        return translations[language]
            ?? translations["en"]
            ?? key
    }

    private static let translations:
        [String: [String: String]] = [

        "welcome": [
            "en": "Welcome to Care Companion",
            "sw": "Karibu Care Companion",
            "es": "Bienvenido a Care Companion",
            "fr": "Bienvenue sur Care Companion",
            "ar": "مرحبًا بك في Care Companion",
            "pt": "Bem-vindo ao Care Companion",
            "hi": "Care Companion में आपका स्वागत है",
            "zh": "欢迎使用 Care Companion",
            "de": "Willkommen bei Care Companion",
            "tr": "Care Companion'a hoş geldiniz",
            "ru": "Добро пожаловать в Care Companion",
            "ja": "Care Companionへようこそ"
        ],

        "tagline": [
            "en": "Your care. Your language. Your community.",
            "sw": "Huduma yako. Lugha yako. Jamii yako.",
            "es": "Tu atención. Tu idioma. Tu comunidad.",
            "fr": "Vos soins. Votre langue. Votre communauté.",
            "ar": "رعايتك. لغتك. مجتمعك.",
            "pt": "Seu cuidado. Seu idioma. Sua comunidade.",
            "hi": "आपकी देखभाल। आपकी भाषा। आपका समुदाय।",
            "zh": "您的关怀。您的语言。您的社区。",
            "de": "Ihre Versorgung. Ihre Sprache. Ihre Gemeinschaft.",
            "tr": "Sizin bakımınız. Sizin diliniz. Sizin topluluğunuz.",
            "ru": "Ваша забота. Ваш язык. Ваше сообщество.",
            "ja": "あなたのケア。あなたの言語。あなたの地域。"
        ],

        "ai": [
            "en": "AI Care Assistant",
            "sw": "Msaidizi wa AI",
            "es": "Asistente de IA",
            "fr": "Assistant IA",
            "ar": "مساعد الذكاء الاصطناعي",
            "pt": "Assistente de IA",
            "hi": "एआई सहायक",
            "zh": "AI 助手",
            "de": "KI-Assistent",
            "tr": "Yapay Zekâ Asistanı",
            "ru": "ИИ-помощник",
            "ja": "AIアシスタント"
        ],

        "healthcare": [
            "en": "Healthcare",
            "sw": "Huduma za Afya",
            "es": "Atención médica",
            "fr": "Soins de santé",
            "ar": "الرعاية الصحية",
            "pt": "Cuidados de saúde",
            "hi": "स्वास्थ्य सेवा",
            "zh": "医疗服务",
            "de": "Gesundheitsversorgung",
            "tr": "Sağlık hizmetleri",
            "ru": "Медицинская помощь",
            "ja": "医療サービス"
        ],

        "food": [
            "en": "Food Banks",
            "sw": "Benki za Chakula",
            "es": "Bancos de alimentos",
            "fr": "Banques alimentaires",
            "ar": "بنوك الطعام",
            "pt": "Bancos de alimentos",
            "hi": "खाद्य बैंक",
            "zh": "食物银行",
            "de": "Lebensmittelbanken",
            "tr": "Gıda bankaları",
            "ru": "Продовольственные банки",
            "ja": "フードバンク"
        ],

        "maternal": [
            "en": "Maternal Care",
            "sw": "Huduma za Wajawazito",
            "es": "Atención materna",
            "fr": "Soins maternels",
            "ar": "رعاية الأمومة",
            "pt": "Cuidados maternos",
            "hi": "मातृत्व देखभाल",
            "zh": "孕产妇护理",
            "de": "Schwangerschaftsbetreuung",
            "tr": "Anne sağlığı",
            "ru": "Помощь матерям",
            "ja": "母子保健"
        ],

        "senior": [
            "en": "Senior Support",
            "sw": "Msaada kwa Wazee",
            "es": "Apoyo a mayores",
            "fr": "Aide aux personnes âgées",
            "ar": "دعم كبار السن",
            "pt": "Apoio a idosos",
            "hi": "वरिष्ठ नागरिक सहायता",
            "zh": "老年人支持",
            "de": "Seniorenhilfe",
            "tr": "Yaşlı desteği",
            "ru": "Поддержка пожилых",
            "ja": "高齢者支援"
        ],

        "foster": [
            "en": "Family & Foster Support",
            "sw": "Msaada wa Familia",
            "es": "Apoyo familiar",
            "fr": "Soutien familial",
            "ar": "دعم الأسرة",
            "pt": "Apoio familiar",
            "hi": "परिवार सहायता",
            "zh": "家庭支持",
            "de": "Familienhilfe",
            "tr": "Aile desteği",
            "ru": "Поддержка семей",
            "ja": "家族支援"
        ],

        "shelters": [
            "en": "Emergency Shelters",
            "sw": "Makazi ya Dharura",
            "es": "Refugios de emergencia",
            "fr": "Abris d'urgence",
            "ar": "ملاجئ الطوارئ",
            "pt": "Abrigos de emergência",
            "hi": "आपातकालीन आश्रय",
            "zh": "紧急避难所",
            "de": "Notunterkünfte",
            "tr": "Acil durum barınakları",
            "ru": "Экстренные убежища",
            "ja": "緊急避難所"
        ],

        "emergency": [
            "en": "Emergency & Disaster Help",
            "sw": "Msaada wa Dharura",
            "es": "Ayuda de emergencia",
            "fr": "Aide d'urgence",
            "ar": "المساعدة في الطوارئ",
            "pt": "Ajuda de emergência",
            "hi": "आपातकालीन सहायता",
            "zh": "紧急援助",
            "de": "Notfallhilfe",
            "tr": "Acil yardım",
            "ru": "Экстренная помощь",
            "ja": "緊急支援"
        ],

        "map": [
            "en": "Find Places",
            "sw": "Tafuta Maeneo",
            "es": "Buscar lugares",
            "fr": "Trouver des lieux",
            "ar": "البحث عن أماكن",
            "pt": "Encontrar lugares",
            "hi": "स्थान खोजें",
            "zh": "查找地点",
            "de": "Orte finden",
            "tr": "Yerleri bul",
            "ru": "Найти места",
            "ja": "場所を探す"
        ],

        "directions": [
            "en": "Directions",
            "sw": "Maelekezo",
            "es": "Cómo llegar",
            "fr": "Itinéraire",
            "ar": "الاتجاهات",
            "pt": "Direções",
            "hi": "दिशा-निर्देश",
            "zh": "路线",
            "de": "Wegbeschreibung",
            "tr": "Yol tarifi",
            "ru": "Маршрут",
            "ja": "道順"
        ],

        "profile": [
            "en": "My Profile",
            "sw": "Wasifu Wangu",
            "es": "Mi perfil",
            "fr": "Mon profil",
            "ar": "ملفي الشخصي",
            "pt": "Meu perfil",
            "hi": "मेरी प्रोफ़ाइल",
            "zh": "我的资料",
            "de": "Mein Profil",
            "tr": "Profilim",
            "ru": "Мой профиль",
            "ja": "プロフィール"
        ],

        "appLanguage": [
            "en": "App Language",
            "sw": "Lugha ya Programu",
            "es": "Idioma de la aplicación",
            "fr": "Langue de l'application",
            "ar": "لغة التطبيق",
            "pt": "Idioma do aplicativo",
            "hi": "ऐप की भाषा",
            "zh": "应用语言",
            "de": "App-Sprache",
            "tr": "Uygulama dili",
            "ru": "Язык приложения",
            "ja": "アプリの言語"
        ],

        "search": [
            "en": "Search",
            "sw": "Tafuta",
            "es": "Buscar",
            "fr": "Rechercher",
            "ar": "بحث",
            "pt": "Pesquisar",
            "hi": "खोजें",
            "zh": "搜索",
            "de": "Suchen",
            "tr": "Ara",
            "ru": "Поиск",
            "ja": "検索"
        ],

        "openMaps": [
            "en": "Open in Apple Maps",
            "sw": "Fungua Apple Maps",
            "es": "Abrir Apple Maps",
            "fr": "Ouvrir Apple Maps",
            "ar": "افتح خرائط Apple",
            "pt": "Abrir Apple Maps",
            "hi": "Apple Maps खोलें",
            "zh": "打开 Apple 地图",
            "de": "Apple Karten öffnen",
            "tr": "Apple Haritalar'da aç",
            "ru": "Открыть Apple Maps",
            "ja": "Appleマップで開く"
        ],

        "noResults": [
            "en": "No places found. Try another search.",
            "sw": "Hakuna maeneo yaliyopatikana.",
            "es": "No se encontraron lugares.",
            "fr": "Aucun lieu trouvé.",
            "ar": "لم يتم العثور على أماكن.",
            "pt": "Nenhum local encontrado.",
            "hi": "कोई स्थान नहीं मिला।",
            "zh": "未找到地点。",
            "de": "Keine Orte gefunden.",
            "tr": "Yer bulunamadı.",
            "ru": "Места не найдены.",
            "ja": "場所が見つかりません。"
        ],

        "searchFailed": [
            "en": "Search failed. Try Apple Maps.",
            "sw": "Utafutaji umeshindwa. Jaribu Apple Maps.",
            "es": "La búsqueda falló. Prueba Apple Maps.",
            "fr": "Recherche échouée. Essayez Apple Maps.",
            "ar": "فشل البحث. جرّب خرائط Apple.",
            "pt": "Falha na busca. Tente Apple Maps.",
            "hi": "खोज विफल रही। Apple Maps आज़माएँ।",
            "zh": "搜索失败。请尝试 Apple 地图。",
            "de": "Suche fehlgeschlagen. Apple Karten versuchen.",
            "tr": "Arama başarısız. Apple Haritalar'ı deneyin.",
            "ru": "Ошибка поиска. Попробуйте Apple Maps.",
            "ja": "検索に失敗しました。Appleマップをお試しください。"
        ],

        "learning": [
            "en": "Language Learning",
            "sw": "Kujifunza Lugha",
            "es": "Aprender idiomas",
            "fr": "Apprentissage des langues",
            "ar": "تعلم اللغات",
            "pt": "Aprender idiomas",
            "hi": "भाषा सीखना",
            "zh": "语言学习",
            "de": "Sprachen lernen",
            "tr": "Dil öğrenme",
            "ru": "Изучение языков",
            "ja": "語学学習"
        ]
    ]
}
