import 'package:get/get.dart';
import '../../../global/controllers/app_controller.dart';
import '../../../data/models/user_model.dart';

class ProfileController extends GetxController {
  final AppController _appController = Get.find();

  UserModel? get user => _appController.currentUser;
}
