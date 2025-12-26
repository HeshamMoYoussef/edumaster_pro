import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/color_constants.dart';

/// Custom text field widget with Reactive Forms
class CustomTextField extends StatelessWidget {
  final String formControlName;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;
  final int? maxLength;
  final bool enabled;
  final Map<String, String Function(Object)>? validationMessages;
  final void Function(FormControl<dynamic>)? onChanged;

  const CustomTextField({
    super.key,
    required this.formControlName,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.validationMessages,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
        ],
        ReactiveTextField<String>(
          formControlName: formControlName,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          maxLines: maxLines,
          maxLength: maxLength,
          readOnly: !enabled,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
            suffixIcon: suffixIcon,
            counterText: '',
          ),
          validationMessages: validationMessages,
        ),
      ],
    );
  }
}

/// Custom search field
class CustomSearchField extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final TextEditingController? controller;

  const CustomSearchField({
    super.key,
    this.hint = 'ابحث...',
    this.onChanged,
    this.onClear,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: controller?.text.isNotEmpty == true
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller?.clear();
                    onClear?.call();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
      ),
    );
  }
}

/// OTP input field
class OtpInputField extends StatelessWidget {
  final int length;
  final ValueChanged<String>? onCompleted;
  final FormControl<String>? formControl;

  const OtpInputField({
    super.key,
    this.length = 4,
    this.onCompleted,
    this.formControl,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        length,
        (index) => _OtpBox(
          index: index,
          formControl: formControl,
          onCompleted: onCompleted,
          length: length,
        ),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  final int index;
  final FormControl<String>? formControl;
  final ValueChanged<String>? onCompleted;
  final int length;

  const _OtpBox({
    required this.index,
    this.formControl,
    this.onCompleted,
    required this.length,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.3),
        ),
      ),
      child: Center(
        child: TextField(
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
          ),
          onChanged: (value) {
            if (value.isNotEmpty && index < length - 1) {
              FocusScope.of(context).nextFocus();
            }
            // Update form control
            final currentValue = formControl?.value ?? '';
            final chars = currentValue.padRight(length).split('');
            chars[index] = value.isEmpty ? ' ' : value;
            formControl?.value = chars.join().trim();

            if (formControl?.value?.length == length) {
              onCompleted?.call(formControl!.value!);
            }
          },
        ),
      ),
    );
  }
}
