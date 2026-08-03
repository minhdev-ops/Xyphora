import 'package:get/get.dart';
import '../../domain/models/language_model.dart';

class LanguageController extends GetxController {
  var selectedCode = 'VN'.obs;

  final List<LanguageModel> languages = [
    LanguageModel(code: 'VN', name: 'Tiếng Việt'),
    LanguageModel(code: 'GB', name: 'English'),
    LanguageModel(code: 'JP', name: '日本語'),
    LanguageModel(code: 'KR', name: '한국어'),
    LanguageModel(code: 'CN', name: '中文'),
    LanguageModel(code: 'TH', name: 'ภาษาไทย'),
  ];

  void selectLanguage(String code) {
    selectedCode.value = code;
  }
}