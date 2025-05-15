import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});
  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  String username = ""; 
  String photoUrl = "https://i.pravatar.cc/150?img=3";// 기본값
  final user = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    super.initState();
    fetchUsername(); // Firestore에서 사용자 이름 불러오기
  }
  Future<void> fetchUsername() async {
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          username = userDoc['username'] ?? '이름 없음';
          photoUrl = userDoc['photo'] ?? 'https://i.pravatar.cc/150?img=3';  // 기본 이미지 설정

        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('친구 추가'),
            backgroundColor: Colors.white
        ),
    );
  }
}