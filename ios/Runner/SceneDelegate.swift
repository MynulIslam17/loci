import Flutter
import UIKit

#if canImport(GoogleSignIn)
import GoogleSignIn
#endif

#if canImport(Stripe)
import Stripe
#endif

class SceneDelegate: FlutterSceneDelegate {
  /// Custom URL scheme returns from Stripe (3DS / Link / bank apps) and Google Sign-In.
  override func scene(
    _ scene: UIScene,
    openURLContexts URLContexts: Set<UIOpenURLContext>
  ) {
    for context in URLContexts {
      #if canImport(GoogleSignIn)
      _ = GIDSignIn.sharedInstance.handle(context.url)
      #endif

      #if canImport(Stripe)
      _ = StripeAPI.handleURLCallback(with: context.url)
      #endif

      let app = UIApplication.shared
      let options: [UIApplication.OpenURLOptionsKey: Any] = [
        .sourceApplication: context.options.sourceApplication as Any,
        .annotation: context.options.annotation as Any,
        .openInPlace: context.options.openInPlace,
      ]
      _ = (app.delegate as? FlutterAppDelegate)?.application(app, open: context.url, options: options)
    }

    // Fans the URL out to Flutter plugins (including any implementing FlutterSceneLifeCycleDelegate).
    super.scene(scene, openURLContexts: URLContexts)
  }

  /// Universal-link style returns (Safari View Controller / ASWebAuthentication).
  override func scene(
    _ scene: UIScene,
    continue userActivity: NSUserActivity
  ) {
    #if canImport(Stripe)
    if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
       let url = userActivity.webpageURL {
      _ = StripeAPI.handleURLCallback(with: url)
    }
    #endif

    let app = UIApplication.shared
    _ = (app.delegate as? FlutterAppDelegate)?.application(
      app,
      continue: userActivity,
      restorationHandler: { _ in }
    )

    // Fans user activity out to Flutter plugins.
    super.scene(scene, continue: userActivity)
  }
}
