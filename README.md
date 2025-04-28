# 🔒 Ares Defence Labs Locksmith PDF

[![pub.dev](https://img.shields.io/pub/v/ares_defence_labs_lock_smith_pdf.svg)](https://pub.dev/packages/ares_defence_labs_lock_smith_pdf)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A Flutter plugin to **encrypt**, **decrypt**, and **manage PDF security** with **fine-grained permissions**.  
Supports **user password**, **owner password**, and control over PDF actions like **printing**, **copying**, **modifying**, **annotating**, and **filling forms**.

**iOS support is coming soon**.

---

## ✨ Features

- Password-protect PDFs using AES-256 encryption.
- Decrypt password-protected PDFs.
- Allow or restrict printing, copying, annotating, modifying, and form filling.
- Remove all security restrictions from a PDF & Decrypt
- Check if a PDF is encrypted or not

---

## 📦 Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  ares_defence_labs_lock_smith_pdf: ^0.0.1
```

Then run

```sh
    flutter pub get
```

To use the Api please import the library

```dart
import 'package:ares_defence_labs_lock_smith_pdf/ares_defence_labs_lock_smith_pdf.dart';

```

To generate a protected PDF with a passcode, please use the following (this enabled all permissions by default: Printing, Annotations Editing, etc):

```dart
await AresDefenceLabsLocksmithPdf.protectPdf(
  inputPath: '/path/to/input.pdf',
  outputPath: '/path/to/encrypted_output.pdf',
  password: 'SuperSecretPassword123',
);
```

You can also adjust the permissions of the document, and adding a owners passcode onto it too (this allows anyone who has decrypted the PDF to be able to adjust the permissions).

```dart
await AresDefenceLabsLocksmithPdf.protectPdfWithPermissions(
  inputPath: '/path/to/input.pdf',
  outputPath: '/path/to/secured_output.pdf',
  userPassword: 'EncryptionPasscode123',
  ownerPassword: 'PermissionsManagerPasscode456',
  permissions: [
    PermissionOption.print,
    PermissionOption.copy,
    PermissionOption.annotate,
  ],
);
```

To decrypt an encrypted PDF:

```dart

await AresDefenceLabsLocksmithPdf.decryptPdf(
  inputPath: '/path/to/encrypted.pdf',
  outputPath: '/path/to/decrypted_output.pdf',
  password: 'SuperSecret123',
);
```

To check if a PDF file is encrypted or not

```dart

bool isEncrypted = await AresDefenceLabsLocksmithPdf.isPdfEncrypted(
  inputPath: '/path/to/file.pdf',
);

if (isEncrypted) {
  print('The PDF is encrypted.');
} else {
  print('The PDF is not encrypted.');
}
```

To remove all permissions & security from a PDF file:

```dart
await AresDefenceLabsLocksmithPdf.removePdfSecurity(
  inputPath: '/path/to/protected.pdf',
  outputPath: '/path/to/unlocked_output.pdf',
  password: 'OwnerPass456',
);
```
