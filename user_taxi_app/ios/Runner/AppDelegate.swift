import Flutter
import UIKit
import GoogleMaps
import metamask_ios_sdk
import SwiftUI

@main
@objc class AppDelegate: FlutterAppDelegate, ObservableObject {
  @ObservedObject var metamaskSDK = MetaMaskSDK.shared(
    AppMetadata(name: "MetaMask", url: "https://metamask.io/"))
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let metamaskChannel = FlutterMethodChannel(name: "metamask",
                                                binaryMessenger: controller.binaryMessenger)
    metamaskChannel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "connectToMetaMask" {
        Task {
        await self?.connectToMetaMask(result: result)
      }
      }
    })
    GeneratedPluginRegistrant.register(with: self)

    GMSServices.provideAPIKey("AIzaSyAJI-buaRrNN3x2RASJk6yv_UltK2fePzM")

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func connectToMetaMask(result: @escaping FlutterResult) async {
    await metamaskSDK.connect()
    result("Connected to MetaMask")
  }
}
