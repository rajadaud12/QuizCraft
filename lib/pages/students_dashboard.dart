import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'SignInPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({Key? key}) : super(key: key);

  static const Color iconAndTextColor = Color(0xFF6E1993);

  @override
  _StudentDashboardState createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  String userName = '';
  int quizzesDue = 0;
  int assignmentsDue = 0;
  int classesEnrolled = 0;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          setState(() {
            userName = userDoc['fullName'];
            quizzesDue = userDoc['quizzesDue'];
            assignmentsDue = userDoc['assignmentsDue'];
            classesEnrolled = userDoc['Classes Enrolled'];
          });
        }
      }
    } catch (e) {
      setState(() {
        userName = 'User';
      });
    }
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => SignInPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title: Text(
          'Student Dashboard',
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.purple,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Logout'),
              onTap: _signOut,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi, $userName',
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: buildDashboardCard('Quizzes\n due', quizzesDue, Colors.orange, Icons.class_)),
                Expanded(child: buildDashboardCard('Assignments\n due', assignmentsDue, Colors.red, Icons.assignment)),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              child: buildDashboardCard('Classes Enrolled', classesEnrolled, Colors.purple, Icons.check_box),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Card buildDashboardCard(String title, int count, Color color, IconData icon,) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  count.toString(),
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(fontSize: 70, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                Icon(icon, color: Colors.white, size: 50),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(height: 5),
            ElevatedButton(
              onPressed: () {
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: color,
                backgroundColor: count == 0 ? Colors.grey[300] : Colors.white,
              ),
              child: Text(
                'VIEW',
                style: TextStyle(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Card buildActivityCard(String user, String activity) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey,
          child: Text(
            user[0],
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(user),
        subtitle: Text(activity),
      ),
    );
  }
}
