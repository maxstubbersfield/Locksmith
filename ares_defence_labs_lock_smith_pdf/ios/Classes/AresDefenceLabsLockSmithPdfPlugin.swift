import Flutter
import UIKit
import PDFKit
import CoreGraphics

@available(iOS 16.0, *)
public class LocksmithPdfPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "locksmith_pdf", binaryMessenger: registrar.messenger())
        let instance = LocksmithPdfPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "protectPdf" {
            guard let args = call.arguments as? [String: Any],
                  let inputPath = args["inputPath"] as? String,
                  let outputPath = args["outputPath"] as? String,
                  let password = args["password"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing required arguments", details: nil))
                return
            }

            let inputUrl = URL(fileURLWithPath: inputPath)
            let outputUrl = URL(fileURLWithPath: outputPath)

            guard let document = PDFDocument(url: inputUrl) else {
                result(FlutterError(code: "LOAD_FAILED", message: "Could not load PDF", details: nil))
                return
            }

            if document.isEncrypted {
                result(FlutterError(code: "ALREADY_ENCRYPTED", message: "Input PDF is already encrypted. Cannot re-encrypt.", details: nil))
                return
            }

            guard document.pageCount > 0 else {
                result(FlutterError(code: "INVALID_PDF", message: "PDF document has no pages.", details: nil))
                return
            }

            if #available(iOS 16.0, *) {
                let options: [String: Any] = [
                    kCGPDFContextUserPassword as String: password,
                    kCGPDFContextOwnerPassword as String: password,
                    kCGPDFContextEncryptionKeyLength as String: 256
                ]

                if let protectedData = document.dataRepresentation(options: options) {
                    do {
                        try protectedData.write(to: outputUrl)
                        result(true)
                    } catch {
                        result(FlutterError(code: "WRITE_FAILED", message: "Failed to save encrypted PDF", details: error.localizedDescription))
                    }
                } else {
                    result(FlutterError(code: "ENCRYPTION_FAILED", message: "Failed to generate encrypted PDF data (possibly invalid PDF structure).", details: nil))
                }
            } else {
                result(FlutterError(code: "UNSUPPORTED_VERSION", message: "Password protection requires iOS 16 or newer.", details: nil))
            }
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
}