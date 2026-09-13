import 'package:get/get.dart';
import 'package:xyphora_frontend/statistics/data/services/statistics_service.dart';
import 'package:xyphora_frontend/statistics/data/datasources/statistics_datasource.dart';
import 'package:xyphora_frontend/statistics/data/repositories/statistics_repository.dart';
import '../controllers/statistics_controller.dart';

class StatisticsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StatisticsService>(() => StatisticsService());
    Get.lazyPut<StatisticsDatasource>(() => StatisticsDatasource(Get.find<StatisticsService>()));
    Get.lazyPut<StatisticsRepository>(() => StatisticsRepository(Get.find<StatisticsDatasource>()));
    Get.lazyPut<StatisticsController>(() => StatisticsController(Get.find<StatisticsRepository>()));
  }
}