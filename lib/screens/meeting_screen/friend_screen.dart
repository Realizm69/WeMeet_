import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wemeet/screens/meeting_screen/friend_req.dart';
import 'package:wemeet/services/friendreq.dart';

class FriendScreen extends StatefulWidget {
  const FriendScreen({super.key});
  @override
  State<FriendScreen> createState() => _FriendScreenState();
}

class _FriendScreenState extends State<FriendScreen> {
    final TextEditingController usernameController = TextEditingController();
  String username = "";
  String photoUrl = "https://i.pravatar.cc/150?img=3"; // 기본값
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
        title: Text('친구 목록'),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                          context: context,
                          builder: (BuildContext context) {
                          return AlertDialog(
                          backgroundColor: Colors.white,
                          title: const Text("친구 추가" , ),
                          content: TextField(
                            controller: usernameController,
                  
                            decoration: InputDecoration(labelText: "친구 이름", border: OutlineInputBorder() ,
                            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color : Colors.black))),
                          ),
                          actions: [
                              TextButton(
                                onPressed: () async {
                                  String username = usernameController.text.trim();
                                  await FriendService.sendFriendRequestByUsername(username);
                                  Navigator.pop(context);
                                  },
                              child: const Text("친구 추가")
                  )
                ],
              );
            }
        );
          }
          , icon: Icon(Icons.search)
          ),
          IconButton(
            onPressed: () async {
                      await Navigator.push(
                      context,
                       MaterialPageRoute(builder: (context) => FriendRequestScreen()),
                      );
                    }, 
           icon: Icon(Icons.add_circle_outline)
           )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundImage: NetworkImage(photoUrl),
                  ),
                  const SizedBox(height: 20),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        username,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10,),
                      const Text(
                        'Description',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 5),
              Expanded(
                  child:  StreamBuilder<List<Map<String, dynamic>>>(
  stream: FriendService.getFriends(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) return CircularProgressIndicator();
    final friends = snapshot.data!;
    if (friends.isEmpty){
      return Center ( child: Text("친구가 없습니다."));
    }
    return ListView.builder(
      shrinkWrap: true,
      itemCount: friends.length,
      itemBuilder: (context, index) {
        final friend = friends[index];
        final photoUrl = friend['photo'] ?? 'https://i.pravatar.cc/150?img=3';
        return SizedBox(
          width: 300,
          height: 80,
          child: ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(photoUrl),
            radius: 30,
          ),
          title: Text(friend['username'] , style: TextStyle(fontSize: 20),),
        ),
        );
      },
    );
  },
)     
              )
            ],
            
          ),
        ),
        ),
      );
  }
}
