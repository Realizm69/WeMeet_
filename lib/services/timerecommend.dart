import 'package:cloud_firestore/cloud_firestore.dart';


class TimeRange {
  final DateTime start;
  final DateTime end;

  TimeRange({required this.start, required this.end});

  bool overlaps(TimeRange other) {
    return start.isBefore(other.end) && end.isAfter(other.start);
  }
}

Future<List<TimeRange>> getRecommendedTimesForGroup({
  required String groupId,
  required DateTime selectedDate,
  required int preferredStartHour,
}) async {
  DateTime startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
  DateTime endOfDay = startOfDay.add(Duration(days: 1));

  // Step 1: Get group members
  final groupDoc = await FirebaseFirestore.instance.collection('groups').doc(groupId).get();
  final memberUids = List<String>.from(groupDoc.data()?['members'] ?? []);

  // Step 2: Gather all schedules for the day
  List<TimeRange> busyRanges = [];

  for (String uid in memberUids) {
    final snapshot = await FirebaseFirestore.instance
        .collection('schedules')
        .where('uid', isEqualTo: uid)
        .where('startTime', isLessThan: endOfDay)
        .where('endTime', isGreaterThan: startOfDay)
        .get();

    for (var doc in snapshot.docs) {
      final start = (doc['startTime'] as Timestamp).toDate();
      final end = (doc['endTime'] as Timestamp).toDate();
      busyRanges.add(TimeRange(start: start, end: end));
    }
  }

  // Step 3: Check each hour slot from preferredStartHour to midnight
  Map<int, int> slotAvailableCounts = {};
  for (int hour = preferredStartHour; hour < 24; hour++) {
    DateTime slotStart = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, hour);
    DateTime slotEnd = slotStart.add(Duration(hours: 1));
    TimeRange slot = TimeRange(start: slotStart, end: slotEnd);

    bool isFree = true;
    for (TimeRange busy in busyRanges) {
      if (slot.overlaps(busy)) {
        isFree = false;
        break;
      }
    }
    if (isFree) {
      slotAvailableCounts[hour] = 0;
    }
  }

  // Step 4: Return top 2 available slots
  List<int> sortedFreeHours = slotAvailableCounts.keys.toList()..sort();
  List<TimeRange> topTwo = sortedFreeHours.take(2).map((hour) {
    final start = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, hour);
    return TimeRange(start: start, end: start.add(Duration(hours: 1)));
  }).toList();

  return topTwo;
}
