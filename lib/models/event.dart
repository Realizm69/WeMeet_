
class Schedule {
  final String id;
  final String uid;           // 문서 id
  final String title;         // 제목
  final String description;   // 설명
  final DateTime startTime;    // 시작 시간
  final DateTime endTime;      // 종료 시간        // 표시 색깔
  final String? recurrenceRule; // 반복 규칙 (ex: 매주 월수금)

  Schedule( 
  {
    required this.id,
    required this.uid,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    this.recurrenceRule,
  });

  // Firestore 저장용 Map
  Map<String, dynamic> toMap() {
    return {
      'uid' : uid,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),   // int로 저장
      'recurrenceRule': recurrenceRule,
    };
  }

  // Firestore에서 불러오기
  factory Schedule.fromMap(String id, Map<String, dynamic> map) {
    return Schedule(
      id: id,
      uid : map['uid'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      recurrenceRule: map['recurrenceRule'],
    );
  }
}
