import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/event.dart';

class FirestoreService {


  // 일정 저장
  Future<void> addSchedule(Schedule schedule) async {
    final user = FirebaseAuth.instance.currentUser;
    if(user == null) return;
    await FirebaseFirestore.instance.collection('schedules').add(schedule.toMap());
  }

  // 일정 불러오기
  Future<List<Schedule>> fetchSchedules() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];
    final snapshot = await FirebaseFirestore.instance.collection('schedules').where('uid', isEqualTo: uid).get();
    return snapshot.docs.map((doc) => Schedule.fromMap(doc.id, doc.data())).toList();
  }
}
