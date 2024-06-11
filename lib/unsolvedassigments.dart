import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import 'package:flutter_pdf_text/flutter_pdf_text.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'FirebaseAuthorizationSingleton.dart';

class ViewUnsolvedAssignments extends StatelessWidget {
  const ViewUnsolvedAssignments({Key? key});


  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser!.uid;


    return Scaffold(
      appBar: AppBar(
        title: const Text('Unsolved Assignments'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('mockAssignments')
            .where('userId', isEqualTo: userId)
            .where('isSolved', isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No unsolved assignments available'));
          }

          final unsolvedAssignments = snapshot.data!.docs;

          return ListView.builder(
            itemCount: unsolvedAssignments.length,
            itemBuilder: (context, index) {
              final assignment = unsolvedAssignments[index];
              return AssignmentCard(
                assignment: assignment,
              );
            },
          );
        },
      ),
    );
  }
}

class AssignmentCard extends StatefulWidget {
  final QueryDocumentSnapshot assignment;

  const AssignmentCard({Key? key, required this.assignment}) : super(key: key);

  @override
  _AssignmentCardState createState() => _AssignmentCardState();
}

class _AssignmentCardState extends State<AssignmentCard> {
  final FirebaseAuth _auth = FirebaseAuthService.instance.auth;
  bool _isLoading = false;
  int? _grade;
  Future<void> _uploadAndEvaluatePDF(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final pdfFile = File(result.files.single.path!);
      final pdfText = await extractTextFromPDF(pdfFile);

      // Call AI to evaluate text and assign marks
      int totalMarks = widget.assignment['totalMarks'];
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: 'AIzaSyAJXG8t0QaODio6R_RJXM-x_dgBNR8GJao');
      final content = [
        Content.text(
          'The topic of assignment is ${widget.assignment['assignmentContent']}.\n Evaluate with brutal honesty the following text for an assignment worth $totalMarks marks, just return marks(i.e: 8), dont give any explanation or reason:\n$pdfText',
        )
      ];
      final response = await model.generateContent(content);
      final grade = int.parse(response.text!.replaceAll(RegExp(r'[^0-9]'), ''));

      // Save the user's solution and mark assignment as solved
      await FirebaseFirestore.instance.collection('mockAssignments').doc(widget.assignment.id).update({
        'uploadedText': pdfText,
        'grade': grade,
        'isSolved': true,
        'solvedTimestamp': Timestamp.now(),
      });
      await FirebaseFirestore.instance.collection('assignments').add({
        'topic': widget.assignment['topic'],
        'totalMarks': totalMarks,
        'grade': grade,
        'assignmentContent': widget.assignment['assignmentContent'],
        'uploadedText': pdfText,
        'timestamp': Timestamp.now(),
        'userId': _auth.currentUser!.uid,
      });

      setState(() {
        _isLoading = false;
        _grade = grade;
      });

      // Show AlertDialog with assignment content and score
      _showScorePopup(context);

    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error: $e');
      throw Exception('Failed to evaluate PDF: $e');
    }
  }

  void _showScorePopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Assignment Topic: ${widget.assignment['topic']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text('You scored $_grade out of ${widget.assignment['totalMarks']}'),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }


  Future<String> extractTextFromPDF(File pdfFile) async {
    try {
      final doc = await PDFDoc.fromFile(pdfFile);
      String extractedText = '';
      for (int i = 1; i <= doc.length; i++) {
        final page = await doc.pageAt(i);
        final text = await page.text;
        extractedText += text;
      }
      return extractedText;
    } catch (e) {
      print('Error extracting text from PDF: $e');
      throw Exception('Failed to extract text from PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('Topic: ${widget.assignment['topic']}'),
        subtitle: Text('Marks: ${widget.assignment['totalMarks']}'),
        onTap: () {
          _showAssignmentContentDialog(context);
        },
        trailing: IconButton(
          icon: _isLoading ? const CircularProgressIndicator() : const Icon(Icons.upload_file),
          onPressed: () {
            if (!_isLoading) {
              _uploadAndEvaluatePDF(context);
            }
          },
        ),
      ),
    );
  }

  void _showAssignmentContentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Assignment Topic: ${widget.assignment['topic']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Assignment Content:'),
              Text(widget.assignment['assignmentContent']),
            ],
          ),
        ),
      ),
    );
  }
}
