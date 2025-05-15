import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wemeet/screens/group/create_meeting.dart';

class GroupScreen extends StatefulWidget {
  final Map<String, dynamic> groupData;

  const GroupScreen({super.key, required this.groupData});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  List<Map<String, dynamic>> memberProfiles = [];
  List<Map<String, dynamic>> meetings = [];

  @override
  void initState() {
    super.initState();
    fetchMemberProfiles();
    fetchMeetings();
  }

  Future<void> fetchMeetings() async {
  final groupId = widget.groupData['id']; // 그룹 ID 필요
  final now = Timestamp.now(); // 현재 시간

  final snapshot = await FirebaseFirestore.instance
      .collection('groups')
      .doc(groupId)
      .collection('meetings')
      .where('startTime', isGreaterThan: now) // 현재 이후의 모임만
      .orderBy('startTime', descending: false) // 가까운 순서대로 정렬
      .get();

  final data = snapshot.docs.map((doc) => doc.data()).toList();

  setState(() {
    meetings = data;
  });
}
  
  void navigateToCreateMeeting() async {
    final groupId = widget.groupData['id'];
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateMeetingScreen(groupId: groupId),
      ),
    );

    if (result == true) {
      fetchMeetings(); // 다시 불러오기
    }
  }

  Future<void> fetchMemberProfiles() async {
    List<String> memberUids = List<String>.from(widget.groupData['members'] ?? []);
    List<Map<String, dynamic>> fetchedProfiles = [];

    for (String uid in memberUids) {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        fetchedProfiles.add({
          'username': data['username'] ?? '이름 없음',
          'photoUrl': data['photo'] ?? 'https://i.pravatar.cc/150?img=3',
        });
      }
    }

    setState(() {
      memberProfiles = fetchedProfiles;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String groupName = widget.groupData['name'] ?? '그룹 이름 없음';

    return Scaffold(
      appBar: AppBar(
        title: Text(groupName),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 프로필 리스트
            SizedBox(
              height: 140,
              child: memberProfiles.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: memberProfiles.length,
                      itemBuilder: (context, index) {
                        final member = memberProfiles[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundImage: NetworkImage(member['photoUrl']),
                              ),
                              SizedBox(height: 10),
                              Text(member['username']),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),
            // 추천 카드들
            buildRecommendationCard("모임 생성"),
            SizedBox(height: 8),
            Expanded(
            child: ListView.builder(
        itemCount: meetings.length,
        itemBuilder: (context, index) {
          final meeting = meetings[index];
          return buildMeetingCard(meeting);
        },
      ),
    )
          ],
        ),
      ),
    );
  }

  Widget buildRecommendationCard(String title,) {
    return GestureDetector ( 
      onTap: () {
        navigateToCreateMeeting();
      },
      child: Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      width: double.infinity,
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
                    const Color.fromARGB(255, 67, 163, 243),
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
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold , color: Colors.white , fontSize: 20), 
        ),
      ),
    )
    );
  }
  Widget buildMeetingCard(Map<String, dynamic> meeting) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
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
                    const Color.fromARGB(255, 99, 180, 247),
                    const Color.fromARGB(255, 79, 165, 235),
                    const Color.fromARGB(255, 53, 155, 239),
                    const Color.fromARGB(255, 53, 155, 236)
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
        Text(meeting['title'] ?? '제목 없음', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold , color: Colors.white) , ),
        SizedBox(height: 6),
        Text(meeting['description'] ?? '설명 없음' , style: TextStyle(color: Colors.white),),
        SizedBox(height: 6),
        Text("모임 날짜: ${meeting['startTime']?.toDate()?.toString().split('.')[0] ?? ''}", style: TextStyle(fontSize: 12, color: const Color.fromARGB(255, 255, 255, 255))),
      ],
    ),
  );
}
}
