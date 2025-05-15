import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wemeet/services/friendreq.dart';

class FriendRequestScreen extends StatefulWidget {
  const FriendRequestScreen({super.key});

  @override
  State<FriendRequestScreen> createState() => _FriendRequestScreenState();
}

class _FriendRequestScreenState extends State<FriendRequestScreen> {
  final String? currentUid = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    if (currentUid == null) {
      return Scaffold(
        appBar: AppBar(title: Text('친구 요청')),
        body: Center(child: Text('로그인이 필요합니다.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('친구 요청') , backgroundColor: Colors.white,),
      body: SafeArea( child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUid)
            .collection('friendRequests')
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final requests = snapshot.data!.docs;

          if (requests.isEmpty) return Center(child: Text('받은 요청이 없습니다.'));

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final data = requests[index].data() as Map<String, dynamic>;
              final requestId = requests[index].id;

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(data['fromPhoto'] ?? 'https://i.pravatar.cc/150?img=3'),
                ),
                title: Text(data['fromUsername'] ?? '알 수 없음'),
                subtitle: Text('친구 요청이 왔습니다.'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.check, color: Colors.green),
                      onPressed: () => FriendService.acceptFriendRequest(requestId,),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.red),
                      onPressed: () => FriendService.rejectFriendRequest(requestId,),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      )
    );
  }
}
