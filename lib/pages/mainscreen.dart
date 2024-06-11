import 'package:flutter/material.dart';
import 'package:quizcraft/pages/assigmentpage.dart';
import 'package:quizcraft/pages/quizPage.dart';
import 'package:quizcraft/pages/students_dashboard.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'classes.dart';
import '../main.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  PageController _pageController = PageController();

  void _onTabChange(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          StudentDashboard(),
          ClassesPage(),
          QuizHomePage(),
          AssignmentHomePage(),
          Container(), // Placeholder for Notifications page
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
        child: GNav(
          rippleColor: Colors.white,
          hoverColor: Colors.white,
          haptic: true,
          tabBorderRadius: 20,
          tabShadow: [BoxShadow(color: Colors.white.withOpacity(0.5), blurRadius: 8)],
          curve: Curves.easeIn,
          duration: Duration(milliseconds: 900),
          gap: 0,
          color: Colors.grey[800],
          activeColor: Colors.purple,
          iconSize: 24,
          tabBackgroundColor: Colors.purple.withOpacity(0.1),
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          selectedIndex: _selectedIndex,
          onTabChange: _onTabChange,
          tabs: [
            GButton(
              icon: LineIcons.home,
              text: 'Home',
            ),
            GButton(
              icon: LineIcons.book,
              text: 'Class',
            ),
            GButton(
              icon: LineIcons.question,
              text: 'Quiz',
            ),
            GButton(
              icon: LineIcons.tasks,
              text: 'Assignment',
            ),
            GButton(
              icon: Icons.notifications,
              text: 'Notification',
              gap:4,
            ),
          ],
        ),
      ),
    );
  }
}
