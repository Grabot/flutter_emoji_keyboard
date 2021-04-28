import Flutter
import UIKit

public class SwiftEmojiKeyboardFlutterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "emoji_keyboard_flutter", binaryMessenger: registrar.messenger())
    let instance = SwiftEmojiKeyboardFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
