import Foundation
import UIKit

/// Менеджер для показа кастомных alert'ов
public final class CustomAlertManager {
    public static let shared = CustomAlertManager()
    
    private init() {}
    
    /// Показывает alert для уведомлений с переходом в настройки
    /// - Parameters:
    ///   - title: Заголовок alert'а (по умолчанию "Notification are disabled")
    ///   - message: Сообщение alert'а (по умолчанию "To receive notifications, please enable them in settings.")
    ///   - settingsButtonTitle: Текст кнопки настроек (по умолчанию "Settings")
    ///   - cancelButtonTitle: Текст кнопки отмены (по умолчанию "Cancel")
    public func showNotificationsAlert(
        title: String = "Notification are disabled",
        message: String = "To receive notifications, please enable them in settings.",
        settingsButtonTitle: String = "Settings",
        cancelButtonTitle: String = "Cancel"
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        guard
            let windowScene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
            let rootVC = windowScene.windows
                .first(where: { $0.isKeyWindow })?.rootViewController
        else {
            print("❌ Не удалось найти root view controller для показа alert")
            return
        }
        
        // Кнопка "Settings"
        alert.addAction(UIAlertAction(title: settingsButtonTitle, style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString),
               UIApplication.shared.canOpenURL(settingsURL) {
                UIApplication.shared.open(settingsURL)
                print("📱 Переход в настройки приложения")
            } else {
                print("❌ Не удалось открыть настройки")
            }
        })
        
        // Кнопка "Cancel"
        alert.addAction(UIAlertAction(title: cancelButtonTitle, style: .cancel) { _ in
            print("❌ Пользователь отменил переход в настройки")
        })
        
        rootVC.present(alert, animated: true)
        print("📱 Показан alert для уведомлений")
    }
    
    /// Показывает кастомный alert с настраиваемыми параметрами
    /// - Parameters:
    ///   - title: Заголовок alert'а
    ///   - message: Сообщение alert'а
    ///   - primaryButtonTitle: Текст основной кнопки
    ///   - secondaryButtonTitle: Текст вторичной кнопки (опционально)
    ///   - primaryAction: Действие при нажатии на основную кнопку
    ///   - secondaryAction: Действие при нажатии на вторичную кнопку (опционально)
    public func showCustomAlert(
        title: String,
        message: String,
        primaryButtonTitle: String,
        secondaryButtonTitle: String? = nil,
        primaryAction: (() -> Void)? = nil,
        secondaryAction: (() -> Void)? = nil
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        guard
            let windowScene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
            let rootVC = windowScene.windows
                .first(where: { $0.isKeyWindow })?.rootViewController
        else {
            print("❌ Не удалось найти root view controller для показа alert")
            return
        }
        
        // Основная кнопка
        alert.addAction(UIAlertAction(title: primaryButtonTitle, style: .default) { _ in
            primaryAction?()
            print("📱 Нажата основная кнопка: \(primaryButtonTitle)")
        })
        
        // Вторичная кнопка (если указана)
        if let secondaryTitle = secondaryButtonTitle {
            alert.addAction(UIAlertAction(title: secondaryTitle, style: .cancel) { _ in
                secondaryAction?()
                print("📱 Нажата вторичная кнопка: \(secondaryTitle)")
            })
        }
        
        rootVC.present(alert, animated: true)
        print("📱 Показан кастомный alert: \(title)")
    }
    
    /// Показывает alert с подтверждением действия
    /// - Parameters:
    ///   - title: Заголовок alert'а
    ///   - message: Сообщение alert'а
    ///   - confirmTitle: Текст кнопки подтверждения (по умолчанию "OK")
    ///   - cancelTitle: Текст кнопки отмены (по умолчанию "Cancel")
    ///   - onConfirm: Действие при подтверждении
    ///   - onCancel: Действие при отмене (опционально)
    public func showConfirmationAlert(
        title: String,
        message: String,
        confirmTitle: String = "OK",
        cancelTitle: String = "Cancel",
        onConfirm: @escaping () -> Void,
        onCancel: (() -> Void)? = nil
    ) {
        showCustomAlert(
            title: title,
            message: message,
            primaryButtonTitle: confirmTitle,
            secondaryButtonTitle: cancelTitle,
            primaryAction: onConfirm,
            secondaryAction: onCancel
        )
    }
}
