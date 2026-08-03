import 'package:get/get.dart';
import '../../data/event_service.dart';
import '../../data/datasources/event_datasource.dart';
import '../../data/repositories/event_repository.dart';
import '../controllers/event_controller.dart';

class EventBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EventService>(() => EventService());
    Get.lazyPut<EventDatasource>(() => EventDatasource(Get.find<EventService>()));
    Get.lazyPut<EventRepository>(() => EventRepository(Get.find<EventDatasource>()));
    Get.lazyPut<EventController>(() => EventController(Get.find<EventRepository>()));
  }
}
