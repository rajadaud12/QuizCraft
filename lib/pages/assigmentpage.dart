import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../GradesOverview.dart';
import '../assignment.dart';
import '../mockCreation.dart';

class AssignmentHomePage extends StatelessWidget {
  const AssignmentHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(

          children: [
            SizedBox(height:40),
            Image.asset(
              'assets/images/Logo.png',
              height: 200,
            ),
            SizedBox(height:40),
            _buildOption(
              context,
              icon: Icons.school,
              text: 'Class Assignments',
              onTap: () {
                // Navigate to Class Quizzes Page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ClassAssignmentsPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildOption(
              context,
              icon: Icons.quiz,
              text: 'Mock Assignment',
              onTap: () {
                // Navigate to Mock Quiz Page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AssignmentCreation(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildOption(
              context,
              icon: Icons.grade,
              text: 'View Grades',
              onTap: () {
                // Navigate to View Grades Page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ViewGradesAssignment(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(BuildContext context, {required IconData icon, required String text, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Ink(
        decoration: BoxDecoration(
          color: const Color(0xFF6E1993),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(icon, size: 50, color: Colors.white),
              const SizedBox(width: 20),
              Text(
                text,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ClassAssignmentsPage extends StatelessWidget {
  const ClassAssignmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Assignments'),
      ),
      body: const Center(
        child: Text('Class Assignment Page Content'),
      ),
    );
  }
}

