// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/gestures.dart';
import 'package:xyphora_frontend/add_expense/presentation/controllers/add_expense_controller.dart';
import 'package:xyphora_frontend/home_dashboard/presentation/pages/home_dashboard_page.dart';
import 'package:xyphora_frontend/add_expense/presentation/pages/add_expense_page.dart';
import 'package:xyphora_frontend/add_group_expense/presentation/controllers/add_group_expense_controller.dart';
import 'package:xyphora_frontend/add_group_expense/presentation/pages/add_group_expense_page.dart';
import 'package:xyphora_frontend/statistics/presentation/controllers/statistics_controller.dart';
import 'package:xyphora_frontend/statistics/presentation/pages/statistics_page.dart';
import 'auth/presentation/pages/home_page.dart';
import 'auth/presentation/controllers/auth_controller.dart';
import 'event_management/presentation/pages/event_page.dart';
import 'home_dashboard/presentation/controllers/dashboard_controller.dart';
import 'profile/presentation/controllers/profile_controller.dart';
import 'notification/presentation/controllers/notification_controller.dart';
import 'setting/presentation/bindings/settings_binding.dart';

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
  // Chạy có DevicePreview (dùng cho web/desktop):
  // runApp(kIsWeb ? DevicePreview(builder: (context) => const MyApp()) : const MyApp());
  // Chạy trực tiếp (Android/iOS/desktop):
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Xyphora',
      debugShowCheckedModeBanner: false,
      // locale: DevicePreview.locale(context),
      // builder: DevicePreview.appBuilder,
      initialBinding: BindingsBuilder(() {
        Get.put<AuthController>(AuthController(), permanent: true);
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
        Get.put<AuthController>(AuthController(), permanent: true);
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
      home: ExpensePage(),
    );
  }
}
*/