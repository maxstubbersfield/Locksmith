import 'dart:async';
import 'package:flutter/services.dart';

class AresDefenceLabsLocksmithPdf {
  static const MethodChannel _channel = MethodChannel('locksmith_pdf');

  /// Encrypt a PDF with a user password (simple)
  static Future<void> protectPdf({
    required String inputPath,
    required String outputPath,
    required String password,
  }) async {
    await _channel.invokeMethod('protectPdf', {
      'inputPath': inputPath,
      'outputPath': outputPath,
      'password': password,
    });
  }

  /// Encrypt a PDF with user + owner password and custom permissions
  static Future<void> protectPdfWithPermissions({
    required String inputPath,
    required String outputPath,
    required String userPassword,
    required String ownerPassword,
    List<PermissionOption> permissions = const [],
  }) async {
    await _channel.invokeMethod('protectPdfWithPermissions', {
      'inputPath': inputPath,
      'outputPath': outputPath,
      'userPassword': userPassword,
      'ownerPassword': ownerPassword,
      'permissions': permissions.map((e) => e.name).toList(),
    });
  }

  /// Decrypt a password-protected PDF
  static Future<void> decryptPdf({
    required String inputPath,
    required String outputPath,
    required String password,
  }) async {
    await _channel.invokeMethod('decryptPdf', {
      'inputPath': inputPath,
      'outputPath': outputPath,
      'password': password,
    });
  }

  /// Check if a PDF file is encrypted
  static Future<bool> isPdfEncrypted({
    required String inputPath,
  }) async {
    final bool isEncrypted = await _channel.invokeMethod('isPdfEncrypted', {
      'inputPath': inputPath,
    });
    return isEncrypted;
  }

  /// Remove all security from a PDF (if password known)
  static Future<void> removePdfSecurity({
    required String inputPath,
    required String outputPath,
    required String password,
  }) async {
    await _channel.invokeMethod('removePdfSecurity', {
      'inputPath': inputPath,
      'outputPath': outputPath,
      'password': password,
    });
  }
}

enum PermissionOption {
  print, // Allow printing
  copy, // Allow content copying
  modify, // Allow content modifications
  fillForms, // Allow filling forms
  annotate, // Allow adding annotations
}
