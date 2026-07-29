import 'package:get/get.dart';
import '../../data/profile_service.dart';
import '../../domain/models/profile_model.dart';

class ProfileController extends GetxController {
  final ProfileService _profileService = ProfileService();

  var isLoading = true.obs;
  var profile = Rxn<ProfileModel>();

  // Settings states
  var isDarkMode = false.obs;
  var selectedColor = 0.obs;
  var isMascotExpanded = true.obs;
  var selectedMascot = 1.obs;

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
    } else {
      profile.value = ProfileModel(
        name: 'Nguyễn Văn Minh',
        email: 'minh.nguyen@xyphora.com',
        avatarUrl: null,
      );
    }
    isLoading.value = false;
  }
}
