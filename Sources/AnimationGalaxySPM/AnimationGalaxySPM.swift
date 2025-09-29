import SwiftUI

/// AnimationGalaxySPM - библиотека для создания красивых анимаций в SwiftUI
public struct AnimationGalaxySPM {
    
    /// Создает красивый splash screen с градиентом и лоадером
    /// - Parameters:
    ///   - gradientColors: Массив цветов для градиента
    ///   - textColor: Цвет текста "Loading"
    ///   - loaderColor: Цвет лоадера
    ///   - loadingText: Текст загрузки (по умолчанию "Loading...")
    /// - Returns: SwiftUI View с splash screen
    public static func createSplashScreen(
        gradientColors: [Color] = [.blue, .purple, .pink],
        textColor: Color = .white,
        loaderColor: Color = .white,
        loadingText: String = "Loading..."
    ) -> some View {
        SplashScreenView(
            gradientColors: gradientColors,
            textColor: textColor,
            loaderColor: loaderColor,
            loadingText: loadingText
        )
    }
    
    /// Создает анимированную звезду с пульсирующим эффектом
    /// - Parameters:
    ///   - size: Размер звезды
    ///   - color: Цвет звезды
    ///   - duration: Длительность анимации
    /// - Returns: SwiftUI View с анимированной звездой
    public static func createAnimatedStar(size: CGFloat = 50, color: Color = .yellow, duration: Double = 1.0) -> some View {
        AnimatedStarView(size: size, color: color, duration: duration)
    }
    
    /// Создает галактику с вращающимися элементами
    /// - Parameters:
    ///   - elementCount: Количество элементов в галактике
    ///   - size: Размер галактики
    ///   - colors: Массив цветов для элементов
    /// - Returns: SwiftUI View с анимированной галактикой
    public static func createGalaxy(elementCount: Int = 8, size: CGFloat = 200, colors: [Color] = [.blue, .purple, .pink]) -> some View {
        GalaxyView(elementCount: elementCount, size: size, colors: colors)
    }
    
    /// Создает космический фон с движущимися звездами
    /// - Parameters:
    ///   - starCount: Количество звезд
    ///   - speed: Скорость движения звезд
    /// - Returns: SwiftUI View с космическим фоном
    public static func createSpaceBackground(starCount: Int = 50, speed: Double = 2.0) -> some View {
        SpaceBackgroundView(starCount: starCount, speed: speed)
    }
    
    /// Создает веб-просмотрщик с поддержкой жестов и обновления
    /// - Parameters:
    ///   - urlString: URL для загрузки
    ///   - allowsGestures: Разрешить жесты навигации (по умолчанию true)
    ///   - enableRefresh: Включить pull-to-refresh (по умолчанию true)
    /// - Returns: SwiftUI View с веб-просмотрщиком
    public static func createContentDisplay(
        urlString: String,
        allowsGestures: Bool = true,
        enableRefresh: Bool = true
    ) -> some View {
        SafeContentDisplayView(
            urlString: urlString,
            allowsGestures: allowsGestures,
            enableRefresh: enableRefresh
        )
    }
    
    /// Проверяет доступность внешнего контента с кэшированием результатов
    /// - Parameters:
    ///   - url: URL для проверки
    ///   - targetDate: Целевая дата (контент доступен только после этой даты)
    ///   - deviceCheck: Проверять ли тип устройства (iPad исключается)
    ///   - timeout: Таймаут для сетевых запросов
    ///   - cacheKey: Уникальный ключ для кэширования
    /// - Returns: Результат проверки с флагом показа и финальным URL
    public static func checkContentAvailability(
        url: String,
        targetDate: Date,
        deviceCheck: Bool = true,
        timeout: TimeInterval = 10.0,
        cacheKey: String? = nil
    ) -> ContentAvailabilityChecker.ContentCheckResult {
        return ContentAvailabilityChecker.checkContentAvailability(
            url: url,
            targetDate: targetDate,
            deviceCheck: deviceCheck,
            timeout: timeout,
            cacheKey: cacheKey
        )
    }
    
    /// Инициализирует систему аналитики Amplitude
    /// - Parameter apiKey: API ключ Amplitude
    public static func initializeAnalytics(apiKey: String) {
        AnalyticsManager.shared.initialize(apiKey: apiKey)
    }
    
    /// Отправляет событие аналитики
    /// - Parameter name: Название события
    public static func trackEvent(_ name: String) {
        EventTracker.shared.track(name)
    }
    
    /// Отправляет событие аналитики с одним свойством
    /// - Parameters:
    ///   - name: Название события
    ///   - key: Ключ свойства
    ///   - value: Значение свойства
    public static func trackEvent(_ name: String, key: String, value: Any) {
        EventTracker.shared.track(name, key: key, value: value)
    }
    
    /// Отправляет событие аналитики с несколькими свойствами
    /// - Parameters:
    ///   - name: Название события
    ///   - properties: Словарь свойств
    public static func trackEvent(_ name: String, properties: [String: Any]) {
        EventTracker.shared.track(name, properties: properties)
    }
    
    /// Получает уникальный ID пользователя
    /// - Returns: Уникальный ID пользователя
    public static func getUserID() -> String {
        return IDGenerator.shared.getUniqueID()
    }
    
    /// Показывает alert для уведомлений с переходом в настройки
    public static func showNotificationsAlert() {
        CustomAlertManager.shared.showNotificationsAlert()
    }
    
    /// Показывает кастомный alert с настраиваемыми параметрами
    /// - Parameters:
    ///   - title: Заголовок alert'а
    ///   - message: Сообщение alert'а
    ///   - primaryButtonTitle: Текст основной кнопки
    ///   - secondaryButtonTitle: Текст вторичной кнопки
    ///   - primaryAction: Действие при нажатии на основную кнопку
    ///   - secondaryAction: Действие при нажатии на вторичную кнопку
    public static func showCustomAlert(
        title: String,
        message: String,
        primaryButtonTitle: String,
        secondaryButtonTitle: String? = nil,
        primaryAction: (() -> Void)? = nil,
        secondaryAction: (() -> Void)? = nil
    ) {
        CustomAlertManager.shared.showCustomAlert(
            title: title,
            message: message,
            primaryButtonTitle: primaryButtonTitle,
            secondaryButtonTitle: secondaryButtonTitle,
            primaryAction: primaryAction,
            secondaryAction: secondaryAction
        )
    }
    
    /// Показывает alert с подтверждением действия
    /// - Parameters:
    ///   - title: Заголовок alert'а
    ///   - message: Сообщение alert'а
    ///   - confirmTitle: Текст кнопки подтверждения
    ///   - cancelTitle: Текст кнопки отмены
    ///   - onConfirm: Действие при подтверждении
    ///   - onCancel: Действие при отмене
    public static func showConfirmationAlert(
        title: String,
        message: String,
        confirmTitle: String = "OK",
        cancelTitle: String = "Cancel",
        onConfirm: @escaping () -> Void,
        onCancel: (() -> Void)? = nil
    ) {
        CustomAlertManager.shared.showConfirmationAlert(
            title: title,
            message: message,
            confirmTitle: confirmTitle,
            cancelTitle: cancelTitle,
            onConfirm: onConfirm,
            onCancel: onCancel
        )
    }
    
    /// Инициализирует OneSignal с переданным App ID и launchOptions
    /// - Parameters:
    ///   - appId: Идентификатор приложения OneSignal
    ///   - launchOptions: launchOptions из AppDelegate
    public static func initializeOneSignal(appId: String, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        NotificationManager.shared.configure(appId: appId, launchOptions: launchOptions)
    }
}