import 'package:get/get.dart';
import '../../../data/models/wallet_model.dart';
import '../../../data/repositories/wallet_repository.dart';

class WalletController extends GetxController {
  final WalletRepository _walletRepo = Get.find();

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final _wallet = Rxn<WalletModel>();
  WalletModel? get wallet => _wallet.value;

  @override
  void onInit() {
    super.onInit();
    loadWallet();
  }

  Future<void> loadWallet() async {
    _isLoading.value = true;
    try {
      _wallet.value = await _walletRepo.getWallet();
    } finally {
      _isLoading.value = false;
    }
  }
}
