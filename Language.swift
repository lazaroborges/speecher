import Foundation

struct Language: Identifiable, Hashable, CaseIterable {
    let id: String
    let code: String
    private let nameKey: String
    
    var name: String {
        return nameKey.localized
    }
    
    static let allCases: [Language] = [
        Language(id: "en", code: "en", nameKey: "language_english"),
        Language(id: "pt", code: "pt", nameKey: "language_portuguese"),
        Language(id: "es", code: "es", nameKey: "language_spanish"),
        Language(id: "fr", code: "fr", nameKey: "language_french"),
        Language(id: "de", code: "de", nameKey: "language_german"),
        Language(id: "it", code: "it", nameKey: "language_italian"),
        Language(id: "ja", code: "ja", nameKey: "language_japanese"),
        Language(id: "ko", code: "ko", nameKey: "language_korean"),
        Language(id: "zh", code: "zh", nameKey: "language_chinese"),
        Language(id: "ru", code: "ru", nameKey: "language_russian"),
        Language(id: "ar", code: "ar", nameKey: "language_arabic"),
        Language(id: "hi", code: "hi", nameKey: "language_hindi"),
        Language(id: "tr", code: "tr", nameKey: "language_turkish"),
        Language(id: "pl", code: "pl", nameKey: "language_polish"),
        Language(id: "nl", code: "nl", nameKey: "language_dutch"),
        Language(id: "sv", code: "sv", nameKey: "language_swedish"),
        Language(id: "da", code: "da", nameKey: "language_danish"),
        Language(id: "no", code: "no", nameKey: "language_norwegian"),
        Language(id: "fi", code: "fi", nameKey: "language_finnish"),
        Language(id: "cs", code: "cs", nameKey: "language_czech"),
        Language(id: "hu", code: "hu", nameKey: "language_hungarian"),
        Language(id: "ro", code: "ro", nameKey: "language_romanian"),
        Language(id: "uk", code: "uk", nameKey: "language_ukrainian"),
        Language(id: "el", code: "el", nameKey: "language_greek"),
        Language(id: "bg", code: "bg", nameKey: "language_bulgarian"),
        Language(id: "hr", code: "hr", nameKey: "language_croatian"),
        Language(id: "sr", code: "sr", nameKey: "language_serbian"),
        Language(id: "sk", code: "sk", nameKey: "language_slovak"),
        Language(id: "sl", code: "sl", nameKey: "language_slovenian"),
        Language(id: "et", code: "et", nameKey: "language_estonian"),
        Language(id: "lv", code: "lv", nameKey: "language_latvian"),
        Language(id: "lt", code: "lt", nameKey: "language_lithuanian"),
        Language(id: "ca", code: "ca", nameKey: "language_catalan"),
        Language(id: "vi", code: "vi", nameKey: "language_vietnamese"),
        Language(id: "th", code: "th", nameKey: "language_thai"),
        Language(id: "id", code: "id", nameKey: "language_indonesian"),
        Language(id: "ms", code: "ms", nameKey: "language_malay"),
        Language(id: "he", code: "he", nameKey: "language_hebrew"),
        Language(id: "fa", code: "fa", nameKey: "language_persian"),
        Language(id: "ur", code: "ur", nameKey: "language_urdu"),
        Language(id: "bn", code: "bn", nameKey: "language_bengali"),
        Language(id: "ta", code: "ta", nameKey: "language_tamil"),
        Language(id: "te", code: "te", nameKey: "language_telugu"),
        Language(id: "ml", code: "ml", nameKey: "language_malayalam"),
        Language(id: "auto", code: "auto", nameKey: "language_auto_detect")
    ]
    
    static let defaultLanguage = Language.allCases.first { $0.code == "pt" } ?? Language.allCases[0]
}
