import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:habit_tracker/core/config/app_config.dart';

class RateAppOutcome {
  const RateAppOutcome({
    required this.success,
    required this.usedInAppReview,
    required this.openedStoreListing,
  });

  final bool success;
  final bool usedInAppReview;
  final bool openedStoreListing;
}

class ReportIssueOutcome {
  const ReportIssueOutcome({
    required this.success,
    required this.logReady,
    this.logSizeBytes,
  });

  final bool success;
  final bool logReady;
  final int? logSizeBytes;
}

class SupportService {
  SupportService({
    InAppReview? inAppReview,
    Future<PackageInfo> Function()? packageInfoProvider,
    Future<Directory> Function()? tempDirectoryProvider,
    Future<bool> Function(Uri url, LaunchMode mode)? launcher,
    Future<void> Function(Email email)? emailSender,
    DateTime Function()? clock,
  }) : _inAppReview = inAppReview ?? InAppReview.instance,
      _packageInfoProvider = packageInfoProvider ?? PackageInfo.fromPlatform,
      _tempDirectoryProvider = tempDirectoryProvider ?? getTemporaryDirectory,
      _launchUrl = launcher ?? ((uri, mode) => launchUrl(uri, mode: mode)),
      _sendEmail = emailSender ?? FlutterEmailSender.send,
      _clock = clock ?? DateTime.now;

  final InAppReview _inAppReview;
  final Future<PackageInfo> Function() _packageInfoProvider;
  final Future<Directory> Function() _tempDirectoryProvider;
  final Future<bool> Function(Uri url, LaunchMode mode) _launchUrl;
  final Future<void> Function(Email email) _sendEmail;
  final DateTime Function() _clock;

  Future<RateAppOutcome> rateApp() async {
    var usedInAppReview = false;
    try {
      final available = await _inAppReview.isAvailable();
      if (available) {
        await _inAppReview.requestReview();
        usedInAppReview = true;
        return RateAppOutcome(
          success: true,
          usedInAppReview: true,
          openedStoreListing: false,
        );
      }
    } catch (_) {
      usedInAppReview = false;
    }

    final storeUrl = _resolveStoreUrl();
    if (storeUrl != null) {
      final launched = await _launchUrl(
        storeUrl,
        LaunchMode.externalApplication,
      );
      if (launched) {
        return RateAppOutcome(
          success: true,
          usedInAppReview: usedInAppReview,
          openedStoreListing: true,
        );
      }
    }

    return RateAppOutcome(
      success: false,
      usedInAppReview: usedInAppReview,
      openedStoreListing: false,
    );
  }

  Future<ReportIssueOutcome> reportIssue({PackageInfo? packageInfo}) async {
    try {
      final info = packageInfo ?? await _packageInfoProvider();
      final logFile = await _createSupportLog(info);
      final logExists = await logFile.exists();
      final logSize = logExists ? await logFile.length() : null;
      final baseBody = _buildEmailBody(info);

      try {
        final email = Email(
          subject: 'Habit Tracker Support Request',
          recipients: <String>[AppConfig.supportEmail],
          body: baseBody,
          attachmentPaths: logExists
              ? <String>[logFile.path]
              : const <String>[],
        );
        await _sendEmail(email);
        return ReportIssueOutcome(
          success: true,
          logReady: logExists,
          logSizeBytes: logSize,
        );
      } catch (_) {
        // fall back to mailto launch below
      }

      final fallbackBody = logExists
          ? '$baseBody\n\n--- Support log ---\n${await logFile.readAsString()}'
          : baseBody;
      final uri = Uri(
        scheme: 'mailto',
        path: AppConfig.supportEmail,
        queryParameters: <String, String>{
          'subject': 'Habit Tracker Support Request',
          'body': fallbackBody,
        },
      );
      final launched = await _launchUrl(
        uri,
        LaunchMode.externalApplication,
      );
      if (launched) {
        return const ReportIssueOutcome(
          success: true,
          logReady: false,
        );
      }

      return const ReportIssueOutcome(success: false, logReady: false);
    } catch (_) {
      return const ReportIssueOutcome(success: false, logReady: false);
    }
  }

  Uri? _resolveStoreUrl() {
    final urlString = kIsWeb
        ? AppConfig.playStoreUrl
        : Platform.isIOS
        ? AppConfig.appStoreUrl
        : AppConfig.playStoreUrl;
    if (urlString.isEmpty) return null;
    return Uri.tryParse(urlString);
  }

  Future<File> _createSupportLog(PackageInfo info) async {
    final directory = await _tempDirectoryProvider();
    final timestamp = _clock().toUtc().toIso8601String().replaceAll(':', '_');
    final file = File('${directory.path}/habit_tracker_support_$timestamp.txt');
    final buffer = StringBuffer()
      ..writeln('Habit Tracker Support Log')
      ..writeln('Generated: ${_clock().toUtc()}')
      ..writeln('Environment: ${AppConfig.environment.name}')
      ..writeln('App: ${info.appName}')
      ..writeln('Package: ${info.packageName}')
      ..writeln('Version: ${info.version} (${info.buildNumber})')
      ..writeln('Platform: ${kIsWeb ? 'web' : Platform.operatingSystem}')
      ..writeln(
        'OS Version: ${kIsWeb ? 'n/a' : Platform.operatingSystemVersion}',
      )
      ..writeln()
      ..writeln('No additional logs were captured for this session.');

    final contents = buffer.toString();
    if (contents.length > 1024 * 1024) {
      return file;
    }
    return file.writeAsString(contents);
  }

  String _buildEmailBody(PackageInfo info) {
    return 'Hello Habit Tracker team,\n\n'
        'I would like to report an issue. Please find the attached log for details.\n\n'
        'App version: ${info.version} (${info.buildNumber})\n'
        'Environment: ${AppConfig.environment.name}\n'
        'Platform: ${kIsWeb ? 'web' : Platform.operatingSystem}\n\n'
        'Describe the issue here:\n';
  }
}

final supportServiceProvider = Provider<SupportService>((ref) {
  return SupportService();
});
