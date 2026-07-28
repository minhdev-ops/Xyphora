import 'package:get/get.dart';
import '../../data/profile_service.dart';
import '../../domain/models/profile_model.dart';

class ProfileController extends GetxController {
  final ProfileService _profileService = ProfileService();

  var isLoading = true.obs;
  var profile = Rxn<ProfileModel>();

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  void fetchProfile() async {
    isLoading.value = true;
    final result = await _profileService.getProfile();
    if (result['success']) {
      profile.value = ProfileModel.fromJson(result['data']);
    }
    isLoading.value = false;
  }
}
