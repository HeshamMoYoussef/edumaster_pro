import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/phone_number.dart';

/// حقل هاتف ذكي يكتشف الدولة تلقائياً من إعدادات الجهاز
/// مصمم ليتوافق مع تنسيق CustomTextField
/// العلم وكود الدولة على اليمين في الواجهة العربية RTL
class SmartPhoneField extends StatefulWidget {
  final TextEditingController? controller;
  final void Function(PhoneNumber)? onChanged;
  final void Function(PhoneNumber?)? onSaved;
  final String? Function(PhoneNumber?)? validator;
  final String? label;
  final String? hint;
  final bool enabled;
  final FocusNode? focusNode;
  final void Function(String)? onSubmitted;
  final void Function(Country)? onCountryChanged;
  final TextInputAction? textInputAction;
  final String? initialCountryCode;

  const SmartPhoneField({
    super.key,
    this.controller,
    this.onChanged,
    this.onSaved,
    this.validator,
    this.label,
    this.hint,
    this.enabled = true,
    this.focusNode,
    this.onSubmitted,
    this.onCountryChanged,
    this.textInputAction,
    this.initialCountryCode,
  });

  @override
  State<SmartPhoneField> createState() => _SmartPhoneFieldState();
}

class _SmartPhoneFieldState extends State<SmartPhoneField> {
  late Country _selectedCountry;
  late TextEditingController _phoneController;
  String? _errorText;
  bool _isInitialized = false;
  int _phoneLength = 0;

  @override
  void initState() {
    super.initState();
    _phoneController = widget.controller ?? TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final countryCode = _getInitialCountryCode();
      _selectedCountry = countries.firstWhere(
        (c) => c.code == countryCode,
        orElse: () => countries.firstWhere((c) => c.code == 'EG'),
      );
      _isInitialized = true;
      debugPrint('📍 [SmartPhoneField] Initialized with country: ${_selectedCountry.name} (${_selectedCountry.code})');
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _phoneController.dispose();
    }
    super.dispose();
  }

  /// تحديد كود الدولة من locale الجهاز الفعلي
  String _getInitialCountryCode() {
    if (widget.initialCountryCode != null && widget.initialCountryCode!.isNotEmpty) {
      return widget.initialCountryCode!;
    }

    // الحصول على locale من الجهاز
    final primaryLocale = ui.PlatformDispatcher.instance.locale;
    String? countryCode = primaryLocale.countryCode?.toUpperCase();

    debugPrint('📍 [SmartPhoneField] Device locale: $primaryLocale');
    debugPrint('📍 [SmartPhoneField] Country code from device: $countryCode');

    // التحقق من صلاحية كود الدولة
    if (countryCode != null && countryCode.length == 2) {
      if (countries.any((c) => c.code == countryCode)) {
        return countryCode;
      }
    }

    // محاولة من Intl
    final systemLocale = Intl.systemLocale;
    debugPrint('📍 [SmartPhoneField] System locale: $systemLocale');

    if (systemLocale.contains('_')) {
      countryCode = systemLocale.split('_').last.toUpperCase();
    } else if (systemLocale.contains('-')) {
      countryCode = systemLocale.split('-').last.toUpperCase();
    }

    if (countryCode != null && countryCode.length == 2) {
      if (countries.any((c) => c.code == countryCode)) {
        return countryCode;
      }
    }

    // تحويل أكواد اللغات إلى أكواد دول
    return _mapLanguageToCountry(primaryLocale.languageCode);
  }

  String _mapLanguageToCountry(String langCode) {
    final map = {
      'ar': 'EG', 'en': 'US', 'fr': 'FR', 'de': 'DE',
      'es': 'ES', 'it': 'IT', 'tr': 'TR', 'ru': 'RU',
      'zh': 'CN', 'ja': 'JP', 'ko': 'KR', 'hi': 'IN',
      'ur': 'PK', 'fa': 'IR', 'pt': 'PT',
    };
    return map[langCode.toLowerCase()] ?? 'EG';
  }

  /// الحصول على طول رقم الهاتف المطلوب لكل دولة
  int _getPhoneLengthForCountry(String countryCode) {
    // أطوال أرقام الهواتف حسب الدولة (بدون كود الدولة)
    const phoneLengths = {
      // الدول العربية
      'EG': 10, // مصر: 10 أرقام (مثال: 1012345678)
      'SA': 9,  // السعودية: 9 أرقام (مثال: 512345678)
      'AE': 9,  // الإمارات: 9 أرقام
      'KW': 8,  // الكويت: 8 أرقام
      'BH': 8,  // البحرين: 8 أرقام
      'QA': 8,  // قطر: 8 أرقام
      'OM': 8,  // عمان: 8 أرقام
      'JO': 9,  // الأردن: 9 أرقام
      'LB': 8,  // لبنان: 8 أرقام
      'SY': 9,  // سوريا: 9 أرقام
      'IQ': 10, // العراق: 10 أرقام
      'YE': 9,  // اليمن: 9 أرقام
      'PS': 9,  // فلسطين: 9 أرقام
      'SD': 9,  // السودان: 9 أرقام
      'LY': 9,  // ليبيا: 9 أرقام
      'TN': 8,  // تونس: 8 أرقام
      'DZ': 9,  // الجزائر: 9 أرقام
      'MA': 9,  // المغرب: 9 أرقام
      'MR': 8,  // موريتانيا: 8 أرقام
      'SO': 8,  // الصومال: 8 أرقام
      'DJ': 8,  // جيبوتي: 8 أرقام
      'KM': 7,  // جزر القمر: 7 أرقام
      // دول أخرى شائعة
      'US': 10, // أمريكا: 10 أرقام
      'GB': 10, // بريطانيا: 10 أرقام
      'FR': 9,  // فرنسا: 9 أرقام
      'DE': 11, // ألمانيا: 10-11 أرقام
      'TR': 10, // تركيا: 10 أرقام
      'IN': 10, // الهند: 10 أرقام
      'PK': 10, // باكستان: 10 أرقام
      'IR': 10, // إيران: 10 أرقام
      'CN': 11, // الصين: 11 رقم
      'JP': 10, // اليابان: 10 أرقام
      'KR': 10, // كوريا: 10 أرقام
      'RU': 10, // روسيا: 10 أرقام
      'IT': 10, // إيطاليا: 10 أرقام
      'ES': 9,  // إسبانيا: 9 أرقام
      'PT': 9,  // البرتغال: 9 أرقام
      'NL': 9,  // هولندا: 9 أرقام
      'BE': 9,  // بلجيكا: 9 أرقام
      'CH': 9,  // سويسرا: 9 أرقام
      'AT': 10, // النمسا: 10 أرقام
      'AU': 9,  // أستراليا: 9 أرقام
      'NZ': 9,  // نيوزيلندا: 9 أرقام
      'CA': 10, // كندا: 10 أرقام
      'MX': 10, // المكسيك: 10 أرقام
      'BR': 11, // البرازيل: 11 رقم
      'ID': 11, // إندونيسيا: 10-11 أرقام
      'MY': 10, // ماليزيا: 9-10 أرقام
      'SG': 8,  // سنغافورة: 8 أرقام
      'TH': 9,  // تايلاند: 9 أرقام
      'VN': 9,  // فيتنام: 9 أرقام
      'PH': 10, // الفلبين: 10 أرقام
      'BD': 10, // بنغلاديش: 10 أرقام
      'NG': 10, // نيجيريا: 10 أرقام
      'KE': 9,  // كينيا: 9 أرقام
      'ZA': 9,  // جنوب أفريقيا: 9 أرقام
    };
    return phoneLengths[countryCode] ?? 10; // الافتراضي 10 أرقام
  }

  void _showCountryPicker() {
    final isArabic = Intl.getCurrentLocale().startsWith('ar');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => _CountryPickerSheet(
          countries: countries,
          selectedCountry: _selectedCountry,
          isArabic: isArabic,
          scrollController: scrollController,
          onCountrySelected: (country) {
            final oldCountry = _selectedCountry;
            setState(() {
              _selectedCountry = country;
              // إذا تغيرت الدولة وطول الرقم مختلف، نمسح الحقل
              if (oldCountry.code != country.code) {
                final newLength = _getPhoneLengthForCountry(country.code);
                if (_phoneController.text.length > newLength) {
                  _phoneController.clear();
                  _phoneLength = 0;
                }
              }
            });
            widget.onCountryChanged?.call(country);
            _notifyPhoneChange();
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _notifyPhoneChange() {
    if (widget.onChanged != null) {
      final phone = PhoneNumber(
        countryISOCode: _selectedCountry.code,
        countryCode: '+${_selectedCountry.dialCode}',
        number: _phoneController.text,
      );
      widget.onChanged!(phone);
    }
  }

  String? _validatePhone(String? value) {
    if (widget.validator != null) {
      final phone = PhoneNumber(
        countryISOCode: _selectedCountry.code,
        countryCode: '+${_selectedCountry.dialCode}',
        number: value ?? '',
      );
      return widget.validator!(phone);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Directionality.of(context) == ui.TextDirection.rtl;
    final requiredLength = _getPhoneLengthForCountry(_selectedCountry.code);
    final isComplete = _phoneLength == requiredLength;
    final isOverLimit = _phoneLength > requiredLength;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // العنوان فوق الحقل (مثل CustomTextField)
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
        ],

        // حقل الهاتف المخصص
        TextFormField(
          controller: _phoneController,
          focusNode: widget.focusNode,
          enabled: widget.enabled,
          keyboardType: TextInputType.phone,
          textInputAction: widget.textInputAction ?? TextInputAction.next,
          textDirection: ui.TextDirection.ltr,
          textAlign: isArabic ? TextAlign.right : TextAlign.left,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            // تحديد الحد الأقصى حسب الدولة المختارة
            LengthLimitingTextInputFormatter(requiredLength),
          ],
          decoration: InputDecoration(
            hintText: widget.hint ?? (isArabic ? 'أدخل رقم هاتفك' : 'Enter phone number'),
            hintTextDirection: ui.TextDirection.ltr,
            errorText: _errorText,
            // عداد الأرقام المدخلة حسب الدولة
            counterText: '$_phoneLength/$requiredLength',
            counterStyle: TextStyle(
              fontSize: 12,
              fontWeight: isComplete ? FontWeight.bold : FontWeight.normal,
              color: isComplete
                  ? Colors.green
                  : isOverLimit
                      ? theme.colorScheme.error
                      : theme.hintColor,
            ),
            // زر اختيار الدولة
            prefixIcon: _buildCountryButton(theme),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          ),
          onChanged: (value) {
            _notifyPhoneChange();
            setState(() {
              _phoneLength = value.length;
              _errorText = _validatePhone(value);
            });
          },
          onFieldSubmitted: widget.onSubmitted,
          validator: _validatePhone,
        ),
      ],
    );
  }

  Widget _buildCountryButton(ThemeData theme) {
    return InkWell(
      onTap: widget.enabled ? _showCountryPicker : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // علم الدولة
            Text(
              _selectedCountry.flag,
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(width: 6),
            // كود الدولة
            Text(
              '+${_selectedCountry.dialCode}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(width: 2),
            // سهم القائمة
            Icon(
              Icons.arrow_drop_down,
              size: 20,
              color: theme.hintColor,
            ),
            // فاصل
            Container(
              height: 24,
              width: 1,
              margin: const EdgeInsets.only(left: 8),
              color: theme.dividerColor,
            ),
          ],
        ),
      ),
    );
  }
}

/// شاشة اختيار الدولة
class _CountryPickerSheet extends StatefulWidget {
  final List<Country> countries;
  final Country selectedCountry;
  final bool isArabic;
  final ScrollController scrollController;
  final void Function(Country) onCountrySelected;

  const _CountryPickerSheet({
    required this.countries,
    required this.selectedCountry,
    required this.isArabic,
    required this.scrollController,
    required this.onCountrySelected,
  });

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  late List<Country> _filteredCountries;
  final _searchController = TextEditingController();

  // الدول العربية للأولوية
  static const arabCountries = [
    'EG', 'SA', 'AE', 'KW', 'BH', 'QA', 'OM', 'JO', 'LB', 'SY',
    'IQ', 'YE', 'PS', 'SD', 'LY', 'TN', 'DZ', 'MA', 'MR', 'SO', 'DJ', 'KM'
  ];

  @override
  void initState() {
    super.initState();
    _sortCountries();
  }

  void _sortCountries() {
    // ترتيب الدول: العربية أولاً ثم الباقي أبجدياً
    final arabList = widget.countries
        .where((c) => arabCountries.contains(c.code))
        .toList()
      ..sort((a, b) => arabCountries.indexOf(a.code).compareTo(arabCountries.indexOf(b.code)));

    final otherList = widget.countries
        .where((c) => !arabCountries.contains(c.code))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    _filteredCountries = [...arabList, ...otherList];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCountries(String query) {
    setState(() {
      if (query.isEmpty) {
        _sortCountries();
      } else {
        final q = query.toLowerCase();
        _filteredCountries = widget.countries.where((country) {
          return country.name.toLowerCase().contains(q) ||
              country.code.toLowerCase().contains(q) ||
              country.dialCode.contains(q);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // المقبض
        Container(
          margin: const EdgeInsets.only(top: 12),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[400],
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        // العنوان
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            widget.isArabic ? 'اختر الدولة' : 'Select Country',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // حقل البحث
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: widget.isArabic ? 'ابحث عن دولة...' : 'Search country...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              isDense: true,
            ),
            onChanged: _filterCountries,
          ),
        ),

        const SizedBox(height: 12),

        // قائمة الدول
        Expanded(
          child: ListView.separated(
            controller: widget.scrollController,
            itemCount: _filteredCountries.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.3)),
            itemBuilder: (context, index) {
              final country = _filteredCountries[index];
              final isSelected = country.code == widget.selectedCountry.code;
              final isArab = arabCountries.contains(country.code);

              return ListTile(
                dense: true,
                leading: Text(
                  country.flag,
                  style: const TextStyle(fontSize: 26),
                ),
                title: Text(
                  country.name,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isArab ? theme.primaryColor : null,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '+${country.dialCode}',
                      style: TextStyle(
                        color: theme.hintColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.check_circle, color: theme.primaryColor, size: 20),
                    ],
                  ],
                ),
                selected: isSelected,
                selectedTileColor: theme.primaryColor.withValues(alpha: 0.08),
                onTap: () => widget.onCountrySelected(country),
              );
            },
          ),
        ),
      ],
    );
  }
}
