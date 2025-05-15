import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wemeet/models/event.dart';
import 'package:wemeet/providers/schedule_provider.dart';
import 'package:intl/intl.dart';


class AddScheduleScreen extends StatefulWidget {

  const AddScheduleScreen({
    super.key,
  });

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
    final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now().add(Duration(hours: 1));
  Color selectedColor = Colors.blue;
  final uid = FirebaseAuth.instance.currentUser?.uid;
  final _firestoreService = FirestoreService();

  void _saveSchedule() async {
    final schedule = Schedule(
      id: '',
      uid: uid!,
      title: _titleController.text,
      description: _descController.text,
      startTime: startTime,
      endTime: endTime,
    );
    await _firestoreService.addSchedule(schedule);
    Navigator.pop(context , true); // 저장 후 이전 화면으로
  }
  
  Future<void> _pickDateTime({required bool isStart}) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? startTime : endTime,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(isStart ? startTime : endTime),
      );
      if (time != null) {
        setState(() {
          DateTime combined = DateTime(picked.year, picked.month, picked.day, time.hour, time.minute);
          if (isStart) {
            startTime = combined;
          } else {
            endTime = combined;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('일정 추가') , backgroundColor: Colors.white,),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [ 
          TextField(controller: _titleController, decoration: InputDecoration(labelText: "제목") , ),
          TextField(controller: _descController, decoration: InputDecoration(labelText: "설명") , ),
                
            const SizedBox(height: 12),
            Row(
              children: [
                Text('시작 시간:   ' , style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                OutlinedButton(
                  
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2)
                    )
                  ),
                  child: Text(DateFormat('yyyy-MM-dd HH:mm').format(startTime) , style: TextStyle(color: Colors.black),),
                  onPressed: () => _pickDateTime(isStart: true),
                )
              ],
            ),
            Row(
              children: [
                Text("종료 시간:   " , style: TextStyle(color: Colors.black , fontWeight: FontWeight.bold),),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2)
                    )
                  ),
                child: Text(DateFormat('yyyy-MM-dd HH:mm').format(endTime) , style: TextStyle(color: Colors.black)),
                
                  onPressed: () => _pickDateTime(isStart: false),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white
              ),
              onPressed: _saveSchedule,
              child: Text('일정 저장' , style: TextStyle(color: Colors.black),),
            ),
          ],
        ),
      ),
    );
  }
}