import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_pdf_text/flutter_pdf_text.dart';
import 'package:quizcraft/unsolvedassigments.dart';
import 'dart:io';

import 'FirebaseAuthorizationSingleton.dart';
import 'GradesOverview.dart';
import 'ViewUnsolvedAssignments.dart'; // Import the new unsolved assignments page

class AssignmentCreation extends StatefulWidget {
  const AssignmentCreation({super.key});

  @override
  _AssignmentCreationState createState() => _AssignmentCreationState();
}

class _AssignmentCreationState extends State<AssignmentCreation> {
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _totalMarksController = TextEditingController();
  bool _isLoading = false;
  bool _isGenerated = false;
  bool _isSubmitted = false;
  String? _generatedAssignment;
  FilePickerResult? _uploadedFile;
  final FirebaseAuth _auth = FirebaseAuthService.instance.auth;

  Future<void> generateAssignmentContent() async {
    if (_topicController.text.isEmpty || _totalMarksController.text.isEmpty) {
      return;
    }
    if (_isGenerated) return;

    setState(() {
      _isLoading = true;
    });

    const String apiKey = 'AIzaSyAJXG8t0QaODio6R_RJXM-x_dgBNR8GJao';
    final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
    int totalMarks = int.parse(_totalMarksController.text);

    try {
      final content = [
        Content.text(
            'Create an assignment worth $totalMarks marks on ${_topicController.text}. Assignment should in the form of question with guidelines')
      ];
      final response = await model.generateContent(content);

      setState(() {
        _generatedAssignment = response.text!;
        _isGenerated = true;
      });

      // Save the generated assignment to Firestore
      await FirebaseFirestore.instance.collection('mockAssignments').add({
        'topic': _topicController.text,
        'totalMarks': totalMarks,
        'assignmentContent': _generatedAssignment,
        'isSolved': false, // Mark the assignment as unsolved initially
        'userId': _auth.currentUser!.uid,
      });

    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to generate content: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _uploadAndEvaluatePDF() async {
    if (_uploadedFile == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Load the PDF and extract text
      final pdfFile = File(_uploadedFile!.files.single.path!);
      final pdfText = await extractTextFromPDF(pdfFile);

      // Call AI to evaluate text and assign marks
      int totalMarks = int.parse(_totalMarksController.text);
      if(totalMarks<0){
        totalMarks=10;
      }
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: 'AIzaSyAJXG8t0QaODio6R_RJXM-x_dgBNR8GJao');
      final content = [
        Content.text(
            'The topic of assignment is $_generatedAssignment.\n Evaluate with brutal honesty the following text for an assignment worth $totalMarks marks, just return marks(i.e: 8), dont give any explanation or reason:\n$pdfText')
      ];
      print('contentssssss $_generatedAssignment');
      final response = await model.generateContent(content);
      print (response.text);
      final grade = int.parse(response.text!.replaceAll(RegExp(r'[^0-9]'), ''));

      // Save to Firestore
      await FirebaseFirestore.instance.collection('assignments').add({
        'topic': _topicController.text,
        'totalMarks': totalMarks,
        'grade': grade,
        'assignmentContent': _generatedAssignment,
        'uploadedText': pdfText,
        'timestamp': Timestamp.now(),
        'userId': _auth.currentUser!.uid,
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Assignment Grade'),
          content: Text('You scored $grade out of $totalMarks'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to evaluate PDF: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String> extractTextFromPDF(File pdfFile) async {
    try {
      // Open the PDF document
      final doc = await PDFDoc.fromFile(pdfFile);

      // Extract text from each page
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Create Assignment'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.grade),
            onPressed: () {
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _topicController,
              decoration: const InputDecoration(
                labelText: 'Topic',
                floatingLabelStyle: TextStyle(color: Color(0xFF6E1993)),
              ),
              enabled: !_isGenerated,
              style: GoogleFonts.poppins(),
            ),
            TextField(
              controller: _totalMarksController,
              decoration: const InputDecoration(
                labelText: 'Total Marks',
                floatingLabelStyle: TextStyle(color: Color(0xFF6E1993)),
              ),
              keyboardType: TextInputType.number,
              enabled: !_isGenerated,
              style: GoogleFonts.poppins(),
            ),
            SizedBox(height:10),
            ElevatedButton(
              onPressed: !_isLoading && !_isGenerated ? generateAssignmentContent : null,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text(
                'Generate Assignment Content',
                style: TextStyle(color: Color(0xFF6E1993)),
              ),
            ),
            const SizedBox(height: 20),
            if (_generatedAssignment != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    _generatedAssignment!,
                    style: GoogleFonts.poppins(),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: !_isGenerated
                  ? null
                  : () async {
                final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
                setState(() {
                  _uploadedFile = result;
                });
                if (result != null) {
                  await _uploadAndEvaluatePDF();
                }
              },
              child: const Text(
                'Upload PDF and Evaluate',
                style: TextStyle(color: Color(0xFF6E1993)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ViewUnsolvedAssignments(),
                  ),
                );
              },
              child: const Text('View Unsolved Assignments'),
            ),
          ],
        ),
      ),
    );
  }
}
