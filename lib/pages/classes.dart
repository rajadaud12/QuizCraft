import 'package:flutter/material.dart';

class ClassesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
            body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.class_,
                size: 100,
                color: Colors.purple,
              ),
              SizedBox(height: 20),
              Text(
                'You are not enrolled in a class',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return EnrollDialog();
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Enroll in a Class',
                  style: TextStyle(fontSize: 18,color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EnrollDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TextEditingController classCodeController = TextEditingController();

    return AlertDialog(
      title: Text('Enter Class Code'),
      content: TextField(
        controller: classCodeController,
        decoration: InputDecoration(
          hintText: 'Class Code',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Handle the class code submission logic here
            String classCode = classCodeController.text;
            print("Entered class code: $classCode");
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
          ),
          child: Text('Submit',style: TextStyle(color: Colors.white),),
        ),
      ],
    );
  }
}
