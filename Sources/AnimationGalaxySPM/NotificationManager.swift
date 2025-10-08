import Foundation
import UIKit
import UserNotifications
import OneSignalFramework

/// Менеджер для интеграции OneSignal в сторонние проекты
public final class NotificationManager {
    public static let shared = NotificationManager()
    
    private init() {}
    
    private let launchCountKey = "animationGalaxyLaunchCount"
    
    /// Инициализация OneSignal
    /// - Parameters:
    ///   - appId: OneSignal App ID
    ///   - launchOptions: launchOptions из AppDelegate
    public func configure(appId: String, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        
        OneSignal.initialize(appId, withLaunchOptions: launchOptions)
        let userId = AnimationGalaxySPM.getUserID()
        let launchCount = UserDefaults.standard.integer(forKey: launchCountKey)
        OneSignal.login(userId)
        
        
        schedulePermissionFlow(userId: userId, launchCount: launchCount)
        UserDefaults.standard.set(launchCount + 1, forKey: launchCountKey)
    }
    
    private func schedulePermissionFlow(userId: String, launchCount: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            
            if launchCount == 0 {
                self.requestInitialPermission(userId: userId)
            } else {
                self.checkNotificationStatus(userId: userId)
            }
        }
    }
    
    private func requestInitialPermission(userId: String) {
        OneSignal.Notifications.requestPermission { accepted in
            print("✅ OneSignal push permission accepted: \(accepted)")
            if accepted {
                OneSignal.login(userId)
                print("📥 OneSignal login on accepted")
            }
        }
    }
    
    private func checkNotificationStatus(userId: String) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized, .provisional:
                    OneSignal.login(userId)
                    print("📬 OneSignal login authorized")
                case .denied, .notDetermined, .ephemeral:
                    AnimationGalaxySPM.showNotificationsAlert()
                    print("⚠️ Show notifications alert")
                @unknown default:
                    AnimationGalaxySPM.showNotificationsAlert()
                    print("⚠️ Unknown status, show alert")
                }
            }
        }
    }
}
