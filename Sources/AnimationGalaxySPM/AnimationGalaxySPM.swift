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
}