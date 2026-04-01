class AuthModel {
  final String id;
  final String username;
  final String profileImage;
  // Password tidak perlu disimpan permanen di model setelah login

  AuthModel({
    required this.id,
    required this.username,
    required this.profileImage,
  });

  // ✨ Ubah JSON dari Backend (Node.js) menjadi Objek AuthModel
  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      // Di database kamu namanya profile_image, di model profileImage
      profileImage: json['profile_image'] ?? 
          'https://xyfdsaighjmiiketlhep.supabase.co/storage/v1/object/public/profile/default_profile.png',
    );
  }

  // ✨ Untuk keperluan simpan ke SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'profile_image': profileImage,
    };
  }
}