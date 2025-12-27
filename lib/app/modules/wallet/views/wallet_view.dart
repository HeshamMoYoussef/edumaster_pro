import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/color_constants.dart';
import '../../../global/widgets/loading_widget.dart';
import '../controllers/wallet_controller.dart';

class WalletView extends GetView<WalletController> {
  const WalletView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('wallet'.tr), centerTitle: true),
      body: Obx(() {
        if (controller.isLoading || controller.wallet == null) {
          return const LoadingWidget();
        }
        final wallet = controller.wallet!;
        return ListView(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          children: [
            // Balance card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text('balance'.tr, style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  Text('${wallet.balance.toInt()} ${'sar'.tr}', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🪙 ', style: TextStyle(fontSize: 24)),
                      Text('${wallet.eduCoins} ${'edu_coins'.tr}', style: const TextStyle(color: Colors.white, fontSize: 18)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                Expanded(child: _ActionButton(icon: Icons.add, label: 'top_up'.tr, onTap: () {})),
                const SizedBox(width: 16),
                Expanded(child: _ActionButton(icon: Icons.arrow_upward, label: 'withdraw'.tr, onTap: () {})),
                const SizedBox(width: 16),
                Expanded(child: _ActionButton(icon: Icons.history, label: 'transactions'.tr, onTap: () {})),
              ],
            ),
            const SizedBox(height: 24),

            // Recent transactions
            Text('transactions'.tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...wallet.recentTransactions.take(5).map((tx) => ListTile(
              leading: CircleAvatar(
                backgroundColor: tx.type.isCredit ? AppColors.success.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1),
                child: Icon(tx.type.isCredit ? Icons.arrow_downward : Icons.arrow_upward, color: tx.type.isCredit ? AppColors.success : AppColors.error),
              ),
              title: Text(tx.description),
              subtitle: Text(tx.category.label),
              trailing: Text(
                '${tx.type.isCredit ? '+' : '-'}${tx.amount?.toInt() ?? 0} ${tx.currency}',
                style: TextStyle(color: tx.type.isCredit ? AppColors.success : AppColors.error, fontWeight: FontWeight.bold),
              ),
            )),
          ],
        );
      }),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
