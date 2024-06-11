import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:google_fonts/google_fonts.dart';

import 'FirebaseAuthorizationSingleton.dart';
import 'GradesOverview.dart';

class MockQuizCreation extends StatefulWidget {
  const MockQuizCreation({super.key});

  @override
  _MockQuizCreationState createState() => _MockQuizCreationState();
}

class _MockQuizCreationState extends State<MockQuizCreation> {
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _totalMarksController = TextEditingController();
  bool isMCQ = true;
  List<Map<String, dynamic>> _quizContent = [];
  List<String> _selectedAnswers = [];
  bool _isLoading = false;
  bool _isSubmitted = false;
  bool _isGenerated = false;  // New variable to track if quiz has been generated
  final PageController _pageController = PageController();
  List<String> _correctAnswers = [];
  final FirebaseAuth _auth = FirebaseAuthService.instance.auth;

  Future<void> generateQuizContent() async {
    if (_isSubmitted) return; // Prevent generating new quiz if already submitted

    setState(() {
      _isLoading = true;
    });

    const String apiKey = 'AIzaSyAJXG8t0QaODio6R_RJXM-x_dgBNR8GJao';
    final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
    int totalMarks = int.parse(_totalMarksController.text);

    try {
      final content = [
        Content.text(
            'Create $totalMarks multiple MCQs on ${_topicController.text} each with 4 options. Format each question as follows:\nQuestion text\na) Option 1\nb) Option 2\nc) Option 3\nd) Option 4\nAnswer: [Correct Option]')
      ];

      // Start a timer to check for slow internet
      Future.delayed(Duration(seconds: 5), () {
        if (_isLoading) {
          setState(() {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Internet is slow, please wait...'),
              ),
            );
          });
        }
      });

      final response = await model.generateContent(content);

      // Log the response text
      print('Response text: ${response.text!}');

      setState(() {
        _quizContent = parseQuizContent(response.text!);
        if (_quizContent.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('An error occurred while generating the quiz. Please try again.'),
            ),
          );
          _isLoading = false;
          return;
        }
        _selectedAnswers = List<String>.filled(_quizContent.length, '');
        _correctAnswers = _quizContent.map((q) => q['correctAnswer'] as String).toList();
        _isGenerated = true; // Quiz has been generated
      });
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate content: $e'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> parseQuizContent(String responseText) {
    List<Map<String, dynamic>> quizContent = [];
    List<String> questions = responseText.split('\n\n');

    for (String questionBlock in questions) {
      List<String> parts = questionBlock.split('\n');
      if (parts.length >= 6) { // Ensure we have at least 1 question, 4 options, and 1 correct answer
        quizContent.add({
          'question': parts[0],
          'options': [
            parts[1].replaceAll(RegExp(r'^\s*[a-d]\)\s*'), '').trim(),
            parts[2].replaceAll(RegExp(r'^\s*[a-d]\)\s*'), '').trim(),
            parts[3].replaceAll(RegExp(r'^\s*[a-d]\)\s*'), '').trim(),
            parts[4].replaceAll(RegExp(r'^\s*[a-d]\)\s*'), '').trim(),
          ],
          'correctAnswer': parts[5].replaceFirst(RegExp(r'^\s*Answer:\s*'), '').trim(),
        });
      } else {
        print('Invalid question format: $parts');
      }
    }
    return quizContent;
  }

  Future<void> _submitAnswers() async {
    if (_isSubmitted) return; // Prevent re-submission

    int correctAnswers = 0;
    for (int i = 0; i < _quizContent.length; i++) {
      String selectedAnswer = _selectedAnswers[i].trim().toLowerCase();
      String correctAnswer = _quizContent[i]['correctAnswer'][10].toLowerCase();

      if (selectedAnswer == correctAnswer) {
        correctAnswers++;
      }
    }
    int totalMarks = int.parse(_totalMarksController.text);
    int grade = (correctAnswers / _quizContent.length * totalMarks).round();

    setState(() {
      _isSubmitted = true;
    });

    // Save to Firestore
    await FirebaseFirestore.instance.collection('quizzes').add({
      'topic': _topicController.text,
      'totalMarks': totalMarks,
      'grade': grade,
      'quizContent': _quizContent,
      'selectedAnswers': _selectedAnswers,
      'correctAnswers': _correctAnswers,
      'timestamp': Timestamp.now(),
      'userId': _auth.currentUser!.uid,
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Your Grade'),
        content: Text('You scored $grade out of $totalMarks'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    ).then((_) {
      // Show summary page after showing the grade
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuizSummaryPage(
            quizContent: _quizContent,
            selectedAnswers: _selectedAnswers,
            correctAnswers: _correctAnswers,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Create Mock Quiz'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.grade),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ViewGradesQuiz(),
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
              decoration: const InputDecoration(labelText: 'Topic', floatingLabelStyle: TextStyle(color: Color(0xFF6E1993))),
              enabled: !_isGenerated, // Disable if quiz is generated
              style: GoogleFonts.poppins(),
            ),
            TextField(
              controller: _totalMarksController,
              decoration: const InputDecoration(labelText: 'Total Marks', floatingLabelStyle: TextStyle(color: Color(0xFF6E1993))),
              keyboardType: TextInputType.number,
              enabled: !_isGenerated, // Disable if quiz is generated
              style: GoogleFonts.poppins(),
            ),
            SwitchListTile(
              title: Text('MCQ', style: GoogleFonts.poppins()),
              activeTrackColor: const Color(0xFF6E1993),
              value: isMCQ,
              onChanged: !_isGenerated
                  ? (bool value) {
                setState(() {
                  isMCQ = value;
                });
              }
                  : null, // Disable if quiz is generated
            ),
            ElevatedButton(
              onPressed: !_isLoading && !_isSubmitted && !_isGenerated ? generateQuizContent : null,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text(
                'Generate Quiz Content',
                style: TextStyle(color: Color(0xFF6E1993)), // Text color
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _quizContent.isNotEmpty
                  ? PageView.builder(
                controller: _pageController,
                itemCount: _quizContent.length,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return SingleChildScrollView(
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      color: Colors.white,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _quizContent[index]['question'],
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                            ),
                            Column(
                              children: [
                                for (int optionIndex = 0; optionIndex < 4; optionIndex++)
                                  RadioListTile<String>(
                                    title: Text(_quizContent[index]['options'][optionIndex]),
                                    value: String.fromCharCode(optionIndex + 65),
                                    groupValue: _selectedAnswers[index],
                                    onChanged: (value) {
                                      if (!_isSubmitted) {
                                        setState(() {
                                          _selectedAnswers[index] = value!;
                                        });
                                      }
                                    },
                                  ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (index > 0)
                                  ElevatedButton(
                                    onPressed: () {
                                      if (!_isSubmitted) {
                                        _pageController.previousPage(
                                          duration: const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                        );
                                      }
                                    },
                                    child: const Text('Previous', style: TextStyle(color: Color(0xFF6E1993))), // Text color
                                  ),
                                if (index < _quizContent.length - 1)
                                  ElevatedButton(
                                    onPressed: () {
                                      if (!_isSubmitted) {
                                        _pageController.nextPage(
                                          duration: const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                        );
                                      }
                                    },
                                    child: const Text('Next', style: TextStyle(color: Color(0xFF6E1993))), // Text color
                                  ),
                                if (index == _quizContent.length - 1)
                                  ElevatedButton(
                                    onPressed: _selectedAnswers.contains('')
                                        ? null
                                        : _submitAnswers,
                                    child: const Text('Submit', style: TextStyle(color: Color(0xFF6E1993))), // Text color
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              )

                  : const Text('No quiz content available'),
            ),
          ],
        ),
      ),
    );
  }
}
class QuizSummaryPage extends StatelessWidget {
  final List<Map<String, dynamic>> quizContent;
  final List<String> selectedAnswers;
  final List<String> correctAnswers;

  const QuizSummaryPage({
    required this.quizContent,
    required this.selectedAnswers,
    required this.correctAnswers,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Quiz Summary'),
      ),
      body: ListView.builder(
        itemCount: quizContent.length,
        itemBuilder: (context, index) {
          return Card(
            color: Colors.white,
            margin: const EdgeInsets.all(10.0),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quizContent[index]['question'],
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  for (int optionIndex = 0; optionIndex < 4; optionIndex++)
                    Text(
                      '${String.fromCharCode(optionIndex + 65)}. ${quizContent[index]['options'][optionIndex]}',
                      style: GoogleFonts.poppins(
                        color: selectedAnswers[index] == String.fromCharCode(optionIndex + 65)
                            ? (selectedAnswers[index] == correctAnswers[index][10].toUpperCase() ? Colors.green : Colors.red)
                            : null,
                        fontWeight: selectedAnswers[index] == String.fromCharCode(optionIndex + 65)
                            ? FontWeight.bold
                            : null,
                      ),
                    ),
                  const SizedBox(height: 10),
                  Text(
                    'Correct Answer: ${correctAnswers[index][10].toUpperCase()}',
                    style: GoogleFonts.poppins(color: Colors.blue),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
