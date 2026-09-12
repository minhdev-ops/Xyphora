import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:device_preview/device_preview.dart';
import 'package:xyphora_frontend/add_expense/presentation/controllers/add_expense_controller.dart';
import 'package:xyphora_frontend/add_expense/presentation/bindings/add_expense_binding.dart';
import 'package:xyphora_frontend/add_group_expense/presentation/controllers/add_group_expense_controller.dart';
import 'package:xyphora_frontend/add_group_expense/presentation/bindings/add_group_expense_binding.dart';
import 'package:xyphora_frontend/statistics/presentation/controllers/statistics_controller.dart';
import 'package:xyphora_frontend/statistics/presentation/bindings/statistics_binding.dart';
import 'package:xyphora_frontend/expense_history/presentation/bindings/expense_history_binding.dart';
import 'package:xyphora_frontend/category_list/presentation/bindings/category_list_binding.dart';
import 'package:xyphora_frontend/expense_detail/presentation/bindings/expense_detail_binding.dart';
import 'package:xyphora_frontend/auth/presentation/bindings/auth_binding.dart';
import 'package:xyphora_frontend/auth/presentation/pages/login_pages.dart';
import 'package:xyphora_frontend/core/deep_link_service.dart';
import 'package:xyphora_frontend/home_dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:xyphora_frontend/profile/presentation/controllers/profile_controller.dart';
import 'package:xyphora_frontend/notification/presentation/controllers/notification_controller.dart';
import 'package:xyphora_frontend/injector.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();

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
      enabled: true, // sửa thành false nếu muốn chạy máy ảo
      builder: (context) => const MyApp(),
    ),
  );

  DeepLinkService.init();
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
        AuthBinding().dependencies();
        AddExpenseBinding().dependencies();
        AddGroupExpenseBinding().dependencies();
        StatisticsBinding().dependencies();
        ExpenseHistoryBinding().dependencies();
        CategoryListBinding().dependencies();
        Get.lazyPut<DashboardController>(
          () => DashboardController(),
          fenix: true,
        );
        Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
        Get.lazyPut<NotificationController>(
          () => NotificationController(),
          fenix: true,
        );
      }),
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFE4F5E5),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0C3D2B)),
        useMaterial3: true,
      ),
      home: const LoginPages(),
    );
  }
}