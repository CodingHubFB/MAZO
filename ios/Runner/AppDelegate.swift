import UIKit
import Flutter
import Firebase
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {

  private let channelName = "mazo.channel"
  private var methodChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()

    // إعدادات الإشعارات
    UNUserNotificationCenter.current().delegate = self

    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
      if let error = error {
        print("❌ Error requesting notifications authorization: \(error)")
      } else {
        print("✅ Notification permission granted: \(granted)")
      }
    }

    application.registerForRemoteNotifications()

    GeneratedPluginRegistrant.register(with: self)

    // إنشاء قناة الاتصال مع Flutter
    if let controller = window?.rootViewController as? FlutterViewController {
      methodChannel = FlutterMethodChannel(name: channelName, binaryMessenger: controller.binaryMessenger)
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // عرض الإشعار حتى لو التطبيق مفتوح
  override func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler([.alert, .badge, .sound])
  }

  // استقبال بيانات الإشعار لما يضغط عليه المستخدم
  override func application(_ application: UIApplication,
                            didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Messaging.messaging().apnsToken = deviceToken
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  // 🧩 استقبال deep link عند فتح التطبيق
  override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    handleDeepLink(url: url)
    return true
  }

  private func handleDeepLink(url: URL) {
  if url.scheme == "globee", url.host == "product" {
    if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
       let productId = components.queryItems?.first(where: { $0.name == "id" })?.value {
      let fullPath = "/Globee/product?id=\(productId)"
      methodChannel?.invokeMethod("openProduct", arguments: fullPath)
    }
  }
}

}
