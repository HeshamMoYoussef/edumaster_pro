import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/storage_service.dart';
import '../../routes/app_routes.dart';

/// Middleware to check authentication status
class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final storage = Get.find<StorageService>();

    // If not logged in, redirect to login
    if (!storage.isLoggedIn) {
      return const RouteSettings(name: Routes.login);
    }

    return null;
  }
}

/// Middleware to prevent authenticated users from accessing auth pages
class GuestMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final storage = Get.find<StorageService>();

    // If logged in, redirect to main
    if (storage.isLoggedIn) {
      return const RouteSettings(name: Routes.main);
    }

    return null;
  }
}

/// Middleware to check if user has completed onboarding
class OnboardingMiddleware extends GetMiddleware {
  @override
  int? get priority => 2;

  @override
  RouteSettings? redirect(String? route) {
    final storage = Get.find<StorageService>();

    // If first time user, show onboarding
    if (storage.isFirstTime) {
      return const RouteSettings(name: Routes.onboarding);
    }

    return null;
  }
}

/// Middleware to check parent role
class ParentMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final storage = Get.find<StorageService>();

    // Check if user is parent
    final userData = storage.getUserData();
    if (userData == null || userData['role'] != 'parent') {
      return const RouteSettings(name: Routes.main);
    }

    return null;
  }
}

/// Middleware to check teacher role
class TeacherMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final storage = Get.find<StorageService>();

    // Check if user is teacher
    final userData = storage.getUserData();
    if (userData == null || userData['role'] != 'teacher') {
      return const RouteSettings(name: Routes.main);
    }

    return null;
  }
}
