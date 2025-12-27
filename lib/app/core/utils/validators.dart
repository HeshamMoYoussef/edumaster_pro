import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';

/// Custom validators for reactive forms
class AppValidators {
  AppValidators._();

  /// Validates that a value is not empty
  static Map<String, dynamic>? requiredValidator(AbstractControl control) {
    if (control.value == null || control.value.toString().trim().isEmpty) {
      return {'required': true};
    }
    return null;
  }

  /// Validates email format
  static Map<String, dynamic>? emailValidator(AbstractControl control) {
    if (control.value == null || control.value.toString().isEmpty) {
      return null; // Let required validator handle empty
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(control.value.toString())) {
      return {'email': true};
    }
    return null;
  }

  /// Validates password strength
  /// - Minimum 8 characters
  /// - At least one uppercase letter
  /// - At least one lowercase letter
  /// - At least one number
  static Map<String, dynamic>? passwordValidator(AbstractControl control) {
    if (control.value == null || control.value.toString().isEmpty) {
      return null;
    }

    final password = control.value.toString();
    final errors = <String, dynamic>{};

    if (password.length < 8) {
      errors['minLength'] = {'requiredLength': 8, 'actualLength': password.length};
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      errors['uppercase'] = true;
    }

    if (!RegExp(r'[a-z]').hasMatch(password)) {
      errors['lowercase'] = true;
    }

    if (!RegExp(r'[0-9]').hasMatch(password)) {
      errors['digit'] = true;
    }

    return errors.isEmpty ? null : {'password': errors};
  }

  /// Validates phone number format
  static Map<String, dynamic>? phoneValidator(AbstractControl control) {
    if (control.value == null || control.value.toString().isEmpty) {
      return null;
    }

    final phone = control.value.toString().replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Accept various formats: +966, 05, 5, etc.
    final phoneRegex = RegExp(r'^(\+?966|0)?5[0-9]{8}$');

    if (!phoneRegex.hasMatch(phone)) {
      return {'phone': true};
    }
    return null;
  }

  /// Validates that password matches confirmation
  static ValidatorFunction mustMatch(String controlName, String matchingControlName) {
    return (AbstractControl control) {
      if (control is! FormGroup) return null;

      final formGroup = control;
      final controlValue = formGroup.control(controlName).value;
      final matchingControlValue = formGroup.control(matchingControlName).value;

      if (controlValue != matchingControlValue) {
        formGroup.control(matchingControlName).setErrors({'mustMatch': true});
        return {'mustMatch': true};
      }

      formGroup.control(matchingControlName).removeError('mustMatch');
      return null;
    };
  }

  /// Validates minimum length
  static ValidatorFunction minLength(int length) {
    return (AbstractControl control) {
      if (control.value == null || control.value.toString().isEmpty) {
        return null;
      }

      if (control.value.toString().length < length) {
        return {
          'minLength': {
            'requiredLength': length,
            'actualLength': control.value.toString().length,
          }
        };
      }
      return null;
    };
  }

  /// Validates maximum length
  static ValidatorFunction maxLength(int length) {
    return (AbstractControl control) {
      if (control.value == null) return null;

      if (control.value.toString().length > length) {
        return {
          'maxLength': {
            'requiredLength': length,
            'actualLength': control.value.toString().length,
          }
        };
      }
      return null;
    };
  }

  /// Validates OTP code (6 digits)
  static Map<String, dynamic>? otpValidator(AbstractControl control) {
    if (control.value == null || control.value.toString().isEmpty) {
      return null;
    }

    final otp = control.value.toString();

    if (otp.length != 6 || !RegExp(r'^[0-9]{6}$').hasMatch(otp)) {
      return {'otp': true};
    }
    return null;
  }

  /// Validates URL format
  static Map<String, dynamic>? urlValidator(AbstractControl control) {
    if (control.value == null || control.value.toString().isEmpty) {
      return null;
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(control.value.toString())) {
      return {'url': true};
    }
    return null;
  }

  /// Validates numeric value within range
  static ValidatorFunction numberRange(num min, num max) {
    return (AbstractControl control) {
      if (control.value == null) return null;

      final value = num.tryParse(control.value.toString());
      if (value == null) {
        return {'number': true};
      }

      if (value < min || value > max) {
        return {
          'range': {'min': min, 'max': max, 'actual': value}
        };
      }
      return null;
    };
  }

  /// Validates date is in the future
  static Map<String, dynamic>? futureDateValidator(AbstractControl control) {
    if (control.value == null) return null;

    DateTime? date;
    if (control.value is DateTime) {
      date = control.value as DateTime;
    } else if (control.value is String) {
      date = DateTime.tryParse(control.value as String);
    }

    if (date == null) {
      return {'date': true};
    }

    if (date.isBefore(DateTime.now())) {
      return {'futureDate': true};
    }
    return null;
  }

  /// Validates date is in the past
  static Map<String, dynamic>? pastDateValidator(AbstractControl control) {
    if (control.value == null) return null;

    DateTime? date;
    if (control.value is DateTime) {
      date = control.value as DateTime;
    } else if (control.value is String) {
      date = DateTime.tryParse(control.value as String);
    }

    if (date == null) {
      return {'date': true};
    }

    if (date.isAfter(DateTime.now())) {
      return {'pastDate': true};
    }
    return null;
  }

  /// Validates age is at least a certain number
  static ValidatorFunction minAge(int minYears) {
    return (AbstractControl control) {
      if (control.value == null) return null;

      DateTime? birthDate;
      if (control.value is DateTime) {
        birthDate = control.value as DateTime;
      } else if (control.value is String) {
        birthDate = DateTime.tryParse(control.value as String);
      }

      if (birthDate == null) {
        return {'date': true};
      }

      final today = DateTime.now();
      int age = today.year - birthDate.year;

      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }

      if (age < minYears) {
        return {'minAge': {'required': minYears, 'actual': age}};
      }
      return null;
    };
  }
}

/// Extension to get localized error messages
extension ValidationMessageExtension on Map<String, dynamic> {
  /// Get localized error message
  String getErrorMessage(String fieldName) {
    if (containsKey('required')) {
      return 'validation_field_required'.tr;
    }
    if (containsKey('email')) {
      return 'invalid_email'.tr;
    }
    if (containsKey('password')) {
      final passwordErrors = this['password'] as Map<String, dynamic>;
      if (passwordErrors.containsKey('minLength')) {
        return 'validation_password_min_length'.tr;
      }
      if (passwordErrors.containsKey('uppercase')) {
        return 'validation_password_uppercase'.tr;
      }
      if (passwordErrors.containsKey('lowercase')) {
        return 'validation_password_lowercase'.tr;
      }
      if (passwordErrors.containsKey('digit')) {
        return 'validation_password_digit'.tr;
      }
    }
    if (containsKey('mustMatch')) {
      return 'passwords_not_match'.tr;
    }
    if (containsKey('phone')) {
      return 'invalid_phone'.tr;
    }
    if (containsKey('otp')) {
      return 'validation_otp_invalid'.tr;
    }
    if (containsKey('minLength')) {
      final minLengthError = this['minLength'] as Map<String, dynamic>;
      return 'validation_min_length'.trParams({'length': '${minLengthError['requiredLength']}'});
    }
    if (containsKey('maxLength')) {
      final maxLengthError = this['maxLength'] as Map<String, dynamic>;
      return 'validation_max_length'.trParams({'length': '${maxLengthError['requiredLength']}'});
    }
    if (containsKey('url')) {
      return 'validation_invalid_url'.tr;
    }
    if (containsKey('range')) {
      final rangeError = this['range'] as Map<String, dynamic>;
      return 'validation_range'.trParams({'min': '${rangeError['min']}', 'max': '${rangeError['max']}'});
    }
    if (containsKey('futureDate')) {
      return 'validation_future_date'.tr;
    }
    if (containsKey('pastDate')) {
      return 'validation_past_date'.tr;
    }
    if (containsKey('minAge')) {
      final minAgeError = this['minAge'] as Map<String, dynamic>;
      return 'validation_min_age'.trParams({'years': '${minAgeError['required']}'});
    }
    return 'validation_invalid_value'.tr;
  }
}
