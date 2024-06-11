import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import for authentication

class ViewGradesQuiz extends StatelessWidget {
  const ViewGradesQuiz({super.key});

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser!.uid; // Get the current user's ID

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text('View Quiz Grades'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('quizzes')
            .where('userId', isEqualTo: userId) // Filter by current user's ID
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No grades available'));
          }

          final quizDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: quizDocs.length,
            itemBuilder: (context, index) {
              final quiz = quizDocs[index];
              return Card(
                color: Colors.white,
                margin: const EdgeInsets.all(10.0),
                child: ListTile(
                  title: Text(
                    'Topic: ${quiz['topic']}',
                    style: GoogleFonts.poppins(),
                  ),
                  subtitle: Text(
                    'Grade: ${quiz['grade']}/${quiz['totalMarks']}',
                    style: GoogleFonts.poppins(),
                  ),
                  trailing: Text(
                    '${(quiz['grade'] / quiz['totalMarks'] * 100).toStringAsFixed(1)}%',
                    style: GoogleFonts.poppins(),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
class ViewGradesAssignment extends StatelessWidget {
  const ViewGradesAssignment({super.key});

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser!.uid; // Get the current user's ID

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text('View Assignment Grades'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('assignments')
            .where('userId', isEqualTo: userId) // Filter by current user's ID
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No grades available'));
          }

          final assignmentDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: assignmentDocs.length,
            itemBuilder: (context, index) {
              final assignment = assignmentDocs[index];
              return Card(
                color: Colors.white,
                margin: const EdgeInsets.all(10.0),
                child: ListTile(
                  title: Text(
                    'Topic: ${assignment['topic']}',
                    style: GoogleFonts.poppins(),
                  ),
                  subtitle: Text(
                    'Grade: ${assignment['grade']}/${assignment['totalMarks']}',
                    style: GoogleFonts.poppins(),
                  ),
                  trailing: Text(
                    '${(assignment['grade'] / assignment['totalMarks'] * 100).toStringAsFixed(1)}%',
                    style: GoogleFonts.poppins(),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
