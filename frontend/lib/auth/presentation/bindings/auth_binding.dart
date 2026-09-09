import 'package:get/get.dart';
import 'package:xyphora_frontend/auth/data/services/auth_service.dart';
import 'package:xyphora_frontend/auth/data/datasources/auth_datasource.dart';
import 'package:xyphora_frontend/auth/data/repositories/auth_repository.dart';
import '../controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthService>(() => AuthService());
    Get.lazyPut<AuthDatasource>(() => AuthDatasource(Get.find<AuthService>()));
    Get.lazyPut<AuthRepository>(() => AuthRepository(Get.find<AuthDatasource>()));
    Get.lazyPut<AuthController>(() => AuthController(Get.find<AuthRepository>()));
  }
}