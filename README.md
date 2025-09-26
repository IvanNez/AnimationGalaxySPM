# AnimationGalaxySPM

Библиотека для создания красивых космических анимаций в SwiftUI.

## Возможности

- 🚀 Красивый splash screen с градиентом и анимированным лоадером
- 🌟 Анимированные звезды с пульсирующим эффектом
- 🌌 Галактики с вращающимися элементами  
- 🌠 Космический фон с движущимися звездами
- 📱 Веб-просмотрщик с поддержкой жестов и обновления

## Установка

### Swift Package Manager

Добавьте зависимость в ваш `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/AnimationGalaxySPM.git", from: "1.0.0")
]
```

Или добавьте через Xcode:
1. File → Add Package Dependencies
2. Введите URL репозитория
3. Выберите версию

## Использование

### Splash Screen

```swift
import SwiftUI
import AnimationGalaxySPM

struct ContentView: View {
    var body: some View {
        AnimationGalaxySPM.createSplashScreen(
            gradientColors: [.blue, .purple, .pink],
            textColor: .white,
            loaderColor: .white,
            loadingText: "Loading..."
        )
    }
}
```

### Анимированная звезда

```swift
AnimationGalaxySPM.createAnimatedStar(
    size: 50,
    color: .yellow,
    duration: 1.0
)
```

### Галактика

```swift
AnimationGalaxySPM.createGalaxy(
    elementCount: 8,
    size: 200,
    colors: [.blue, .purple, .pink]
)
```

### Космический фон

```swift
AnimationGalaxySPM.createSpaceBackground(
    starCount: 50,
    speed: 2.0
)
```

### Веб-просмотрщик

```swift
AnimationGalaxySPM.createContentDisplay(
    urlString: "https://example.com",
    allowsGestures: true,
    enableRefresh: true
)
```

#### Особенности веб-просмотрщика:

- ✅ Поддержка JavaScript
- ✅ Свайпы для навигации назад/вперед
- ✅ Pull-to-refresh жесты
- ✅ Обработка дочерних окон
- ✅ Автоматическое открытие внешних ссылок
- ✅ Сохранение куки
- ✅ Современный User Agent
- ✅ Отступы от safe area
- ✅ Черный фон для лучшего отображения

## Требования

- iOS 15.0+
- macOS 12.0+
- watchOS 8.0+
- tvOS 15.0+
- Swift 5.9+

## Лицензия

MIT License
