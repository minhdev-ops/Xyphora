import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/gestures.dart';
import 'package:xyphora_frontend/add_expense/presentaition/controllers/add_expense_controller.dart';
import 'package:xyphora_frontend/home_dashboard/presentation/pages/home_dashboard_page.dart';
import 'package:xyphora_frontend/add_expense/presentaition/pages/add_expense_page.dart';
import 'package:xyphora_frontend/add_group_expense/presentaition/controllers/add_group_expense_controller.dart';
import 'package:xyphora_frontend/add_group_expense/presentaition/pages/add_group_expense_page.dart';
import 'package:xyphora_frontend/statistics/presentaition/controllers/statistics_controller.dart';
import 'package:xyphora_frontend/statistics/presentaition/pages/statistics_page.dart';
import 'auth/presentation/pages/home_page.dart';
import 'auth/presentation/controllers/auth_controller.dart';
import 'event_management/presentation/pages/event_page.dart';
import 'home_dashboard/presentation/controllers/dashboard_controller.dart';
import 'profile/presentation/controllers/profile_controller.dart';
import 'notification/presentation/controllers/notification_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exceptionAsString()}');
  };

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFFE4F5E5),
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(
    DevicePreview(
      enabled: true, // Chuyển thành false khi muốn chạy trên máy ảo điện thoại hoặc thiết bị thật
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Xyphora',
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      initialBinding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
        Get.lazyPut<DashboardController>(() => DashboardController(), fenix: true);
        Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
        Get.lazyPut<NotificationController>(() => NotificationController(), fenix: true);
        Get.lazyPut<AddExpenseController>(() => AddExpenseController(), fenix: true);
        Get.lazyPut<AddGroupExpenseController>(() => AddGroupExpenseController(), fenix: true);
        Get.lazyPut<StatisticsController>(() => StatisticsController(), fenix: true);

      }),
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFE4F5E5),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0C3D2B)),
        useMaterial3: true,
      ),
      home: const HomeDashboardPage(),
    );
  }
}

// Nếu chạy trực tiếp ứng dụng lên máy ảo Android/iOS hoặc điện thoại thật mà không thông qua khung DevicePreview,
// hãy comment toàn bộ nội dung file bên trên (hoặc xóa đi) và mở comment khối code dưới đây:
/*
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exceptionAsString()}');
  };

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const MyAppPhone());
}

class MyAppPhone extends StatelessWidget {
  const MyAppPhone({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Xyphora',
      debugShowCheckedModeBanner: false,
      initialBinding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
        Get.lazyPut<DashboardController>(
          () => DashboardController(),
          fenix: true,
        );
        Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
        Get.lazyPut<NotificationController>(
          () => NotificationController(),
          fenix: true,
        );
        Get.lazyPut<AddExpenseController>(
          () => AddExpenseController(),
          fenix: true,
        );
        Get.lazyPut<AddGroupExpenseController>(
          () => AddGroupExpenseController(),
          fenix: true,
        );
        Get.lazyPut<StatisticsController>(
          () => StatisticsController(),
          fenix: true,
        );
      }),
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFE4F5E5),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0C3D2B)),
        useMaterial3: true,
      ),
      scrollBehavior: MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.stylus,
          PointerDeviceKind.trackpad,
        },
      ),
      home: const ExpensePage(),
    );
  }
}
*/