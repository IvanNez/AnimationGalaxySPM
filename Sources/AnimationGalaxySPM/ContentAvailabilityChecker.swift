import Foundation
import Network
import UIKit

/// Универсальный проверщик доступности внешнего контента
public class ContentAvailabilityChecker {
    
    /// Результат проверки доступности контента
    public struct ContentCheckResult {
        public let shouldShowExternalContent: Bool
        public let finalUrl: String
        public let reason: String
        
        public init(shouldShowExternalContent: Bool, finalUrl: String, reason: String) {
            self.shouldShowExternalContent = shouldShowExternalContent
            self.finalUrl = finalUrl
            self.reason = reason
        }
    }
    
    /// Проверяет доступность внешнего контента с кэшированием результатов
    /// - Parameters:
    ///   - url: URL для проверки
    ///   - targetDate: Целевая дата (контент доступен только после этой даты)
    ///   - deviceCheck: Проверять ли тип устройства (iPad исключается)
    ///   - timeout: Таймаут для сетевых запросов
    ///   - cacheKey: Уникальный ключ для кэширования (по умолчанию используется URL)
    /// - Returns: Результат проверки с флагом показа и финальным URL
    public static func checkContentAvailability(
        url: String,
        targetDate: Date,
        deviceCheck: Bool = true,
        timeout: TimeInterval = 10.0,
        cacheKey: String? = nil
    ) -> ContentCheckResult {
        
        let uniqueKey = cacheKey ?? url
        let hasShownExternalKey = "hasShownExternal_\(uniqueKey)"
        let hasShownAppKey = "hasShownApp_\(uniqueKey)"
        let savedUrlKey = "savedUrl_\(uniqueKey)"
        
        print("🔍 Начинаем проверку доступности контента для URL: \(url)")
        
        // Проверяем кэш - уже показывали внешний контент
        if UserDefaults.standard.bool(forKey: hasShownExternalKey) {
            let savedUrl = UserDefaults.standard.string(forKey: savedUrlKey) ?? url
            print("✅ Кэш: Уже показывали внешний контент, возвращаем сохраненный URL")
            return ContentCheckResult(
                shouldShowExternalContent: true,
                finalUrl: savedUrl,
                reason: "Cached external content"
            )
        }
        
        // Проверяем кэш - уже показывали приложение
        if UserDefaults.standard.bool(forKey: hasShownAppKey) {
            print("✅ Кэш: Уже показывали приложение, возвращаем false")
            return ContentCheckResult(
                shouldShowExternalContent: false,
                finalUrl: "",
                reason: "Cached app content"
            )
        }
        
        print("🔄 Кэш пуст, выполняем полную проверку...")
        
        // Проверка 1: Интернет соединение
        print("🌐 Проверяем интернет соединение...")
        let internetResult = checkInternetConnection(timeout: 2.0)
        if !internetResult {
            print("❌ Не прошли интернет")
            UserDefaults.standard.set(true, forKey: hasShownAppKey)
            return ContentCheckResult(
                shouldShowExternalContent: false,
                finalUrl: "",
                reason: "No internet connection"
            )
        }
        print("✅ Прошли интернет")
        
        // Проверка 2: Дата
        print("📅 Проверяем целевую дату...")
        let dateResult = checkTargetDate(targetDate: targetDate)
        if !dateResult {
            print("❌ Не прошли дату")
            UserDefaults.standard.set(true, forKey: hasShownAppKey)
            return ContentCheckResult(
                shouldShowExternalContent: false,
                finalUrl: "",
                reason: "Target date not reached"
            )
        }
        print("✅ Прошли дату")
        
        // Проверка 3: Устройство (если включена)
        if deviceCheck {
            print("📱 Проверяем тип устройства...")
            let deviceResult = checkDeviceType()
            if !deviceResult {
                print("❌ Не прошли проверку устройства (iPad)")
                UserDefaults.standard.set(true, forKey: hasShownAppKey)
                return ContentCheckResult(
                    shouldShowExternalContent: false,
                    finalUrl: "",
                    reason: "Device not supported (iPad)"
                )
            }
            print("✅ Прошли проверку устройства")
        }
        
        // Проверка 4: Серверный код
        print("🌐 Проверяем серверный код...")
        let serverResult = checkServerResponse(url: url, timeout: timeout)
        if !serverResult.success {
            print("❌ Не прошли код: \(serverResult.reason)")
            UserDefaults.standard.set(true, forKey: hasShownAppKey)
            return ContentCheckResult(
                shouldShowExternalContent: false,
                finalUrl: "",
                reason: "Server check failed: \(serverResult.reason)"
            )
        }
        print("✅ Прошли код")
        
        // Все проверки пройдены - сохраняем результат
        print("🎉 Все проверки пройдены! Сохраняем результат...")
        UserDefaults.standard.set(true, forKey: hasShownExternalKey)
        UserDefaults.standard.set(serverResult.finalUrl, forKey: savedUrlKey)
        
        return ContentCheckResult(
            shouldShowExternalContent: true,
            finalUrl: serverResult.finalUrl,
            reason: "All checks passed"
        )
    }
    
    // MARK: - Private Methods
    
    private static func checkInternetConnection(timeout: TimeInterval) -> Bool {
        let monitor = NWPathMonitor()
        var isConnected = false
        let semaphore = DispatchSemaphore(value: 0)
        
        monitor.pathUpdateHandler = { path in
            isConnected = path.status == .satisfied
            semaphore.signal()
        }
        
        let queue = DispatchQueue(label: "ContentAvailabilityConnectionMonitor")
        monitor.start(queue: queue)
        
        _ = semaphore.wait(timeout: .now() + timeout)
        monitor.cancel()
        
        return isConnected
    }
    
    private static func checkTargetDate(targetDate: Date) -> Bool {
        let currentDate = Date()
        return currentDate >= targetDate
    }
    
    private static func checkDeviceType() -> Bool {
        return UIDevice.current.model != "iPad"
    }
    
    private static func checkServerResponse(url: String, timeout: TimeInterval) -> (success: Bool, finalUrl: String, reason: String) {
        guard let requestUrl = URL(string: url) else {
            return (false, "", "Invalid URL")
        }
        
        let redirectHandler = ContentRedirectHandler()
        let session = URLSession(configuration: .default, delegate: redirectHandler, delegateQueue: nil)
        
        let semaphore = DispatchSemaphore(value: 0)
        var result = (success: false, finalUrl: "", reason: "Unknown error")
        
        let task = session.dataTask(with: requestUrl) { data, response, error in
            defer { semaphore.signal() }
            
            if let error = error {
                result = (false, "", "Network error: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if (200...403).contains(httpResponse.statusCode) {
                    result = (true, redirectHandler.finalUrl, "Success")
                } else {
                    result = (false, "", "Server error: \(httpResponse.statusCode)")
                }
            } else {
                result = (false, "", "Invalid response")
            }
        }
        
        task.resume()
        _ = semaphore.wait(timeout: .now() + timeout)
        
        return result
    }
}

// MARK: - Redirect Handler

private class ContentRedirectHandler: NSObject, URLSessionTaskDelegate {
    var finalUrl: String = ""
    
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        if let url = request.url {
            finalUrl = url.absoluteString
        }
        completionHandler(request)
    }
}
