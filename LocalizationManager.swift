import Foundation

class LocalizationManager {
    static let shared = LocalizationManager()
    
    private let supportedLanguages = ["en", "es", "pt"]
    private let defaultLanguage = "en"
    
    private init() {}
    
    /// Get the appropriate language code based on system locale
    private func getLanguageCode() -> String {
        let systemLanguage = Locale.current.languageCode ?? defaultLanguage
        
        // Check if system language is supported
        if supportedLanguages.contains(systemLanguage) {
            return systemLanguage
        }
        
        // Default to English if not supported
        return defaultLanguage
    }
    
    /// Get localized string for the current locale
    func localizedString(key: String) -> String {
        let languageCode = getLanguageCode()
        
        // Try to get the bundle for the specific language
        guard let path = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            // Fallback to main bundle (English)
            return NSLocalizedString(key, comment: "")
        }
        
        return NSLocalizedString(key, bundle: bundle, comment: "")
    }
}

// Convenience extension for easier usage
extension String {
    var localized: String {
        return LocalizationManager.shared.localizedString(key: self)
    }
}
