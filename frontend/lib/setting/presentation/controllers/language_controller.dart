import 'package:get/get.dart';
import '../../domain/models/language_model.dart';

class LanguageController extends GetxController {
  var selectedCode = 'VN'.obs;

  final List<LanguageModel> languages = [
    LanguageModel(code: 'VN', name: 'Tiếng Việt', nativeName: 'Tiếng Việt', flag: '🇻🇳'),
    LanguageModel(code: 'EN', name: 'English', nativeName: 'English (US)', flag: '🇺🇸'),
    LanguageModel(code: 'JP', name: '日本語', nativeName: '日本語', flag: '🇯🇵'),
    LanguageModel(code: 'KR', name: '한국어', nativeName: '한국어', flag: '🇰🇷'),
    LanguageModel(code: 'CN', name: '中文', nativeName: '中文', flag: '🇨🇳'),
    LanguageModel(code: 'TH', name: 'ภาษาไทย', nativeName: 'ภาษาไทย', flag: '🇹🇭'),

  ];

  void selectLanguage(String code) {
    selectedCode.value = code;
  }
}