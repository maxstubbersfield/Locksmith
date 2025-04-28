package com.aresdefencelabs.locksmith_pdf

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import com.tom_roush.pdfbox.pdmodel.PDDocument
import com.tom_roush.pdfbox.pdmodel.encryption.AccessPermission
import com.tom_roush.pdfbox.pdmodel.encryption.StandardProtectionPolicy
import java.io.File
import com.tom_roush.pdfbox.pdmodel.encryption.InvalidPasswordException
import com.tom_roush.pdfbox.io.MemoryUsageSetting

class LocksmithPdfPlugin: FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "locksmith_pdf")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "protectPdf" -> protectPdf(call, result)
            "protectPdfWithPermissions" -> protectPdfWithPermissions(call, result)
            "decryptPdf" -> decryptPdf(call, result)
            "isPdfEncrypted" -> isPdfEncrypted(call, result)
            "removePdfSecurity" -> removePdfSecurity(call, result)
            else -> result.notImplemented()
        }
    }

    private fun protectPdf(call: MethodCall, result: Result) {
        val inputPath = call.argument<String>("inputPath")
        val outputPath = call.argument<String>("outputPath")
        val password = call.argument<String>("password")

        if (inputPath == null || outputPath == null || password == null) {
            result.error("INVALID_ARGUMENTS", "Missing arguments", null)
            return
        }

        try {
            val inputFile = File(inputPath)
            val outputFile = File(outputPath)

            val document = PDDocument.load(inputFile)

            val accessPermission = AccessPermission()
            val protectionPolicy = StandardProtectionPolicy(password, password, accessPermission)
            protectionPolicy.encryptionKeyLength = 256
            protectionPolicy.permissions = accessPermission

            document.protect(protectionPolicy)
            document.save(outputFile)
            document.close()

            result.success(true)
        } catch (e: Exception) {
            result.error("PROTECT_FAILED", e.message, e)
        }
    }

    private fun protectPdfWithPermissions(call: MethodCall, result: Result) {
    val inputPath = call.argument<String>("inputPath")
    val outputPath = call.argument<String>("outputPath")
    val userPassword = call.argument<String>("userPassword")
    val ownerPassword = call.argument<String>("ownerPassword")
    val permissionsList = call.argument<List<String>>("permissions") ?: listOf()

    if (inputPath == null || outputPath == null || userPassword == null || ownerPassword == null) {
        result.error("INVALID_ARGUMENTS", "Missing arguments", null)
        return
    }

    try {
        val inputFile = File(inputPath)
        val outputFile = File(outputPath)

        if (!inputFile.exists()) {
            result.error("FILE_NOT_FOUND", "Input file not found", null)
            return
        }

        val document = PDDocument.load(inputFile)

        val accessPermission = AccessPermission()

        // 🔥 Lock everything down first
        accessPermission.setCanPrint(false)
        accessPermission.setCanExtractContent(false)
        accessPermission.setCanModify(false)
        accessPermission.setCanFillInForm(false)
        accessPermission.setCanModifyAnnotations(false)

        // 🔥 Only enable permissions if explicitly allowed
        for (perm in permissionsList) {
            when (perm) {
                "print" -> accessPermission.setCanPrint(true)
                "copy" -> accessPermission.setCanExtractContent(true)
                "modify" -> accessPermission.setCanModify(true)
                "fillForms" -> accessPermission.setCanFillInForm(true)
                "annotate" -> accessPermission.setCanModifyAnnotations(true)
            }
        }

        val protectionPolicy = StandardProtectionPolicy(ownerPassword, userPassword, accessPermission)
        protectionPolicy.encryptionKeyLength = 256
        protectionPolicy.permissions = accessPermission

        document.protect(protectionPolicy)
        document.save(outputFile)
        document.close()

        result.success(true)
    } catch (e: Exception) {
        result.error("PROTECT_WITH_PERMISSIONS_FAILED", e.message, e)
    }
}

    private fun decryptPdf(call: MethodCall, result: Result) {
        val inputPath = call.argument<String>("inputPath")
        val outputPath = call.argument<String>("outputPath")
        val password = call.argument<String>("password")

        if (inputPath == null || outputPath == null || password == null) {
            result.error("INVALID_ARGUMENTS", "Missing arguments", null)
            return
        }

        try {
            val inputFile = File(inputPath)
            val outputFile = File(outputPath)

            val document = PDDocument.load(inputFile, password)

            document.setAllSecurityToBeRemoved(true)
            document.save(outputFile)
            document.close()

            result.success(true)
        } catch (e: Exception) {
            result.error("DECRYPT_FAILED", e.message, e)
        }
    }

    private fun isPdfEncrypted(call: MethodCall, result: Result) {
    val inputPath = call.argument<String>("inputPath")

    if (inputPath == null) {
        result.error("INVALID_ARGUMENTS", "Missing inputPath", null)
        return
    }

    try {
        val inputFile = File(inputPath)

        // ✅ Explicitly specify memory usage setting
        val document = PDDocument.load(inputFile, MemoryUsageSetting.setupMainMemoryOnly())

        val isEncrypted = document.isEncrypted
        document.close()

        result.success(isEncrypted)
    } catch (e: InvalidPasswordException) {
        // 🎯 If PDF cannot be opened because it is encrypted
        result.success(true)
    } catch (e: Exception) {
        result.error("CHECK_ENCRYPTED_FAILED", e.message, e)
    }
}

    private fun removePdfSecurity(call: MethodCall, result: Result) {
        val inputPath = call.argument<String>("inputPath")
        val outputPath = call.argument<String>("outputPath")
        val password = call.argument<String>("password")

        if (inputPath == null || outputPath == null || password == null) {
            result.error("INVALID_ARGUMENTS", "Missing arguments", null)
            return
        }

        try {
            val inputFile = File(inputPath)
            val outputFile = File(outputPath)

            val document = PDDocument.load(inputFile, password)

            document.setAllSecurityToBeRemoved(true)
            document.save(outputFile)
            document.close()

            result.success(true)
        } catch (e: Exception) {
            result.error("REMOVE_SECURITY_FAILED", e.message, e)
        }
    }
}