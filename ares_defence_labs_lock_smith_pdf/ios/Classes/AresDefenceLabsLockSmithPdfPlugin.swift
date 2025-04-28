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
        switch call.method {
        case "protectPdf":
            protectPdf(call: call, result: result)

        case "protectPdfWithPermissions":
            protectPdfWithPermissions(call: call, result: result)

        case "decryptPdf":
            decryptPdf(call: call, result: result)

        case "isPdfEncrypted":
            isPdfEncrypted(call: call, result: result)

        case "removePdfSecurity":
            removePdfSecurity(call: call, result: result)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func protectPdf(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let inputPath = args["inputPath"] as? String,
              let outputPath = args["outputPath"] as? String,
              let password = args["password"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing required arguments", details: nil))
            return
        }

        protectPdfInternal(
            inputPath: inputPath,
            outputPath: outputPath,
            userPassword: password,
            ownerPassword: password,
            permissions: [],
            result: result
        )
    }

    private func protectPdfWithPermissions(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let inputPath = args["inputPath"] as? String,
              let outputPath = args["outputPath"] as? String,
              let userPassword = args["userPassword"] as? String,
              let ownerPassword = args["ownerPassword"] as? String,
              let permissions = args["permissions"] as? [String] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing required arguments", details: nil))
            return
        }

        protectPdfInternal(
            inputPath: inputPath,
            outputPath: outputPath,
            userPassword: userPassword,
            ownerPassword: ownerPassword,
            permissions: permissions,
            result: result
        )
    }

    private func decryptPdf(call: FlutterMethodCall, result: @escaping FlutterResult) {
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
            let success = document.unlock(withPassword: password)
            if !success {
                result(FlutterError(code: "WRONG_PASSWORD", message: "Incorrect password for PDF", details: nil))
                return
            }
        }

        guard let data = document.dataRepresentation() else {
            result(FlutterError(code: "DECRYPTION_FAILED", message: "Failed to create decrypted PDF data", details: nil))
            return
        }

        do {
            try data.write(to: outputUrl)
            result(true)
        } catch {
            result(FlutterError(code: "WRITE_FAILED", message: "Failed to save decrypted PDF", details: error.localizedDescription))
        }
    }

    private func isPdfEncrypted(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let inputPath = args["inputPath"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing required arguments", details: nil))
            return
        }

        let inputUrl = URL(fileURLWithPath: inputPath)

        guard let document = PDFDocument(url: inputUrl) else {
            result(FlutterError(code: "LOAD_FAILED", message: "Could not load PDF", details: nil))
            return
        }

        result(document.isEncrypted)
    }

    private func removePdfSecurity(call: FlutterMethodCall, result: @escaping FlutterResult) {
        // This is basically a "decrypt" and save.
        decryptPdf(call: call, result: result)
    }

    private func protectPdfInternal(
        inputPath: String,
        outputPath: String,
        userPassword: String,
        ownerPassword: String,
        permissions: [String],
        result: @escaping FlutterResult
    ) {
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

        let options: [String: Any] = [
            kCGPDFContextUserPassword as String: userPassword,
            kCGPDFContextOwnerPassword as String: ownerPassword,
            kCGPDFContextEncryptionKeyLength as String: 256,
            kCGPDFContextAllowsPrinting as String: permissions.contains("print"),
            kCGPDFContextAllowsCopying as String: permissions.contains("copy"),
            kCGPDFContextAllowsEditing as String: permissions.contains("modify"),
            kCGPDFContextAllowsCommenting as String: permissions.contains("annotate"),
            kCGPDFContextAllowsFillingForms as String: permissions.contains("fillForms")
        ]

        if let protectedData = document.dataRepresentation(options: options) {
            do {
                try protectedData.write(to: outputUrl)
                result(true)
            } catch {
                result(FlutterError(code: "WRITE_FAILED", message: "Failed to save encrypted PDF", details: error.localizedDescription))
            }
        } else {
            result(FlutterError(code: "ENCRYPTION_FAILED", message: "Failed to generate encrypted PDF data.", details: nil))
        }
    }
}