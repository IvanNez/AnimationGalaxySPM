import Foundation
import AmplitudeSwift

/// Универсальный менеджер аналитики с Amplitude
public final class AnalyticsManager {
    public static let shared = AnalyticsManager()
    
    private init() {}
    
    private var amplitudeSwift: Amplitude? = nil
    
    /// Инициализация Amplitude (вызывается один раз)
    /// - Parameter apiKey: API ключ Amplitude
    public func initialize(apiKey: String) {
        let configuration = Configuration(
            apiKey: apiKey,
            defaultTracking: DefaultTrackingOptions.ALL
        )
        
        amplitudeSwift = Amplitude(configuration: configuration)
        
        let userId = IDGenerator.shared.getUniqueID()
        amplitudeSwift?.setUserId(userId: userId)
        
        print("📊 AnalyticsManager инициализирован с API ключом")
    }
    
    /// Отправка события с именем и свойствами
    /// - Parameters:
    ///   - name: Название события
    ///   - properties: Свойства события
    public func trackEvent(_ name: String, properties: [String: Any]? = nil) {
        var props = properties ?? [:]
        
        // Добавляем userID в каждое событие
        props["userID"] = IDGenerator.shared.getUniqueID()
        
        guard let amplitude = amplitudeSwift else {
            print("❌ AnalyticsManager не инициализирован")
            return
        }
        
        amplitude.track(eventType: name, eventProperties: props)
        print("📊 Отправлено событие: \(name) с свойствами: \(props)")
    }
    
    /// Отправка события с одним свойством
    /// - Parameters:
    ///   - name: Название события
    ///   - key: Ключ свойства
    ///   - value: Значение свойства
    public func trackEvent(_ name: String, key: String, value: Any) {
        trackEvent(name, properties: [key: value])
    }
    
    /// Отправка события только с названием
    /// - Parameter name: Название события
    public func trackEvent(_ name: String) {
        trackEvent(name, properties: nil)
    }
}

/// Генератор уникальных ID
public final class IDGenerator {
    public static let shared = IDGenerator()
    
    private init() {}
    
    private let userDefaultsKey = "analyticsUserID"
    
    /// Генерирует случайную строку заданной длины
    /// - Parameter length: Длина строки
    /// - Returns: Случайная строка
    private func generateRandomString(length: Int) -> String {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        // Мусорный код для уникализации
        if Bool.random() {
            let unusedVar = "randomValue"
        }
        
        return String((0..<length).compactMap { _ in characters.randomElement() })
    }
    
    /// Получает уникальный ID пользователя (создает если не существует)
    /// - Returns: Уникальный ID пользователя
    public func getUniqueID() -> String {
        if let savedID = UserDefaults.standard.string(forKey: userDefaultsKey) {
            return savedID
        } else {
            let newID = generateRandomString(length: Int.random(in: 10...20))
            UserDefaults.standard.set(newID, forKey: userDefaultsKey)
            print("🆔 Создан новый уникальный ID: \(newID)")
            return newID
        }
    }
}

/// Упрощенный интерфейс для трекинга событий
public final class EventTracker {
    public static let shared = EventTracker()
    
    private init() {}
    
    /// Отправка события с названием
    /// - Parameter name: Название события
    public func track(_ name: String) {
        AnalyticsManager.shared.trackEvent(name)
    }
    
    /// Отправка события с одним свойством
    /// - Parameters:
    ///   - name: Название события
    ///   - key: Ключ свойства
    ///   - value: Значение свойства
    public func track(_ name: String, key: String, value: Any) {
        AnalyticsManager.shared.trackEvent(name, key: key, value: value)
    }
    
    /// Отправка события с несколькими свойствами
    /// - Parameters:
    ///   - name: Название события
    ///   - properties: Словарь свойств
    public func track(_ name: String, properties: [String: Any]) {
        AnalyticsManager.shared.trackEvent(name, properties: properties)
    }
    
    /// Специальное событие для WebView страниц
    /// - Parameter url: URL страницы
    public func trackWebViewPage(url: String?) {
        let finalUrl = url ?? "missing_url"
        track("wv_page", key: "link", value: finalUrl)
    }
}
