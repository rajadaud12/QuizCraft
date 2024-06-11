import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:quizcraft/pages/mainscreen.dart';
import 'FirebaseAuthorizationSingleton.dart';
import 'pages/SignInPage.dart';
import 'pages/SignUpPage.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyCMoM_dKZpnncbk2i6uaQJygM3TkPjS5_E',
        appId: '1:732506664299:android:077e94a3ddf5eec74e702e',
        messagingSenderId: '732506664299',
        projectId: 'quizcraft-e3df3',
        storageBucket: 'quizcraft-e3df3.appspot.com',
      )
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final FirebaseAuth _auth = FirebaseAuthService.instance.auth;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      home: _auth.currentUser == null ? SignInPage() : MainScreen(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (context) => SignInPage());
          case '/signUp':
            return MaterialPageRoute(builder: (context) => SignUpPage());
          case '/main':
            return MaterialPageRoute(builder: (context) => MainScreen());
          default:
            return null;
        }
      },
    );
  }
}

