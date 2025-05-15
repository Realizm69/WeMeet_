import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  // 🔍 username 으로 친구 요청 보내기 (통합 버전)
  static Future<void> sendFriendRequestByUsername(String username) async {
    final toUid = await _getUidByUsername(username);
    if (toUid == null) throw Exception("해당 유저를 찾을 수 없습니다.");
    await _sendFriendRequest(toUid);
  }

  // ✉️ 친구 요청 전송 (내 정보 포함해서)
  static Future<void> _sendFriendRequest(String toUid) async {
    final fromUser = _auth.currentUser!;
    final fromDoc = await _firestore.collection('users').doc(fromUser.uid).get();

    await _firestore
        .collection('users')
        .doc(toUid)
        .collection('friendRequests')
        .doc(fromUser.uid)
        .set({
      'fromUid': fromUser.uid,
      'fromUsername': fromDoc['username'],
      'fromPhoto': fromDoc['photo'],
      'status': 'pending',
    });
  }

  // 🧭 username → uid 변환 (소문자 기준)
  static Future<String?> _getUidByUsername(String username) async {
    final normalized = username.trim();
    final snapshot = await _firestore
        .collection('users')
        .where('username', isEqualTo: normalized)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return snapshot.docs.first.id;
  }

  // ✅ 친구 요청 수락
  static Future<void> acceptFriendRequest(String fromUid) async {
    final currentUid = _auth.currentUser!.uid;
    final fromDoc = await _firestore.collection('users').doc(fromUid).get();
    final toDoc = await _firestore.collection('users').doc(currentUid).get();

    // 상대방의 friends 컬렉션에 나 추가
    await _firestore.collection('users').doc(currentUid).collection('friends').doc(fromUid).set({
      'username': fromDoc['username'],
      'photo': fromDoc['photo']
    });

    // 나의 friends 컬렉션에 상대방 추가
    await _firestore.collection('users').doc(fromUid).collection('friends').doc(currentUid).set({
      'username': toDoc['username'],
      'photo': toDoc['photo']
    });

    // 요청 상태 업데이트
    await _firestore
        .collection('users')
        .doc(currentUid)
        .collection('friendRequests')
        .doc(fromUid)
        .update({'status': 'accepted'});
  }

  // ❌ 친구 요청 거절
  static Future<void> rejectFriendRequest(String fromUid) async {
    final currentUid = _auth.currentUser!.uid;
    await _firestore
        .collection('users')
        .doc(currentUid)
        .collection('friendRequests')
        .doc(fromUid)
        .update({'status': 'rejected'});
  }

  // 👥 친구 목록 불러오기
  static Stream<List<Map<String, dynamic>>> getFriends() {
    final uid = _auth.currentUser!.uid;
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('friends')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => doc.data()).toList());
  }
}
