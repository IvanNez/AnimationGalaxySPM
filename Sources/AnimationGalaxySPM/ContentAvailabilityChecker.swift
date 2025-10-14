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
        
        // Проверяем кэш - уже показывали внешний контент
        if UserDefaults.standard.bool(forKey: hasShownExternalKey) {
            let savedUrl = UserDefaults.standard.string(forKey: savedUrlKey) ?? url
            print("💾 Сохраненная ссылка: \(savedUrl)")
            
            // Извлекаем и сохраняем path_id из сохранённой ссылки
            if let components = URLComponents(string: savedUrl),
               let pathIdItem = components.queryItems?.first(where: { $0.name == "pathid" }),
               let pathIdValue = pathIdItem.value {
                let pathIdKey = "savedPathId_\(url.hash)"
                UserDefaults.standard.set(pathIdValue, forKey: pathIdKey)
                print("🔑 Извлечен path_id из сохраненной ссылки: \(pathIdValue)")
            }
            
            // Валидируем сохраненный URL
            let validationResult = validateSavedUrl(savedUrl: savedUrl, originalUrl: url, timeout: timeout)
            if validationResult.isValid {
                print("✅ Прошли код (сохраненная ссылка валидна)")
                print("🔗 Ссылка: \(validationResult.finalUrl)")
                return ContentCheckResult(
                    shouldShowExternalContent: true,
                    finalUrl: validationResult.finalUrl,
                    reason: "Valid cached external content"
                )
            } else {
                
                // Запрашиваем новый URL с path_id
                let newUrlResult = requestNewUrlWithPathId(originalUrl: url, timeout: timeout)
                if newUrlResult.success {
                    UserDefaults.standard.set(newUrlResult.finalUrl, forKey: savedUrlKey)
                    
                    // Извлекаем и сохраняем path_id из новой ссылки
                    if let components = URLComponents(string: newUrlResult.finalUrl),
                       let pathIdItem = components.queryItems?.first(where: { $0.name == "pathid" }),
                       let pathIdValue = pathIdItem.value {
                        let pathIdKey = "savedPathId_\(url.hash)"
                        UserDefaults.standard.set(pathIdValue, forKey: pathIdKey)
                        print("🔑 Сохранен path_id из новой ссылки: \(pathIdValue)")
                    }
                    
                    return ContentCheckResult(
                        shouldShowExternalContent: true,
                        finalUrl: newUrlResult.finalUrl,
                        reason: "New URL with path_id"
                    )
                } else {
                    
                    return ContentCheckResult(
                        shouldShowExternalContent: true,
                        finalUrl: "",
                        reason: "Failed to get new URL, show empty WebView"
                    )
                }
            }
        }
        
        // Проверяем кэш - уже показывали приложение
        if UserDefaults.standard.bool(forKey: hasShownAppKey) {
            
            return ContentCheckResult(
                shouldShowExternalContent: false,
                finalUrl: "",
                reason: "Cached app content"
            )
        }
        
        // Проверка 1: Интернет соединение
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
            
            let deviceResult = checkDeviceType()
            if !deviceResult {
                
                UserDefaults.standard.set(true, forKey: hasShownAppKey)
                return ContentCheckResult(
                    shouldShowExternalContent: false,
                    finalUrl: "",
                    reason: "Device not supported (iPad)"
                )
            }
            
        }
        
        // Проверка 4: Серверный код
        let serverResult = checkServerResponseWithPathId(url: url, timeout: timeout)
        if !serverResult.success {
            print("❌ Не прошли код")
            UserDefaults.standard.set(true, forKey: hasShownAppKey)
            return ContentCheckResult(
                shouldShowExternalContent: false,
                finalUrl: "",
                reason: "Server check failed: \(serverResult.reason)"
            )
        }
        print("✅ Прошли код")
        print("🔗 Ссылка: \(serverResult.finalUrl)")
        
        // Все проверки пройдены - сохраняем результат
        UserDefaults.standard.set(true, forKey: hasShownExternalKey)
        UserDefaults.standard.set(serverResult.finalUrl, forKey: savedUrlKey)
        print("💾 Сохраненная ссылка: \(serverResult.finalUrl)")
        
        // Извлекаем и сохраняем path_id из финальной ссылки
        if let components = URLComponents(string: serverResult.finalUrl),
           let pathIdItem = components.queryItems?.first(where: { $0.name == "pathid" }),
           let pathIdValue = pathIdItem.value {
            let pathIdKey = "savedPathId_\(url.hash)"
            UserDefaults.standard.set(pathIdValue, forKey: pathIdKey)
            print("🔑 Сохранен path_id: \(pathIdValue)")
        }
        
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
                    let resolvedUrl = redirectHandler.finalUrl.isEmpty ? requestUrl.absoluteString : redirectHandler.finalUrl
                    result = (true, resolvedUrl, "Success")
                } else {
                    result = (false, "", "Server error: \(httpResponse.statusCode)")
                }
            } else {
                result = (false, "", "Invalid response")
            }
        }
        
        task.resume()
        _ = semaphore.wait(timeout: .now() + timeout)
        
        if result.success && result.finalUrl.isEmpty {
            result.finalUrl = requestUrl.absoluteString
        }
        
        return result
    }
    
    private static func checkServerResponseWithPathId(url: String, timeout: TimeInterval) -> (success: Bool, finalUrl: String, reason: String) {
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
                    let resolvedUrl = redirectHandler.finalUrl.isEmpty ? requestUrl.absoluteString : redirectHandler.finalUrl
                    result = (true, resolvedUrl, "Success")
                    
                    // Сохраняем path_id если есть
                    if let components = URLComponents(url: requestUrl, resolvingAgainstBaseURL: false),
                       let pathIdItem = components.queryItems?.first(where: { $0.name == "pathid" }) {
                        let pathIdKey = "savedPathId_\(url.hash)"
                        UserDefaults.standard.set(pathIdItem.value ?? "", forKey: pathIdKey)
                    }
                } else {
                    result = (false, "", "Server error: \(httpResponse.statusCode)")
                }
            } else {
                result = (false, "", "Invalid response")
            }
        }
        
        task.resume()
        _ = semaphore.wait(timeout: .now() + timeout)
        
        if result.success && result.finalUrl.isEmpty {
            result.finalUrl = requestUrl.absoluteString
        }
        
        return result
    }
    
    // MARK: - URL Validation and Path ID Methods
    
    private static func validateSavedUrl(savedUrl: String, originalUrl: String, timeout: TimeInterval) -> (isValid: Bool, finalUrl: String) {
        print("🔄 Идет запрос по сохраненной ссылке")
        let processedSavedUrl: String
        if savedUrl.contains("?") {
            processedSavedUrl = "\(savedUrl)&push_id=\(AnimationGalaxySPM.getUserID())"
        } else {
            processedSavedUrl = "\(savedUrl)?push_id=\(AnimationGalaxySPM.getUserID())"
        }
        print("🔗 Запрос к: \(processedSavedUrl)")
        
        let validationResult = checkServerResponse(url: processedSavedUrl, timeout: timeout)
        if validationResult.success {
            let finalUrl = validationResult.finalUrl.isEmpty ? processedSavedUrl : validationResult.finalUrl
            print("✅ Код: 200-403 (успешно)")
            return (true, finalUrl)
        } else {
            print("❌ Код: \(validationResult.reason)")
            return (false, processedSavedUrl)
        }
    }
    
    private static func requestNewUrlWithPathId(originalUrl: String, timeout: TimeInterval) -> (success: Bool, finalUrl: String) {
        print("🔄 Запрашиваем новую ссылку с path_id")
        
        // Получаем сохраненный path_id
        let pathIdKey = "savedPathId_\(originalUrl.hash)"
        let savedPathId = UserDefaults.standard.string(forKey: pathIdKey) ?? ""
        
        if !savedPathId.isEmpty {
            print("🔑 Сохраненный path_id: \(savedPathId)")
        } else {
            print("⚠️ path_id отсутствует")
        }
        
        var urlString = originalUrl
        if !savedPathId.isEmpty {
            if urlString.contains("?") {
                urlString += "&pathid=\(savedPathId)"
            } else {
                urlString += "?pathid=\(savedPathId)"
            }
        }
        print("🔗 Запрос к главной ссылке: \(urlString)")
        
        let redirectHandler = ContentRedirectHandler()
        let session = URLSession(configuration: .default, delegate: redirectHandler, delegateQueue: nil)
        
        let semaphore = DispatchSemaphore(value: 0)
        var result = (success: false, finalUrl: "")
        
        guard let url = URL(string: urlString) else {
            return (false, "")
        }
        
        let task = session.dataTask(with: url) { data, response, error in
            defer { semaphore.signal() }
            
            if let error = error {
                result = (false, "")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if (200...403).contains(httpResponse.statusCode) {
                    let resolvedUrl = redirectHandler.finalUrl.isEmpty ? url.absoluteString : redirectHandler.finalUrl
                    result = (true, resolvedUrl)
                    print("✅ Код: \(httpResponse.statusCode)")
                    print("🔗 Новая ссылка: \(resolvedUrl)")
                    // Сохраняем новый path_id если есть
                    if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                       let pathIdItem = components.queryItems?.first(where: { $0.name == "pathid" }) {
                        UserDefaults.standard.set(pathIdItem.value ?? "", forKey: pathIdKey)
                        print("💾 Сохранен новый path_id: \(pathIdItem.value ?? "")")
                    }
                } else {
                    print("❌ Код: \(httpResponse.statusCode)")
                    result = (false, "")
                }
            } else {
                print("❌ Неверный ответ сервера")
                result = (false, "")
            }
        }
        
        task.resume()
        _ = semaphore.wait(timeout: .now() + timeout)
        
        if result.success && result.finalUrl.isEmpty {
            result.finalUrl = url.absoluteString
        }
        
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

