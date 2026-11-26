import Flutter
import UIKit
import UserNotifications
import GoogleMaps

#if canImport(Stripe)
import Stripe
#endif

#if canImport(FirebaseMessaging)
import FirebaseMessaging
#endif

#if canImport(GoogleSignIn)
import GoogleSignIn
#endif

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Flutter passes the Maps key through --dart-define-from-file or --dart-define.
    if let mapsKey = googleMapsAPIKeyFromDartDefines() {
      GMSServices.provideAPIKey(mapsKey)
    }

    // Must run BEFORE plugin registration. firebase_messaging installs
    // itself as the UNUserNotificationCenter delegate only when it finds the
    // slot empty, and then forwards to whatever it displaced. With the slot
    // nil it captures nothing, becomes the sole delegate, and drops every
    // notification callback flutter_local_notifications needs — taps on the
    // notifications this app posts itself silently do nothing.
    //
    // FlutterAppDelegate conforms to FlutterAppLifeCycleProvider, which
    // firebase_messaging explicitly declines to replace, so claiming the slot
    // here leaves both plugins working: the app delegate fans callbacks out to
    // every registered plugin.
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }

    application.registerForRemoteNotifications()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    print("[FCM Native] ✅ APNs token received: \(token)")
    #if canImport(FirebaseMessaging)
    Messaging.messaging().apnsToken = deviceToken
    #endif
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    print("[FCM Native] ❌ APNs registration failed: \(error.localizedDescription)")
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }

  /// Custom URL scheme returns from Stripe (3DS / Link / bank apps).
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    #if canImport(GoogleSignIn)
    if GIDSignIn.sharedInstance.handle(url) {
      return true
    }
    #endif
    #if canImport(Stripe)
    if StripeAPI.handleURLCallback(with: url) {
      return true
    }
    #endif
    return super.application(app, open: url, options: options)
  }

  /// Universal-link style returns (Safari View Controller / ASWebAuthentication).
  override func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
  ) -> Bool {
    #if canImport(Stripe)
    if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
       let url = userActivity.webpageURL,
       StripeAPI.handleURLCallback(with: url) {
      return true
    }
    #endif
    return super.application(
      application,
      continue: userActivity,
      restorationHandler: restorationHandler
    )
  }

  private func googleMapsAPIKeyFromDartDefines() -> String? {
    guard let encodedDefines = Bundle.main.object(
      forInfoDictionaryKey: "FlutterDartDefines"
    ) as? String else {
      return nil
    }

    let prefix = "GOOGLE_MAPS_API_KEY="
    for encoded in encodedDefines.split(separator: ",") {
      guard let data = Data(base64Encoded: String(encoded)),
            let definition = String(data: data, encoding: .utf8),
            definition.hasPrefix(prefix) else {
        continue
      }

      let key = String(definition.dropFirst(prefix.count))
      return key.isEmpty ? nil : key
    }
    return nil
  }

}
