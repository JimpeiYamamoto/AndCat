import SwiftUI
import UserNotifications
import FacebookCore

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
        
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        return true
    }
    
    func application(
        _ application: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any]
    ) -> Bool {
        ApplicationDelegate.shared.application(
            application,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
    }
}
