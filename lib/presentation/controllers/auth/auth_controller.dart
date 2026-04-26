import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../../data/models/user/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../routes/app_routes.dart';
import '../nav_controller.dart';

class AuthController extends GetxController {
  final AuthRepository _repository;

  AuthController(this._repository);

  String? accessToken;
  String? role;
  UserModel? userModel;

  @override
  void onInit() {
    super.onInit();

    loadUserData();
  }

  Future<void> saveUserData({
    required UserModel model,
    required String token,
  }) async {
    await _repository.saveUserData(model: model, token: token);
    accessToken = token;
    userModel = model;
    role = model.role;
  }

  Future<void> loadUserData() async {
    final data = await _repository.loadUserData();
    accessToken = data.token;
    userModel = data.user;
    role = data.role;
  }

  Future<void> updateUser(UserModel updatedUser) async {
    await _repository.updateUser(updatedUser);
    userModel = updatedUser;
  }

  Future<void> logout() async {
    await _repository.clearUserData();

    accessToken = null;
    userModel = null;
    role = null;

    Get.find<NavController>().changeIndex(0);

    Get.offAllNamed(AppRoutes.login);
  }

  bool get isLoggedIn => accessToken != null;
}