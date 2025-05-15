import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wemeet/models/event.dart';
import 'package:wemeet/providers/schedule_provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:wemeet/screens/schedule_screen/schedule_add.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});
  
  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final _firestoreService = FirestoreService();

  List<Schedule> schedules = [];
  DateTime selectedDate = DateTime.now();
  final CalendarController _controller = CalendarController();
  Color? headerColor, viewHeaderColor, calendarColor;
String username = ""; // 기본값
  final user = FirebaseAuth.instance.currentUser;
  
  @override
  void initState() {
    super.initState();
    fetchUsername();
    loadSchedules();
//irestore에서 사용자 이름 불러오기
  }
  Future<void> loadSchedules() async {
    final data = await _firestoreService.fetchSchedules();
    setState(() {
      schedules = data;
    });
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
        });
      }
    }
  } 
  void calendarTapped(CalendarTapDetails calendarTapDetails) { 
    if (_controller.view == CalendarView.month && calendarTapDetails.targetElement == CalendarElement.calendarCell) 
    { _controller.view = CalendarView.day; } else if 
    ((_controller.view == CalendarView.week || _controller.view == CalendarView.workWeek) && calendarTapDetails.targetElement == CalendarElement.viewHeader) 
    { _controller.view = CalendarView.day; }       
    } 
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '오늘의 시간표',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                height: 550,
                color: Colors.white,
                alignment: Alignment.center,
                child: SfCalendar(
                  todayHighlightColor: Colors.lightBlue,
                  view: CalendarView.month,
                  timeZone: 'Korea Standard Time',
                  showCurrentTimeIndicator: true,
                  allowedViews: [
                  CalendarView.day,
                  CalendarView.week,
                  CalendarView.month,
                  ],
                  viewHeaderStyle:
                  ViewHeaderStyle(backgroundColor: Colors.white),
                  backgroundColor: calendarColor,
                  controller: _controller,
                  initialDisplayDate: DateTime.now(),
                  onTap: calendarTapped,
                  monthViewSettings: MonthViewSettings(
                  showAgenda: true,
                  navigationDirection: MonthNavigationDirection.vertical,
                  dayFormat: 'EEE'
                  ),
                  scheduleViewSettings: ScheduleViewSettings(
                    appointmentItemHeight: 50,
                    hideEmptyScheduleWeek: true,
                    dayHeaderSettings: DayHeaderSettings(
                dayFormat: 'EEEE',
                width: 70,
                dayTextStyle: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w300,
                  color: Colors.red,
                ),
                dateTextStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                  color: Colors.red,
                )
                    ),
                    weekHeaderSettings: WeekHeaderSettings(
                startDateFormat: 'dd MMM ',
                endDateFormat: 'dd MMM, yy',
                height: 50,
                textAlign: TextAlign.center,
                backgroundColor: Colors.red,
                weekTextStyle: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 15,
                )
                ),
                monthHeaderSettings: MonthHeaderSettings(
                  monthFormat: 'MMMM, yyyy',
                height: 70,
                textAlign: TextAlign.center,
                backgroundColor: Colors.green,
                monthTextStyle: TextStyle(
                    color: Colors.red,
                    fontSize: 20,
                    fontWeight: FontWeight.w400)
                )
                  ),
                  dataSource: _getCalendarDataSource(),
                  
                )
              ),
              const SizedBox(height: 16),
              FloatingActionButton(
                backgroundColor: Colors.lightBlueAccent,
        onPressed: () async {
          final result = await Navigator.push(
          context,
            MaterialPageRoute(builder: (context) => AddScheduleScreen()),
            );
             if (result == true) {
      setState(() {
        loadSchedules();// 여기에 캘린더 데이터 새로고침 코드 (필요시 Provider나 fetch 함수 호출)
      });
    }
        },
        child: const Icon(Icons.add , color: Colors.white,),
      ),// 날짜 선택 버튼
            ],
          ),
        ),
      ),
    );
  }
  ScheduleDataSource _getCalendarDataSource() {
    List<Appointment> appointments = schedules.map((schedule) {
      return Appointment(
        startTime: schedule.startTime,
        endTime: schedule.endTime,
        subject: schedule.title,
        notes: schedule.description,
        color: Colors.blue
      );
    }).toList();

    return ScheduleDataSource(appointments);
  }

}
class ScheduleDataSource extends CalendarDataSource {
  ScheduleDataSource(List<Appointment> source) {
    appointments = source;
  }
}
