import 'package:shared_preferences/shared_preferences.dart';

class SessionStore {
  static const _roomKey = 'paired_room_code';

  Future<String?> readRoom() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roomKey);
  }

  Future<void> saveRoom(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roomKey, code);
  }

  Future<void> clearRoom() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_roomKey);
  }
}
