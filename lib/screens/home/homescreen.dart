import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:wemeet/screens/home/profile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String photoUrl = "https://i.pravatar.cc/150?img=3";
  String username = "";
  final user = FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>> upcomingMeetings = [];

  @override
  void initState() {
    super.initState();
    fetchUsername();
    fetchMyMeetings();
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
          photoUrl = userDoc['photo'] ?? 'https://i.pravatar.cc/150?img=3';
        });
      }
    }
  }

  Future<void> fetchMyMeetings() async {
    if (user == null) return;

    final groupQuery = await FirebaseFirestore.instance
        .collection('groups')
        .where('members', arrayContains: user!.uid)
        .get();

    List<Map<String, dynamic>> allMeetings = [];

    for (var groupDoc in groupQuery.docs) {
      final groupId = groupDoc.id;

      final meetingQuery = await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .collection('meetings')
          .get();

      for (var meetingDoc in meetingQuery.docs) {
        final data = meetingDoc.data();
        final startTime = (data['startTime'] as Timestamp).toDate();

        // 오늘 이후의 일정만 필터링
        if (startTime.isAfter(DateTime.now())) {
          data['groupId'] = groupId;
          data['meetingId'] = meetingDoc.id;
          allMeetings.add(data);
        }
      }
    }

    // 시작 시간 기준 정렬
    allMeetings.sort((a, b) {
      final aTime = (a['startTime'] as Timestamp).toDate();
      final bTime = (b['startTime'] as Timestamp).toDate();
      return aTime.compareTo(bTime);
    });

    setState(() {
      upcomingMeetings = allMeetings;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea ( 
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 프로필 카드
              Container(
                margin: EdgeInsets.symmetric(vertical: 1),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Profile()));
                      },
                      child: CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(photoUrl),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          '이용자',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                '다가오는 모임',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: upcomingMeetings.isEmpty
                    ? Center(
                        child: Text(
                          '다가오는 모임이 없습니다!',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: upcomingMeetings.length,
                        itemBuilder: (context, index) {
                          final meeting = upcomingMeetings[index];
                          final startTime =
                              (meeting['startTime'] as Timestamp).toDate();
                          final title = meeting['title'] ?? '제목 없음';
                          final address = meeting['description'] ?? '장소 없음';

                          return Container(
                            height: 100,
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
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: Center (child: ListTile(
                              isThreeLine: true,
                              title: Text(title , style: TextStyle(color: Colors.white),),
                              subtitle: Text(
                                  '장소: $address\n시간: ${DateFormat('yyyy-MM-dd HH:mm').format(startTime)}' , style: TextStyle(color: Colors.white),),
                            ),
                            )
                          );
                        },
                      ),
              ),
            ],
          ),
      ),
      )
    );
  }
}
