import SwiftUI
import UserNotifications

@main
struct AndCatApp: App {
    @UIApplicationDelegateAdaptor (AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            TopListView(viewStream: TopViewStream.shared)
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    // PushNotificationを受信するためのPermissionを求める。UserがOKすれば受け取れる。
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, _) in
            if granted {
                UNUserNotificationCenter.current().delegate = self
            }
        }
        return true
    }
}
