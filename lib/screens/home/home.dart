import 'package:flutter/material.dart';
import 'package:wemeet/screens/home/homescreen.dart';
import 'package:wemeet/screens/meeting_screen/meeting_screen.dart';
import 'package:wemeet/screens/schedule_screen/schedule_screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  final List<Widget> _tabs = [
    HomeScreen(),     // 홈 탭 (처음 보여줄 화면)
    MeetingScreen(),    // 모임 탭
    ScheduleScreen(), // 시간표 탭
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue ,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: '모임',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: '시간표',
          ),
        ],
      ),
    );
  }
}
