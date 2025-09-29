# AnimationGalaxySPM

Библиотека для создания красивых космических анимаций в SwiftUI.

## Возможности

- 🚀 Красивый splash screen с градиентом и анимированным лоадером
- 🌟 Анимированные звезды с пульсирующим эффектом
- 🌌 Галактики с вращающимися элементами  
- 🌠 Космический фон с движущимися звездами
- 📱 Веб-просмотрщик с поддержкой жестов и обновления
- 🔍 Универсальная система проверки доступности внешнего контента
- 📊 Интеграция с Amplitude для аналитики
- 🚨 Кастомные alert'ы с переходом в настройки
- 📬 Быстрая интеграция OneSignal для push-уведомлений

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

### Проверка доступности внешнего контента

```swift
// Проверяем доступность внешнего контента
let targetDate = Calendar.current.date(from: DateComponents(year: 2025, month: 3, day: 4))!
let result = AnimationGalaxySPM.checkContentAvailability(
    url: "https://example.com",
    targetDate: targetDate,
    deviceCheck: true,
    timeout: 10.0,
    cacheKey: "myApp" // Уникальный ключ для кэширования
)

if result.shouldShowExternalContent {
    // Показываем WebView с внешним контентом
    AnimationGalaxySPM.createContentDisplay(urlString: result.finalUrl)
} else {
    // Показываем основное приложение
    MainAppView()
}
```

#### Особенности системы проверки:

- ✅ **Кэширование результатов** - проверка выполняется только один раз
- ✅ **Проверка интернета** - автоматическая проверка соединения
- ✅ **Проверка даты** - контент доступен только после указанной даты
- ✅ **Проверка устройства** - исключение iPad (опционально)
- ✅ **Проверка сервера** - валидация ответа сервера (коды 200-403)
- ✅ **Подробные логи** - отладочная информация в консоли
- ✅ **Уникальные ключи** - разные приложения не влияют друг на друга

#### Логи в консоли:

```
🔍 Начинаем проверку доступности контента для URL: https://example.com
🌐 Проверяем интернет соединение...
✅ Прошли интернет
📅 Проверяем целевую дату...
✅ Прошли дату
📱 Проверяем тип устройства...
✅ Прошли проверку устройства
🌐 Проверяем серверный код...
✅ Прошли код
🎉 Все проверки пройдены! Сохраняем результат...
```

### Аналитика с Amplitude

```swift
// Инициализация аналитики (вызывается один раз в начале приложения)
AnimationGalaxySPM.initializeAnalytics(apiKey: "your_amplitude_api_key")

// Отправка простого события
AnimationGalaxySPM.trackEvent("app_launched")

// Отправка события с одним свойством
AnimationGalaxySPM.trackEvent("button_clicked", key: "button_name", value: "start_game")

// Отправка события с несколькими свойствами
AnimationGalaxySPM.trackEvent("game_completed", properties: [
    "score": 1500,
    "level": 5,
    "time_spent": 120
])

// Автоматический трекинг WebView страниц
// Событие "wv_page" с URL автоматически отправляется при загрузке страницы
```

#### Особенности аналитики:

- ✅ **Автоматическая инициализация** - один вызов для настройки
- ✅ **Уникальные ID пользователей** - автоматическая генерация и сохранение
- ✅ **Автоматический трекинг WebView** - события загрузки страниц
- ✅ **Простой API** - удобные методы для отправки событий
- ✅ **Подробные логи** - отладочная информация в консоли
- ✅ **Интеграция с Amplitude** - полная поддержка официального SDK

### Кастомные Alert'ы

```swift
// Alert для уведомлений с переходом в настройки
AnimationGalaxySPM.showNotificationsAlert()

// Универсальный кастомный alert
AnimationGalaxySPM.showCustomAlert(
    title: "Подтверждение",
    message: "Вы уверены, что хотите продолжить?",
    primaryButtonTitle: "Да",
    secondaryButtonTitle: "Нет",
    primaryAction: {
        print("Пользователь подтвердил действие")
    },
    secondaryAction: {
        print("Пользователь отменил действие")
    }
)

// Alert с подтверждением
AnimationGalaxySPM.showConfirmationAlert(
    title: "Удалить данные",
    message: "Это действие нельзя отменить",
    confirmTitle: "Удалить",
    cancelTitle: "Отмена",
    onConfirm: {
        // Удаляем данные
        print("Данные удалены")
    }
)
```

#### Особенности alert'ов:

- ✅ **Автоматический поиск root view controller** - работает в любом месте приложения
- ✅ **Переход в настройки** - автоматическое открытие Settings.app
- ✅ **Обработка действий** - callback'и для кнопок
- ✅ **Безопасность** - проверка доступности view controller'а
- ✅ **Подробные логи** - отладочная информация в консоли

### Интеграция OneSignal

```swift
import SwiftUI
import OneSignalFramework
import AnimationGalaxySPM

@main
struct MyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup { ContentView() }
    }
}

final class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        AnimationGalaxySPM.initializeOneSignal(
            appId: "YOUR-ONESIGNAL-APP-ID",
            launchOptions: launchOptions
        )
        return true
    }
}
```

#### Что делает менеджер:

- ✅ Инициализирует OneSignal и логинит пользователя с `AnimationGalaxySPM.getUserID()`
- ✅ Хранит счётчик запусков, чтобы запрашивать разрешение только на первом старте
- ✅ При последующих запусках проверяет статус разрешения и показывает системный Alert из библиотеки
- ✅ Автоматически вызывает `OneSignal.login` после получения разрешения

> **Важно:** Добавьте `OneSignalAppID` в Info.plist, включите push capability и пропишите правильный App ID.

## Требования

- iOS 15.0+
- macOS 12.0+
- watchOS 8.0+
- tvOS 15.0+
- Swift 5.9+

## Лицензия

MIT License
