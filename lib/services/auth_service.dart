import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService._();
  static final instance = AuthService._();

  final _auth = FirebaseAuth.instance;

  String get uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('No hay sesión anónima.');
    }
    return user.uid;
  }

  Future<User> ensureSignedIn() async {
    final existing = _auth.currentUser;
    if (existing != null) return existing;
    final cred = await _auth.signInAnonymously();
    return cred.user!;
  }
}
