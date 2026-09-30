import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'auth_service.dart';
import 'fcm_service.dart';

class RoomService {
  RoomService._();
  static final instance = RoomService._();

  final _db = FirebaseFirestore.instance;
  final _random = Random.secure();

  DocumentReference<Map<String, dynamic>> roomRef(String code) =>
      _db.collection('rooms').doc(code);

  CollectionReference<Map<String, dynamic>> members(String code) =>
      roomRef(code).collection('members');

  CollectionReference<Map<String, dynamic>> rings(String code) =>
      roomRef(code).collection('rings');

  Future<String> createRoom() async {
    final uid = AuthService.instance.uid;
    final token = await FcmService.instance.getToken() ?? '';

    for (var i = 0; i < 10; i++) {
      final code = _sixDigits();
      final ref = roomRef(code);
      try {
        await _db.runTransaction((tx) async {
          final snap = await tx.get(ref);
          if (snap.exists) {
            throw StateError('collision');
          }
          tx.set(ref, {
            'code': code,
            'hostUid': uid,
            'status': 'waiting',
            'createdAt': FieldValue.serverTimestamp(),
          });
          tx.set(members(code).doc(uid), {
            'fcmToken': token,
            'joinedAt': FieldValue.serverTimestamp(),
          });
        });
        return code;
      } on StateError {
        continue;
      }
    }
    throw Exception('No se pudo crear un código libre. Inténtalo de nuevo.');
  }

  Future<void> joinRoom(String code) async {
    final normalized = code.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(normalized)) {
      throw Exception('El código debe tener 6 dígitos.');
    }
    final uid = AuthService.instance.uid;
    final token = await FcmService.instance.getToken() ?? '';
    final ref = roomRef(normalized);
    final existing = await ref.get();
    if (!existing.exists) {
      throw Exception('Ese código no existe.');
    }

    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) {
        throw Exception('Ese código no existe.');
      }
      final data = snap.data()!;
      final status = data['status'] as String? ?? '';
      final alreadyMember = (await tx.get(members(normalized).doc(uid))).exists;
      if (status == 'paired' && !alreadyMember) {
        throw Exception('Esa campana ya está emparejada.');
      }
      if (status != 'waiting' && status != 'paired') {
        throw Exception('Esa campana no está disponible.');
      }
      tx.update(ref, {'status': 'paired'});
      tx.set(members(normalized).doc(uid), {
        'fcmToken': token,
        'joinedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> refreshToken(String code) async {
    final uid = AuthService.instance.uid;
    final token = await FcmService.instance.getToken() ?? '';
    await members(code).doc(uid).set({
      'fcmToken': token,
      'joinedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> sendRing(String code) async {
    final uid = AuthService.instance.uid;
    await rings(code).add({
      'fromUid': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> leaveRoom(String code) async {
    final uid = AuthService.instance.uid;
    final ref = roomRef(code);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) return;
      tx.set(members(code).doc(uid), {
        'leftAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      tx.update(ref, {'status': 'waiting'});
    });
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchRoom(String code) =>
      roomRef(code).snapshots();

  Stream<QuerySnapshot<Map<String, dynamic>>> watchLatestRing(String code) =>
      rings(code).orderBy('createdAt', descending: true).limit(1).snapshots();

  String _sixDigits() =>
      (_random.nextInt(900000) + 100000).toString();
}
