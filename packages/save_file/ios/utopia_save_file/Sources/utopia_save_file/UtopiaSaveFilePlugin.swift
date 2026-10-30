import Flutter
import UIKit

public class UtopiaSaveFilePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "utopia_save_file", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(UtopiaSaveFilePlugin(), channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "share":
      let arguments = call.arguments as! [String: Any]
      share(
        URL(fileURLWithPath: arguments["path"] as! String),
        origin: Self.parseRect(arguments["origin"]),
        result: result
      )
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func share(_ url: URL, origin: CGRect?, result: @escaping FlutterResult) {
    guard let presenter = Self.topViewController() else {
      result(FlutterError(code: "no_view_controller", message: "No view controller to present the share sheet from", details: nil))
      return
    }

    let controller = UIActivityViewController(activityItems: [url], applicationActivities: nil)
    var isCompleted = false
    controller.completionWithItemsHandler = { _, completed, _, error in
      guard !isCompleted else { return }
      isCompleted = true
      if let error = error {
        result(FlutterError(code: "share_failed", message: error.localizedDescription, details: nil))
      } else {
        result(completed)
      }
    }

    if let popover = controller.popoverPresentationController {
      let view = presenter.view!
      popover.sourceView = view
      if let origin = origin, !origin.isEmpty {
        popover.sourceRect = origin
      } else {
        popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
        popover.permittedArrowDirections = []
      }
    }

    presenter.present(controller, animated: true)
  }

  private static func parseRect(_ value: Any?) -> CGRect? {
    guard let values = value as? [Double], values.count == 4 else { return nil }
    return CGRect(x: values[0], y: values[1], width: values[2], height: values[3])
  }

  private static func topViewController() -> UIViewController? {
    var controller = keyWindow()?.rootViewController
    while let presented = controller?.presentedViewController, !presented.isBeingDismissed {
      controller = presented
    }
    return controller
  }

  private static func keyWindow() -> UIWindow? {
    if #available(iOS 13.0, *) {
      let windows = UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .flatMap { $0.windows }
      return windows.first { $0.isKeyWindow } ?? windows.first
    }
    return UIApplication.shared.keyWindow
  }
}
