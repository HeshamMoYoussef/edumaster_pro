import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/core/theme/app_theme.dart';
import 'app/core/utils/storage_service.dart';
import 'app/core/services/notification_service.dart';
import 'app/core/services/session_reminder_service.dart';
import 'app/routes/app_pages.dart';
import 'app/translations/app_translations.dart';
import 'app/global/bindings/initial_binding.dart';
import 'app/global/controllers/locale_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetStorage for local persistence
  await GetStorage.init();
  await GetStorage.init('EduMasterPro');

  // Initialize StorageService FIRST before anything else
  final storageService = StorageService();
  await storageService.init();
  Get.put(storageService, permanent: true);

  // Initialize date formatting for Arabic
  await initializeDateFormatting('ar', null);

  // Initialize Notification Service
  await Get.putAsync(() => NotificationService().init(), permanent: true);

  // Initialize Session Reminder Service
  await Get.putAsync(() => SessionReminderService().init(), permanent: true);

  // Request notification permissions
  await NotificationService.to.requestPermissions();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const EduMasterApp());
}

/// Main application widget
class EduMasterApp extends StatelessWidget {
  const EduMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'EduMaster Pro',
      debugShowCheckedModeBanner: false,

      // Theme configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Translations
      translations: AppTranslations(),
      locale: LocaleController.arabicLocale,
      fallbackLocale: LocaleController.englishLocale,

      // Localization delegates
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LocaleController.supportedLocales,

      // Initial binding for dependency injection
      initialBinding: InitialBinding(),

      // Routes configuration
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,

      // Default transition
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),

      // Builder for RTL support
      builder: (context, child) {
        return Directionality(
          textDirection: Get.locale?.languageCode == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: child ?? const SizedBox(),
        );
      },
    );
  }
}
