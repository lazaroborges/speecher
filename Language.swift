import Foundation

struct Language: Identifiable, Hashable, CaseIterable {
    let id: String
    let code: String
    let name: String
    
    static let allCases: [Language] = [
        Language(id: "en", code: "en", name: "English"),
        Language(id: "pt", code: "pt", name: "Portuguese"),
        Language(id: "es", code: "es", name: "Spanish"),
        Language(id: "fr", code: "fr", name: "French"),
        Language(id: "de", code: "de", name: "German"),
        Language(id: "it", code: "it", name: "Italian"),
        Language(id: "ja", code: "ja", name: "Japanese"),
        Language(id: "ko", code: "ko", name: "Korean"),
        Language(id: "zh", code: "zh", name: "Chinese"),
        Language(id: "ru", code: "ru", name: "Russian"),
        Language(id: "ar", code: "ar", name: "Arabic"),
        Language(id: "hi", code: "hi", name: "Hindi"),
        Language(id: "tr", code: "tr", name: "Turkish"),
        Language(id: "pl", code: "pl", name: "Polish"),
        Language(id: "nl", code: "nl", name: "Dutch"),
        Language(id: "sv", code: "sv", name: "Swedish"),
        Language(id: "da", code: "da", name: "Danish"),
        Language(id: "no", code: "no", name: "Norwegian"),
        Language(id: "fi", code: "fi", name: "Finnish"),
        Language(id: "cs", code: "cs", name: "Czech"),
        Language(id: "hu", code: "hu", name: "Hungarian"),
        Language(id: "ro", code: "ro", name: "Romanian"),
        Language(id: "uk", code: "uk", name: "Ukrainian"),
        Language(id: "el", code: "el", name: "Greek"),
        Language(id: "bg", code: "bg", name: "Bulgarian"),
        Language(id: "hr", code: "hr", name: "Croatian"),
        Language(id: "sr", code: "sr", name: "Serbian"),
        Language(id: "sk", code: "sk", name: "Slovak"),
        Language(id: "sl", code: "sl", name: "Slovenian"),
        Language(id: "et", code: "et", name: "Estonian"),
        Language(id: "lv", code: "lv", name: "Latvian"),
        Language(id: "lt", code: "lt", name: "Lithuanian"),
        Language(id: "ca", code: "ca", name: "Catalan"),
        Language(id: "vi", code: "vi", name: "Vietnamese"),
        Language(id: "th", code: "th", name: "Thai"),
        Language(id: "id", code: "id", name: "Indonesian"),
        Language(id: "ms", code: "ms", name: "Malay"),
        Language(id: "he", code: "he", name: "Hebrew"),
        Language(id: "fa", code: "fa", name: "Persian"),
        Language(id: "ur", code: "ur", name: "Urdu"),
        Language(id: "bn", code: "bn", name: "Bengali"),
        Language(id: "ta", code: "ta", name: "Tamil"),
        Language(id: "te", code: "te", name: "Telugu"),
        Language(id: "ml", code: "ml", name: "Malayalam"),
        Language(id: "auto", code: "auto", name: "Auto-detect")
    ]
    
    static let defaultLanguage = Language.allCases.first { $0.code == "pt" } ?? Language.allCases[0]
}
