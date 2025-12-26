import 'package:get/get.dart';

import '../../config/env_config.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/wallet_model.dart';
import '../mock/mock_data.dart';

/// Wallet repository
class WalletRepository {
  final ApiClient _api = Get.find();
  bool get _useMock => EnvConfig.useMockData;

  /// Get wallet info
  Future<WalletModel> getWallet() async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return MockData.wallet;
    }

    final response = await _api.get(ApiConstants.wallet);
    return WalletModel.fromJson(response.data);
  }

  /// Get transactions
  Future<List<TransactionModel>> getTransactions({
    TransactionType? type,
    TransactionCategory? category,
    DateTime? fromDate,
    DateTime? toDate,
    int page = 1,
    int limit = 20,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      var transactions = MockData.wallet.recentTransactions;

      // Filter by type
      if (type != null) {
        transactions = transactions.where((t) => t.type == type).toList();
      }

      // Filter by category
      if (category != null) {
        transactions =
            transactions.where((t) => t.category == category).toList();
      }

      return transactions;
    }

    final response = await _api.get(
      ApiConstants.transactions,
      queryParameters: {
        if (type != null) 'type': type.value,
        if (category != null) 'category': category.value,
        if (fromDate != null) 'from_date': fromDate.toIso8601String(),
        if (toDate != null) 'to_date': toDate.toIso8601String(),
        'page': page,
        'limit': limit,
      },
    );

    return (response.data['data'] as List)
        .map((e) => TransactionModel.fromJson(e))
        .toList();
  }

  /// Top up wallet
  Future<TransactionModel> topUp({
    required double amount,
    required String paymentMethod,
    Map<String, dynamic>? paymentDetails,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(seconds: 1));
      return TransactionModel(
        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
        type: TransactionType.credit,
        category: TransactionCategory.topUp,
        amount: amount,
        currency: 'SAR',
        description: 'شحن المحفظة',
        status: TransactionStatus.completed,
        createdAt: DateTime.now(),
      );
    }

    final response = await _api.post(
      ApiConstants.topUp,
      data: {
        'amount': amount,
        'payment_method': paymentMethod,
        'payment_details': paymentDetails,
      },
    );
    return TransactionModel.fromJson(response.data);
  }

  /// Withdraw from wallet
  Future<TransactionModel> withdraw({
    required double amount,
    required String withdrawMethod,
    required Map<String, dynamic> withdrawDetails,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(seconds: 1));
      return TransactionModel(
        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
        type: TransactionType.debit,
        category: TransactionCategory.withdrawal,
        amount: amount,
        currency: 'SAR',
        description: 'سحب من المحفظة',
        status: TransactionStatus.pending,
        createdAt: DateTime.now(),
      );
    }

    final response = await _api.post(
      ApiConstants.withdraw,
      data: {
        'amount': amount,
        'withdraw_method': withdrawMethod,
        'withdraw_details': withdrawDetails,
      },
    );
    return TransactionModel.fromJson(response.data);
  }

  /// Get earning options
  Future<List<EarningOptionModel>> getEarningOptions() async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return MockData.earningOptions;
    }

    final response = await _api.get('${ApiConstants.wallet}/earning-options');
    return (response.data['data'] as List)
        .map((e) => EarningOptionModel.fromJson(e))
        .toList();
  }

  /// Redeem EduCoins
  Future<TransactionModel> redeemCoins({
    required int coins,
    required String rewardType,
    String? rewardId,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(seconds: 1));
      return TransactionModel(
        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
        type: TransactionType.debit,
        category: TransactionCategory.reward,
        amount: coins.toDouble(),
        currency: 'COINS',
        description: 'استبدال نقاط',
        status: TransactionStatus.completed,
        createdAt: DateTime.now(),
      );
    }

    final response = await _api.post(
      '${ApiConstants.wallet}/redeem',
      data: {
        'coins': coins,
        'reward_type': rewardType,
        'reward_id': rewardId,
      },
    );
    return TransactionModel.fromJson(response.data);
  }

  /// Transfer to another user
  Future<TransactionModel> transfer({
    required String recipientId,
    required double amount,
    String? note,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(seconds: 1));
      return TransactionModel(
        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
        type: TransactionType.debit,
        category: TransactionCategory.transfer,
        amount: amount,
        currency: 'SAR',
        description: 'تحويل إلى مستخدم آخر',
        status: TransactionStatus.completed,
        createdAt: DateTime.now(),
        metadata: {'recipient_id': recipientId, 'note': note},
      );
    }

    final response = await _api.post(
      '${ApiConstants.wallet}/transfer',
      data: {
        'recipient_id': recipientId,
        'amount': amount,
        'note': note,
      },
    );
    return TransactionModel.fromJson(response.data);
  }
}
