import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../controllers/account_security_controller.dart';
import '../controllers/push_notification_controller.dart';
import '../controllers/default_currency_controller.dart';
import '../controllers/language_controller.dart';
import '../controllers/support_feedback_controller.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingsController>(() => SettingsController(), fenix: true);
    Get.lazyPut<AccountSecurityController>(() => AccountSecurityController(), fenix: true);
    Get.lazyPut<PushNotificationController>(() => PushNotificationController(), fenix: true);
    Get.lazyPut<DefaultCurrencyController>(() => DefaultCurrencyController(), fenix: true);
    Get.lazyPut<LanguageController>(() => LanguageController(), fenix: true);
    Get.lazyPut<SupportFeedbackController>(() => SupportFeedbackController(), fenix: true);
  }
}