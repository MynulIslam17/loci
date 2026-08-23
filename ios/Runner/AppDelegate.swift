import Flutter
import UIKit
import UserNotifications
import Stripe

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Must run BEFORE GeneratedPluginRegistrant. firebase_messaging installs
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

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  /// Custom URL scheme returns from Stripe (3DS / Link / bank apps).
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    if StripeAPI.handleURLCallback(with: url) {
      return true
    }
    return super.application(app, open: url, options: options)
  }

  /// Universal-link style returns (Safari View Controller / ASWebAuthentication).
  override func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
  ) -> Bool {
    if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
       let url = userActivity.webpageURL,
       StripeAPI.handleURLCallback(with: url) {
      return true
    }
    return super.application(
      application,
      continue: userActivity,
      restorationHandler: restorationHandler
    )
  }
}
