import 'package:flutter/material.dart';
import 'package:qatar_document_expiry_tracker/app_scope.dart';
import 'package:qatar_document_expiry_tracker/data/document_repository.dart';
import 'package:qatar_document_expiry_tracker/data/local_store.dart';
import 'package:qatar_document_expiry_tracker/data/settings_repository.dart';
import 'package:qatar_document_expiry_tracker/screens/home/home_screen.dart';
import 'package:qatar_document_expiry_tracker/screens/onboarding/onboarding_screen.dart';
import 'package:qatar_document_expiry_tracker/services/notification_service.dart';
import 'package:qatar_document_expiry_tracker/services/photo_service.dart';
import 'package:qatar_document_expiry_tracker/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalStore.init();

  final notifications = NotificationService();
  await notifications.init();

  final documents = DocumentRepository();
  final settings = SettingsRepository();
  final photos = PhotoService();

  // Reconcile schedules after cold start (covers reboot gaps on some OS versions).
  await notifications.rescheduleAll(
    documents.getAll(),
    settings.getReminderSettings(),
  );

  runApp(
    AppScope(
      documents: documents,
      settings: settings,
      notifications: notifications,
      photos: photos,
      child: QatarDocsApp(onboardingComplete: settings.isOnboardingComplete),
    ),
  );
}

class QatarDocsApp extends StatelessWidget {
  const QatarDocsApp({super.key, required this.onboardingComplete});

  final bool onboardingComplete;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qatar Docs',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: onboardingComplete
          ? const HomeScreen()
          : const OnboardingTypeScreen(),
    );
  }
}
