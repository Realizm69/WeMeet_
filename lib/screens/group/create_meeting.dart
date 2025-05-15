import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wemeet/screens/group/recommend.dart';

class CreateMeetingScreen extends StatefulWidget {
  final String groupId;

  const CreateMeetingScreen({super.key, required this.groupId});

  @override
  State<CreateMeetingScreen> createState() => _CreateMeetingScreenState();
}

class _CreateMeetingScreenState extends State<CreateMeetingScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now().add(Duration(hours: 1));
  

  Future<void> _pickDateTime({required bool isStart}) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStart ? _startTime : _endTime,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );

    if (pickedDate == null) return;

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(isStart ? _startTime : _endTime),
    );

    if (pickedTime == null) return;

    final selected = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      if (isStart) {
        _startTime = selected;
        if (_endTime.isBefore(_startTime)) {
          _endTime = _startTime.add(Duration(hours: 1));
        }
      } else {
        _endTime = selected;
      }
    });
  }

  void _saveMeeting() async {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();

    if (title.isEmpty || desc.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('meetings')
        .add({
      'title': title,
      'description': desc,
      'startTime': _startTime,
      'endTime': _endTime,
      'timestamp': Timestamp.now(),
    });

    Navigator.pop(context, true); // 저장 후 true 반환
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('모임 생성'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _titleController, decoration: InputDecoration(labelText: '모임 제목')),
            TextField(controller: _descController, decoration: InputDecoration(labelText: '모임 장소')),
            const SizedBox(height: 16),

            Row(
              children: [
                Text('시작 시간: ', style: TextStyle(fontWeight: FontWeight.bold)),
                OutlinedButton(
                  onPressed: () => _pickDateTime(isStart: true),
                  child: Text(DateFormat('yyyy-MM-dd HH:mm').format(_startTime)),
                ),
              ],
            ),
            Row(
              children: [
                Text('종료 시간: ', style: TextStyle(fontWeight: FontWeight.bold)),
                OutlinedButton(
                  onPressed: () => _pickDateTime(isStart: false),
                  child: Text(DateFormat('yyyy-MM-dd HH:mm').format(_endTime)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shadowColor: Colors.blueGrey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                ),
  onPressed: () => _showMeetingBottomSheet(context),
  child: Text('모임 생성하기' , style: TextStyle(color: Colors.white , fontWeight: FontWeight.bold)),
  
),

            const SizedBox(height: 24),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shadowColor: Colors.blueGrey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                ),
              onPressed: _saveMeeting,
              child: Text('모임 저장' , style: TextStyle(color: Colors.white , fontWeight: FontWeight.bold),),
            ),
          ],
        ),
      ),
    );
  }
  void _showMeetingBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    constraints: BoxConstraints(
    minHeight: MediaQuery.of(context).size.height * 0.7, // 화면 높이의 70%부터 시작
    maxHeight: MediaQuery.of(context).size.height * 0.9, // 최대 화면 높이의 90%까지 확장 가능
    maxWidth: MediaQuery.of(context).size.width, // 너비는 화면 전체
  ),
    builder: (context) => CreateMeetingBottomSheet(groupId: widget.groupId),
  );
}
}
