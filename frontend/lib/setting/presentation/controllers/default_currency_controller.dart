import 'package:get/get.dart';
import '../../domain/models/currency_model.dart';

class DefaultCurrencyController extends GetxController {
  var selectedCode = 'VN'.obs;

  final List<CurrencyModel> currencies = [
    CurrencyModel(code: 'VN', name: 'Việt Nam Đồng', detail: 'VND · ₫'),
    CurrencyModel(code: 'US', name: 'US Dollar', detail: 'USD · \$'),
    CurrencyModel(code: 'EU', name: 'Euro', detail: 'EUR · €'),
    CurrencyModel(code: 'JP', name: 'Japanese Yen', detail: 'JPY · ¥'),
    CurrencyModel(code: 'KR', name: 'Korean Won', detail: 'KRW · ₩'),
    CurrencyModel(code: 'SG', name: 'Singapore Dollar', detail: 'SGD · S\$'),
    CurrencyModel(code: 'TH', name: 'Thai Baht', detail: 'THB · ฿'),
  ];

  void selectCurrency(String code) {
    selectedCode.value = code;
  }
}