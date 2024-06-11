import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../FirebaseAuthorizationSingleton.dart';



class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuthService.instance.auth;
  final FirebaseFirestore _firestore = FirestoreService.instance.firestore;

  Future<void> _signUp() async {
    try {
      if (_passwordController.text != _confirmPasswordController.text) {
        _showSnackBar('Passwords do not match');
        return;
      }

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await userCredential.user?.updateDisplayName(_fullNameController.text.trim());

      await _saveUserData(userCredential);

      _showSnackBar('Sign up successful!');
      Navigator.pushNamed(context, '/');
    } on FirebaseAuthException catch (e) {
      _handleFirebaseAuthError(e);
    } catch (e) {
      _showSnackBar('An unknown error occurred. Please try again.');
    }
  }

  Future<void> _saveUserData(UserCredential userCredential) async {
    try {
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'fullName': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'quizzesDue':0,
        'assignmentsDue':0,
        'Classes Enrolled':0,
      });
    } catch (e) {
      _showSnackBar('An error occurred while saving user data. Please try again.');
    }
  }

  void _handleFirebaseAuthError(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'weak-password':
        message = 'The password provided is too weak.';
        break;
      case 'email-already-in-use':
        message = 'The account already exists for that email.';
        break;
      case 'invalid-email':
        message = 'The email address is not valid.';
        break;
      case 'operation-not-allowed':
        message = 'Email/password accounts are not enabled.';
        break;
      default:
        message = 'An error occurred. Please try again.';
    }
    _showSnackBar(message);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                Image.asset(
                  'assets/images/Logo.png',
                  height: 200,
                ),
                const SizedBox(height: 20),
                _buildTitle(),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _fullNameController,
                  icon: Icons.person_outline,
                  labelText: 'Full Name',
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _emailController,
                  icon: Icons.email_outlined,
                  labelText: 'Email',
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _passwordController,
                  icon: Icons.lock_outline,
                  labelText: 'Password',
                  obscureText: true,
                  suffixIcon: Icons.visibility,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _confirmPasswordController,
                  icon: Icons.lock_outline,
                  labelText: 'Confirm Password',
                  obscureText: true,
                  suffixIcon: Icons.visibility,
                ),
                const SizedBox(height: 20),
                _buildSignUpButton(),
                const SizedBox(height: 20),
                _buildOrSignUpWithText(),
                const SizedBox(height: 20),
                _buildSocialIcons(),
                const SizedBox(height: 20),
                _buildSignInText(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'Sign Up',
        style: GoogleFonts.poppins(
          fontSize: 30,
          fontWeight: FontWeight.w500,
          color: Color(0xFF6E1993),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String labelText,
    bool obscureText = false,
    IconData? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Color(0xFF6E1993)),
        labelText: labelText,
        labelStyle: GoogleFonts.poppins(color: Colors.black),
        floatingLabelStyle: GoogleFonts.poppins(color: Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF6E1993)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF6E1993)),
        ),
        suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: Color(0xFF6E1993)) : null,
      ),
    );
  }

  Widget _buildSignUpButton() {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Color(0xFF6E1993),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: _signUp,
        child: Text(
          'Sign Up',
          style: GoogleFonts.poppins(),
        ),
      ),
    );
  }

  Widget _buildOrSignUpWithText() {
    return Text(
      'Or sign up with',
      style: GoogleFonts.poppins(),
    );
  }

  Widget _buildSocialIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialIconButton(FontAwesomeIcons.google, () {}),
        const SizedBox(width: 10),
        _buildSocialIconButton(FontAwesomeIcons.facebook, () {}),
        const SizedBox(width: 10),
        _buildSocialIconButton(FontAwesomeIcons.twitter, () {}),
        const SizedBox(width: 10),
        _buildSocialIconButton(FontAwesomeIcons.linkedin, () {}),
      ],
    );
  }

  Widget _buildSocialIconButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: IconButton(
        icon: FaIcon(icon, color: Color(0xFF6E1993)),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildSignInText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account? ",
          style: GoogleFonts.poppins(),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            'Sign In',
            style: GoogleFonts.poppins(color:Color(0xFF6E1993)),
          ),
        ),
      ],
    );
  }
}
