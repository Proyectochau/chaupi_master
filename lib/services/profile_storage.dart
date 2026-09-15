import 'package:shared_preferences/shared_preferences.dart';

class ProfileStorage {
  static const profileKey = 'chaupi_master_profile_id';

  Future<String?> loadProfileId() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(profileKey);
  }

  Future<void> saveProfileId(String profileId) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(profileKey, profileId);
  }
}
