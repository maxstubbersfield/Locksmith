import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:ares_defence_labs_lock_smith_pdf/ares_defence_labs_lock_smith_pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<String> getPdfFilePath(String fileName) async {
    final Directory appDir = await getApplicationDocumentsDirectory();

    // Ensure the file has .pdf extension
    final safeFileName = fileName.endsWith('.pdf') ? fileName : '$fileName.pdf';

    final String filePath = '${appDir.path}/$safeFileName';

    return filePath;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Column(
          children: [
            MaterialButton(
              child: Text("Encrypt PDF"),
              onPressed: () async {
                var pickedFile = await FilePicker.platform.pickFiles();
                if (pickedFile != null) {
                  var output = await getPdfFilePath("random_test");

                  await AresDefenceLabsLocksmithPdf.protectPdf(
                    inputPath: pickedFile.files.first.path!,
                    outputPath: output,
                    password: "secretPassword123",
                  ).then((e) async {
                    print(
                      "IS ENCRYPTED : ${await AresDefenceLabsLocksmithPdf.isPdfEncrypted(inputPath: output)}",
                    );
                    final params = ShareParams(
                      text: 'Sample PDF',
                      files: [XFile(output)],
                    );

                    final result = await SharePlus.instance.share(params);
                  });
                }
              },
            ),
            MaterialButton(
              child: Text("Encrypt PDF with Permissions"),
              onPressed: () async {
                var pickedFile = await FilePicker.platform.pickFiles();
                if (pickedFile != null) {
                  var output = await getPdfFilePath("random_test");

                  await AresDefenceLabsLocksmithPdf.protectPdfWithPermissions(
                    inputPath: pickedFile.files.first.path!,
                    outputPath: output,
                    userPassword: "secretPassword123",
                    ownerPassword: "permissionPassword",
                    permissions: [
                      PermissionOption.fillForms,
                      PermissionOption.modify,
                    ],
                  ).then((e) async {
                    final params = ShareParams(
                      text: 'Sample PDF',
                      files: [XFile(output)],
                    );

                    final result = await SharePlus.instance.share(params);
                  });
                }
              },
            ),
            MaterialButton(
              child: Text("Decrypt PDF"),
              onPressed: () async {
                var pickedFile = await FilePicker.platform.pickFiles();
                if (pickedFile != null) {
                  var output = await getPdfFilePath("random_test");

                  await AresDefenceLabsLocksmithPdf.decryptPdf(
                    inputPath: pickedFile.files.first.path!,
                    outputPath: output,
                    password: "",
                  ).then((e) async {
                    final params = ShareParams(
                      text: 'Sample PDF',
                      files: [XFile(output)],
                    );

                    final result = await SharePlus.instance.share(params);
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
