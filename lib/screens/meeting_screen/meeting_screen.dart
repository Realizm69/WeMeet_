import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wemeet/screens/group/group_screen.dart';
import 'package:wemeet/screens/meeting_screen/friend_screen.dart';

class MeetingScreen extends StatefulWidget {
  const MeetingScreen({super.key});
  @override
  State<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  String username = "";
  String photoUrl = "https://i.pravatar.cc/150?img=3";
  final user = FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>> userFriends = [];
  List<String> selectedFriendUids = [];

  @override
  void initState() {
    super.initState();
    fetchUsername();
    fetchFriends();
  }

  Future<void> fetchUsername() async {
    if (user != null) {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      if (userDoc.exists) {
        setState(() {
          username = userDoc['username'] ?? '이름 없음';
          photoUrl = userDoc['photo'] ?? 'https://i.pravatar.cc/150?img=3';
        });
      }
    }
  }

  Future<void> fetchFriends() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('friends')
        .get();

    setState(() {
      userFriends = snapshot.docs
          .map((doc) => {'uid': doc.id, ...doc.data()})
          .toList();
    });
  }

  Future<void> showCreateGroupDialog() async {
  final nameController = TextEditingController();
  final typeController = TextEditingController();

  // 초기화
  List<String> tempSelectedUids = List.from(selectedFriendUids);

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Text('그룹 만들기'),
        content: StatefulBuilder(
          builder: (context, setStateDialog) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: "그룹 이름"),
                  ),
                  TextField(
                    controller: typeController,
                    decoration: InputDecoration(labelText: "그룹 성향 (예: 동창회, 친구 등)"),
                  ),
                  SizedBox(height: 12),
                  Text('친구 선택', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...userFriends.map((friend) {
                    final uid = friend['uid'];
                    final username = friend['username'] ?? '이름 없음';

                    return CheckboxListTile(
                      value: tempSelectedUids.contains(uid),
                      title: Text(username),
                      onChanged: (bool? selected) {
                        setStateDialog(() {
                          if (selected == true) {
                            tempSelectedUids.add(uid);
                          } else {
                            tempSelectedUids.remove(uid);
                          }
                        });
                      },
                    );
                  })
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              // 아무것도 저장하지 않고 닫기
              Navigator.of(context).pop();
            },
            child: Text('취소', style: TextStyle(color: Colors.black),),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white
            ),
            onPressed: () async {
              // 유효성 검사
              if (nameController.text.trim().isEmpty || tempSelectedUids.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("그룹 이름과 친구를 선택해주세요.")),
                );
                return;
              }

              // 그룹 생성
              await createGroup(
                nameController.text.trim(),
                typeController.text.trim(),
                tempSelectedUids,
              );

              // 최종 선택된 친구들을 selectedFriendUids에 반영
              setState(() {
                selectedFriendUids = tempSelectedUids;
              });

              Navigator.of(context).pop();
            },
            child: Text('생성' , style: TextStyle(color: Colors.black),),
          )
        ],
      );
    },
  );
}


  Future<void> createGroup(String name, String type, List<String> memberUids) async {
    if (name.isEmpty || memberUids.isEmpty) return;
    final currentUid = FirebaseAuth.instance.currentUser!.uid;
  final groupRef = FirebaseFirestore.instance.collection('groups').doc();

  await groupRef.set({
    'id': groupRef.id,
    'name': name,
    'type': type,
    'members': memberUids + [currentUid], // 나 자신도 포함
    'createdAt': FieldValue.serverTimestamp(),
    'createdBy': currentUid,
  });
    setState(() {}); // 다시 로드
  }

  Stream<List<Map<String, dynamic>>> getUserGroups() {
    return FirebaseFirestore.instance
        .collection('groups')
        .where('members', arrayContains: user!.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  const Text(
                  '내 그룹',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                 ),
                  const Spacer(),
                  IconButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FriendScreen()),
                      );
                    },
                    icon: const Icon(Icons.account_box),
                  ),
                  IconButton(
                    onPressed: showCreateGroupDialog,
                    icon: const Icon(Icons.group_add),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: getUserGroups(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return CircularProgressIndicator();
                    final groups = snapshot.data!;
                    if (groups.isEmpty) return Text("생성된 그룹이 없습니다.");

                    return ListView.builder(
                      itemCount: groups.length,
                      itemBuilder: (context, index) {
                        final group = groups[index];
                        return InkWell(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupScreen(groupData: group),
      ),
    );
  },
  child: Container(
    margin: EdgeInsets.symmetric(vertical: 8),
    padding: EdgeInsets.all(16),
    decoration:  BoxDecoration(
    color: Colors.lightBlue,
    borderRadius: BorderRadius.all(Radius.circular(10)),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withValues(alpha: 0.5),
        spreadRadius: 3,
        blurRadius: 5,
        offset: Offset(0, 3), // changes position of shadow
      ),
    ],
    gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color.fromARGB(255, 52, 156, 241),
                    const Color.fromARGB(255, 45, 147, 231),
                    const Color.fromARGB(255, 37, 149, 240),
                    const Color.fromARGB(255, 34, 152, 248)
                  ],
                  stops: const [
                    0.1,
                    0.3,
                    0.9,
                    1.0
                  ])
  ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(group['name'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold , color: Colors.white)),
        SizedBox(height: 4),
        Text(group['type'], style: TextStyle(color: const Color.fromARGB(255, 219, 219, 219))),
      ],
    ),
  ),
);
                      },
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
