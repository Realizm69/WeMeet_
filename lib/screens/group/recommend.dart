import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void showCreateMeetingBottomSheet(BuildContext context, String groupId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    constraints: BoxConstraints(
    minHeight: MediaQuery.of(context).size.height * 0.7, // 화면 높이의 70%부터 시작
    maxHeight: MediaQuery.of(context).size.height * 0.9, // 최대 화면 높이의 90%까지 확장 가능
    maxWidth: MediaQuery.of(context).size.width, // 너비는 화면 전체
  ),
    builder: (context) {
      return CreateMeetingBottomSheet(groupId: groupId);
    },
  );
}

class CreateMeetingBottomSheet extends StatefulWidget {
  final String groupId;

  const CreateMeetingBottomSheet({super.key, required this.groupId});

  @override
  State<CreateMeetingBottomSheet> createState() => _CreateMeetingBottomSheetState();
}

class _CreateMeetingBottomSheetState extends State<CreateMeetingBottomSheet> {
  late final String groupId;
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  int _selectedStartHour = 18; // 기본값: 오후 6시
  TimeRange? _recommendedTime;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickHour() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _selectedStartHour, minute: 0),
    );
    if (picked != null) {
      setState(() {
        _selectedStartHour = picked.hour;
      });
    }
  }

  Future<void> _showRecommendationDialog() async {
    final date = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final recommendations = await _getRecommendedTimes(date, _selectedStartHour);

    if (recommendations.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("추천 실패"),
          content: const Text("추천 가능한 시간이 없습니다."),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("확인"))],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("추천 시간"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: recommendations.map((range) {
            return Column(
              children: [
                Text("${DateFormat('HH:mm').format(range.start)} ~ ${DateFormat('HH:mm').format(range.end)}"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _recommendedTime = range;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text("수락"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("거절"),
                    ),
                  ],
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<List<TimeRange>> _getRecommendedTimes(DateTime date, int startHour) async {
    final groupDoc = await FirebaseFirestore.instance.collection('groups').doc(widget.groupId).get();
    final memberUids = List<String>.from(groupDoc.data()?['members'] ?? []);

    // 가능한 시간 슬롯 생성 (1시간 단위)
    List<TimeRange> candidateSlots = List.generate(
      24 - startHour,
      (i) {
        final start = DateTime(date.year, date.month, date.day, startHour + i);
        final end = start.add(const Duration(hours: 1));
        return TimeRange(start: start, end: end);
      },
    );

    List<TimeRange> allSchedules = [];

    for (String uid in memberUids) {
      final snapshot = await FirebaseFirestore.instance
          .collection('schedules')
          .where('uid', isEqualTo: uid)
          .where('startTime',)
          .where('endTime',)
          .get();

      allSchedules.addAll(snapshot.docs.map((doc) {
        try {
          final start = DateTime.parse(doc['startTime'] as String);
          final end = DateTime.parse(doc['endTime'] as String);
          return TimeRange(start: start, end: end);
        } catch (e) {
          log("Error parsing date: $e");
          return null; // 파싱 오류 발생 시 null 반환하고 이후 필터링
        }
      }).whereType<TimeRange>().toList()); // null 값 제거
    }

    // 슬롯 중 겹치는 시간 제거
    List<TimeRange> availableSlots = candidateSlots.where((slot) {
      for (var schedule in allSchedules) {
        final bool overlaps = schedule.start.isBefore(slot.end) && schedule.end.isAfter(slot.start);
        if (overlaps) return false;
      }
      return true;
    }).toList();

    return availableSlots.take(2).toList(); // 최대 2개의 추천 시간 반환
  }

  Future<void> _saveMeeting() async {
    if (_titleController.text.isEmpty || _descController.text.isEmpty || _recommendedTime == null) return;

    await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('meetings')
        .add({
      'title': _titleController.text.trim(),
      'description': _descController.text.trim(),
      'startTime': _recommendedTime!.start,
      'endTime': _recommendedTime!.end,
      'timestamp': Timestamp.now(),
    });

    // 첫 번째 pop: 현재 화면을 스택에서 제거하고 바로 이전 화면으로 이동
Navigator.pop(context);

// 두 번째 pop: 이제 이전 화면이 현재 화면이 되었으므로, 다시 pop하여 그 이전 화면으로 이동
Navigator.pop(context);
       // Bottom Sheet 닫기
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: '모임 제목')),
            TextField(controller: _descController, decoration: const InputDecoration(labelText: '모임 장소')),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text("모임 날짜: "),
                OutlinedButton(
                  onPressed: _pickDate,
                  child: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                ),
              ],
            ),
            Row(
              children: [
                const Text("추천 시작 시간: "),
                OutlinedButton(
                  onPressed: _pickHour,
                  child: Text("약 $_selectedStartHour:00"),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
              onPressed: _showRecommendationDialog,
              child: const Text("추천 시간 받기"),
            ),
            if (_recommendedTime != null) ...[
              const SizedBox(height: 16),
              Text("선택된 시간: ${DateFormat('HH:mm').format(_recommendedTime!.start)} ~ ${DateFormat('HH:mm').format(_recommendedTime!.end)}"),
            ],
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
              child: const Text("모임 저장"),
            ),
            SizedBox(height: 600,)
          ],
        ),
      ),
    );
  }
}

class TimeRange {
  final DateTime start;
  final DateTime end;

  TimeRange({required this.start, required this.end});

  bool overlaps(TimeRange other) {
    return start.isBefore(other.end) && end.isAfter(other.start);
  }
}