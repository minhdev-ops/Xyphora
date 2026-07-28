class ProfileModel {
  final String name;
  final String email;
  final String? avatarUrl;

  ProfileModel({
    required this.name,
    required this.email,
    this.avatarUrl,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatar_url'],
    );
  }
}
