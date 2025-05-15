import "package:flutter/material.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:provider/provider.dart";
import "package:wemeet/screens/auth/login_screen.dart";
import "package:wemeet/services/auth_service.dart";

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}
class _ProfileState extends State<Profile> {
  String photoUrl = "https://i.pravatar.cc/150?img=3";
  String username = ""; // 기본값
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
    final authService = context.read<AuthService>();
    return Scaffold(
      appBar: AppBar(
        title: Text("My Page"),
        titleTextStyle: TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold , color: Colors.black
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      ),
      body: SafeArea (
        child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height:20),
          Row(
              children: [
                CircleAvatar(
                    radius: 48,
                    backgroundImage: NetworkImage(photoUrl),
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        style: const TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 6),
                      Text(
                        "descryption",
                        style: const TextStyle(
                          fontSize: 20, 
                        )
                      )
                    ],
                  ),
              ]
          ),
                  SizedBox(height: 40,),
                  TextButton(
                    onPressed: () async {
                  await authService.signOut();

                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
                    child: const Text("Log out")
                    )
        ],
        ),
      )
      )
    );
  }

}