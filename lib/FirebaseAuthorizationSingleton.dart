import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthService {
  FirebaseAuthService._privateConstructor();
  static final FirebaseAuthService _instance = FirebaseAuthService._privateConstructor();

  static FirebaseAuthService get instance => _instance;

  final FirebaseAuth auth = FirebaseAuth.instance;
}

class FirestoreService {
  FirestoreService._privateConstructor();

  static final FirestoreService _instance = FirestoreService._privateConstructor();

  static FirestoreService get instance => _instance;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
}
