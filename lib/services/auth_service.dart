
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  User? get user => _user;

  AuthService() {
    // 로그인 상태가 변경될 때마다 _user 업데이트
    _auth.authStateChanges().listen((User? newUser) {
      _user = newUser;
      notifyListeners();
    });
  }
  // ✅ 로그인 기능
  Future<User?> signIn(String email, String password) async {
  try {
    // 1. Firebase Auth로 로그인 시도
    UserCredential credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;

    // 2. Firestore에 해당 유저 문서가 있는지 확인
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (!userDoc.exists) {
      // Firestore에 유저 정보가 없으면 로그아웃 후 예외 던짐
      await _auth.signOut();
      throw FirebaseAuthException(
        code: 'user-not-found-in-firestore',
        message: 'Firestore에 사용자 정보가 없습니다.',
      );
    }

    // 3. 로그인 성공
    return credential.user;
  } catch (e) {
    log("로그인 오류: $e");
    rethrow; // UI에서 메시지 출력하게 위로 던져줘
  }
}
final defaultProfileImageUrl = 'https://i.pravatar.cc/150?img=3';


  // ✅ 회원가입 기능
  Future<User?> signUp(String email, String password , String username , String phone , defaultProfileImageUrl) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
        ); 
        
      await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).set({
        "username": username,
        "email" : email,
        "phone number" : phone,
        'photo' : defaultProfileImageUrl,
      });
      return credential.user;
    } catch (e) {
      log("회원가입 오류: $e");
      return null;
    }
  }

  // ✅ 로그아웃 기능
  Future<void> signOut() async {
    await _auth.signOut();
  }
}