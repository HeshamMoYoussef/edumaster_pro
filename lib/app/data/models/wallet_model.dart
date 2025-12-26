/// Wallet model
class WalletModel {
  final String id;
  final String odUserId;
  final double balance;
  final int eduCoins;
  final String currency;
  final List<TransactionModel> recentTransactions;

  const WalletModel({
    required this.id,
    required this.odUserId,
    this.balance = 0.0,
    this.eduCoins = 0,
    this.currency = 'SAR',
    this.recentTransactions = const [],
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'] as String,
      odUserId: json['user_id'] as String,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      eduCoins: json['edu_coins'] as int? ?? 0,
      currency: json['currency'] as String? ?? 'SAR',
      recentTransactions: (json['recent_transactions'] as List<dynamic>?)
              ?.map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': odUserId,
      'balance': balance,
      'edu_coins': eduCoins,
      'currency': currency,
      'recent_transactions':
          recentTransactions.map((e) => e.toJson()).toList(),
    };
  }

  /// Get formatted balance
  String get formattedBalance => '$balance ر.س';

  /// Get formatted EduCoins
  String get formattedCoins => '$eduCoins EC';
}

/// Transaction model
class TransactionModel {
  final String id;
  final String odUserId;
  final TransactionType type;
  final TransactionCategory category;
  final double? amount;
  final int? coins;
  final String currency;
  final String description;
  final TransactionStatus status;
  final String? referenceId;
  final String? referenceType;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  const TransactionModel({
    required this.id,
    String? odUserId,
    required this.type,
    required this.category,
    this.amount,
    this.coins,
    this.currency = 'SAR',
    required this.description,
    this.status = TransactionStatus.completed,
    this.referenceId,
    this.referenceType,
    required this.createdAt,
    this.metadata,
  }) : odUserId = odUserId ?? '';

  /// Alias for isCredit
  bool get isCredit => type.isCredit;

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      odUserId: json['user_id'] as String?,
      type: TransactionType.fromString(json['type'] as String),
      category: TransactionCategory.fromString(json['category'] as String),
      amount: (json['amount'] as num?)?.toDouble(),
      coins: json['coins'] as int?,
      currency: json['currency'] as String? ?? 'SAR',
      description: json['description'] as String,
      status:
          TransactionStatus.fromString(json['status'] as String? ?? 'completed'),
      referenceId: json['reference_id'] as String?,
      referenceType: json['reference_type'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': odUserId,
      'type': type.value,
      'category': category.value,
      'amount': amount,
      'coins': coins,
      'currency': currency,
      'description': description,
      'status': status.value,
      'reference_id': referenceId,
      'reference_type': referenceType,
      'created_at': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Check if transaction is income
  bool get isIncome => type == TransactionType.credit;

  /// Get formatted amount
  String get formattedAmount {
    if (amount != null) {
      final sign = isIncome ? '+' : '-';
      return '$sign${amount!.abs()} ر.س';
    }
    if (coins != null) {
      final sign = isIncome ? '+' : '-';
      return '$sign${coins!.abs()} EC';
    }
    return '';
  }
}

/// Transaction type enum
enum TransactionType {
  credit('credit'),
  debit('debit');

  final String value;
  const TransactionType(this.value);

  bool get isCredit => this == TransactionType.credit;
  bool get isDebit => this == TransactionType.debit;

  static TransactionType fromString(String value) {
    return TransactionType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TransactionType.debit,
    );
  }
}

/// Transaction category enum
enum TransactionCategory {
  coursePayment('course_payment', 'دفع كورس'),
  sessionPayment('session_payment', 'دفع جلسة'),
  deposit('deposit', 'إيداع'),
  topUp('top_up', 'شحن رصيد'),
  withdrawal('withdrawal', 'سحب'),
  refund('refund', 'استرداد'),
  reward('reward', 'مكافأة'),
  referral('referral', 'إحالة'),
  dailyLogin('daily_login', 'تسجيل دخول'),
  lessonComplete('lesson_complete', 'إكمال درس'),
  quizComplete('quiz_complete', 'إكمال اختبار'),
  courseComplete('course_complete', 'إكمال كورس'),
  achievement('achievement', 'إنجاز'),
  transfer('transfer', 'تحويل'),
  giftReceived('gift_received', 'هدية مستلمة'),
  giftSent('gift_sent', 'هدية مرسلة');

  final String value;
  final String label;
  const TransactionCategory(this.value, this.label);

  static TransactionCategory fromString(String value) {
    return TransactionCategory.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TransactionCategory.reward,
    );
  }
}

/// Transaction status enum
enum TransactionStatus {
  pending('pending', 'قيد الانتظار'),
  completed('completed', 'مكتمل'),
  failed('failed', 'فشل'),
  cancelled('cancelled', 'ملغي'),
  refunded('refunded', 'مسترد');

  final String value;
  final String label;
  const TransactionStatus(this.value, this.label);

  static TransactionStatus fromString(String value) {
    return TransactionStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TransactionStatus.completed,
    );
  }
}

/// Earning option model (for earn more coins page)
class EarningOptionModel {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int coinsReward;
  final int? pointsReward;
  final EarningType type;
  final bool isRepeatable;
  final int? dailyLimit;
  final int? currentCount;

  const EarningOptionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.coinsReward,
    this.pointsReward,
    required this.type,
    this.isRepeatable = true,
    this.dailyLimit,
    this.currentCount,
  });

  factory EarningOptionModel.fromJson(Map<String, dynamic> json) {
    return EarningOptionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      coinsReward: json['coins_reward'] as int,
      pointsReward: json['points_reward'] as int?,
      type: EarningType.fromString(json['type'] as String),
      isRepeatable: json['is_repeatable'] as bool? ?? true,
      dailyLimit: json['daily_limit'] as int?,
      currentCount: json['current_count'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'coins_reward': coinsReward,
      'points_reward': pointsReward,
      'type': type.value,
      'is_repeatable': isRepeatable,
      'daily_limit': dailyLimit,
      'current_count': currentCount,
    };
  }

  /// Check if limit reached
  bool get isLimitReached {
    if (dailyLimit == null || currentCount == null) return false;
    return currentCount! >= dailyLimit!;
  }

  /// Get remaining count
  int get remainingCount {
    if (dailyLimit == null || currentCount == null) return -1;
    return (dailyLimit! - currentCount!).clamp(0, dailyLimit!);
  }
}

/// Earning type enum
enum EarningType {
  action('action'),
  achievement('achievement'),
  referral('referral'),
  bonus('bonus');

  final String value;
  const EarningType(this.value);

  static EarningType fromString(String value) {
    return EarningType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => EarningType.action,
    );
  }
}
