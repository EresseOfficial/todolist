import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo_list/screens/login-register/login.dart';
import 'package:todo_list/screens/login-register/verify_successful.dart';

class Verify extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<bool> checkEmailVerificationStream() async* {
    User? user = _auth.currentUser;
    await for (var _ in Stream.periodic(Duration(seconds: 1))) {
      await user?.reload();
      user = _auth.currentUser;
      yield user?.emailVerified ?? false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Verify Email"),
      ),
      body: StreamBuilder<bool>(
        stream: checkEmailVerificationStream(),
        builder: (context, snapshot) {
          if (snapshot.data == true) {
            return VerifySuccessful();
          } else {
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
              _auth.currentUser?.sendEmailVerification();
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
              _auth.signOut();
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
}
