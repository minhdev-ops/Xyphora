import 'package:get/get.dart';
import 'package:xyphora_frontend/auth/data/repositories/auth_repository.dart';
import 'package:xyphora_frontend/auth/data/datasources/auth_datasource.dart';
import 'package:xyphora_frontend/event_management/data/services/event_service.dart';
import 'package:xyphora_frontend/event_management/data/datasources/event_datasource.dart';
import 'package:xyphora_frontend/event_management/data/repositories/event_repository.dart';
import 'package:xyphora_frontend/event_management/presentation/controllers/event_controller.dart';

class EventBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EventService>(() => EventService());
    Get.lazyPut<EventDatasource>(() => EventDatasource(Get.find<EventService>()));
    Get.lazyPut<EventRepository>(() => EventRepository(Get.find<EventDatasource>()));
    Get.lazyPut<AuthRepository>(() => AuthRepository(Get.find<AuthDatasource>()));
    Get.lazyPut<EventController>(() => EventController(Get.find<EventRepository>(), Get.find<AuthRepository>()));
  }
}