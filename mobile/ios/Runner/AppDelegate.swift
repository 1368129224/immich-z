import Flutter
import SwiftUI
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    let launched = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    // Retain the storyboard's FlutterViewController so the migration preview can
    // return to the full Flutter app without losing its engine or plugin state.
    let flutterController = window?.rootViewController
    window?.rootViewController = UIHostingController(rootView: NativeImmichRootView(onUseFlutter: { [weak self] in
      guard let flutterController else { return }
      self?.window?.rootViewController = flutterController
      self?.window?.makeKeyAndVisible()
    }))
    window?.makeKeyAndVisible()
    return launched
  }
}
