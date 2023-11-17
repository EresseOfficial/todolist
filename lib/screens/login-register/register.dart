import 'package:flutter/material.dart';
import 'package:todo_list/screens/login-register/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo_list/screens/login-register/verify.dart';
import 'package:todo_list/screens/todolist/todolist.dart';
import 'package:todo_list/colors.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  // Password strength regex pattern
  final RegExp passwordStrengthRegex = RegExp(
    r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#$%^&*()_+{}|:;<>,.?/~]).{8,}$',
  );

  Future<void> _registerUser() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Create a user with email and password
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
          email: _emailController.text, password: _passwordController.text);

      // Get the user ID
      String userId = userCredential.user?.uid ?? '';

      // Send a verification email to the user
      await userCredential.user?.sendEmailVerification();

      // Store additional user data in Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'email': _emailController.text,
        // Add other user data fields here
      });

      // Registration successful, navigate to the verification screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Verify()),
      );

      // Add a log statement here
      print('Registration successful for user ID: $userId');
    } catch (e) {
      print('Error during registration: $e');
      String errorMessage = 'An error occurred during registration.';

      if (e is FirebaseAuthException) {
        if (e.code == 'email-already-in-use') {
          errorMessage = 'Email already exists. Do you want to log in instead?';
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Email Already Exists'),
                content: Text(errorMessage),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => Login()),
                      );
                    },
                    child: Text('Log in'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Text('Cancel'),
                  ),
                ],
              );
            },
          );
        }
      }

      setState(() {
        _errorMessage = errorMessage;
        _isLoading = false;
      });
      print('Registration failed: $errorMessage');
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an e-mail address';
    }
    if (!RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$').hasMatch(value)) {
      return 'Please enter a valid e-mail address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!passwordStrengthRegex.hasMatch(value)) {
      return 'Password must contain at least one uppercase letter, one lowercase letter, one digit, and one special character.';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Register"),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: ColorConstants.red),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "E-mail",
                  border: OutlineInputBorder(),
                ),
                style: TextStyle(fontSize: 16),
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                style: TextStyle(fontSize: 16),
                obscureText: _obscurePassword,
                validator: _validatePassword,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: "Confirm password",
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                style: TextStyle(fontSize: 16),
                obscureText: _obscureConfirmPassword,
                validator: _validateConfirmPassword,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (!_isLoading) {
                  if (_formKey.currentState!.validate()) {
                    _registerUser(); // Call the registration method
                  }
                }
              },
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Text("Register"),
              style: ButtonStyle(
                padding: MaterialStateProperty.all(
                  EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => Login()),
                );
              },
              child: Text("Have an account?"),
            ),
          ],
        ),
      ),
    );
  }
}
