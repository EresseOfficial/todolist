import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_list/screens/todolist/todolist.dart';
import 'package:todo_list/screens/login-register/login.dart';
import 'package:todo_list/screens/login-register/verify_successful.dart'; // Import your successful page

class Verify extends StatefulWidget {
  @override
  _VerifyState createState() => _VerifyState();
}

class _VerifyState extends State<Verify> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    // Refresh the user data to check if the email is verified
    user?.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Verify Email"),
      ),
      body: FutureBuilder(
        future: user?.reload(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Still loading, show a loading indicator or some message
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (user != null && user!.emailVerified) {
            // Email is verified, display the "Continue" button
            return _buildEmailVerified(context);
          } else {
            // Email is not verified, display the verification options
            return _buildVerificationOptions(context);
          }
        },
      ),
    );
  }

  Widget _buildVerificationOptions(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.warning,
            color: Colors.orange,
            size: 100,
          ),
          Text(
            'Email Not Verified',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Please check your email and verify your account.',
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Send a verification email again
              user?.sendEmailVerification();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Verification email sent again.'),
                ),
              );
            },
            child: Text('Resend Verification Email'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // You can log out the user if needed
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Login()),
              );
            },
            child: Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailVerified(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 100,
          ),
          Text(
            'Email Verified!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Navigate to the VerifySuccessful screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => VerifySuccessful()),
              );
            },
            child: Text('Continue'),
          ),
        ],
      ),
    );
  }
}
