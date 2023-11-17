import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  final RegExp passwordStrengthRegex = RegExp(
    r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#$%^&*()_+{}|:;<>,.?/~]).{8,}$',
  );

  final ButtonController _buttonController = Get.put(ButtonController());

  Future<void> _registerUser() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
          email: _emailController.text, password: _passwordController.text);

      String userId = userCredential.user?.uid ?? '';

      await userCredential.user?.sendEmailVerification();

      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'email': _emailController.text,
      });

      Navigator.pushReplacementNamed(context, '/auth/verify');

      print('Registration successful for user ID: $userId');
    } catch (e) {
      print('Error during registration: $e');
      String errorMessage = 'An error occurred during registration.';

      if (e is FirebaseAuthException) {
        if (e.code == 'email-already-in-use') {
          errorMessage = 'Email already exists. Do you want to log in instead?';
          // showDialog(
          //   context: context,
          //   builder: (context) {
          //     return AlertDialog(
          //       title: Text('Email Already Exists'),
          //       content: Text(errorMessage),
          //       actions: [
          //         TextButton(
          //           onPressed: () {
          //             Navigator.of(context).pop(); // Close the dialog
          //             Navigator.of(context).pushReplacement(
          //               MaterialPageRoute(builder: (context) => Login()),
          //             );
          //           },
          //           child: Text('Log in'),
          //         ),
          //         TextButton(
          //           onPressed: () {
          //             Navigator.of(context).pop(); // Close the dialog
          //           },
          //           child: Text('Cancel'),
          //         ),
          //       ],
          //     );
          //   },
          // );
          _buttonController.changeToLoginState();
        }
      }

      setState(() {
        _errorMessage = errorMessage;
        _isLoading = false;
      });
      print('Registration failed: $errorMessage');
    }
  }

  Future<void> _loginUser() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      Navigator.pushReplacementNamed(context, '/todolist');

      print('Login successful for user: ${_emailController.text}');
    } catch (e) {
      print('Error during login: $e');
      String errorMessage = 'An error occurred during login.';

      if (e is FirebaseAuthException) {
        if (e.code == 'user-not-found' || e.code == 'wrong-password') {
          errorMessage = 'Invalid email or password. Please try again.';
        }
      }

      setState(() {
        _errorMessage = errorMessage;
        _isLoading = false;
      });
      print('Login failed: $errorMessage');
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
      body: SingleChildScrollView( // Wrap with SingleChildScrollView
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_errorMessage != null)
                Container(
                  constraints: BoxConstraints(
                    minHeight: 40,
                  ),
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
              GetBuilder<ButtonController>(
                builder: (_) {
                  return ElevatedButton(
                    onPressed: () {
                      if (!_isLoading) {
                        if (_formKey.currentState!.validate()) {
                          if (_buttonController.buttonText == "Register") {
                            _registerUser();
                          } else if (_buttonController.buttonText == "Log in") {
                            _loginUser();
                          }
                        }
                      }
                    },
                    child: _isLoading
                        ? CircularProgressIndicator()
                        : Text(_buttonController.buttonText),
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(
                        EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  );
                },
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/auth/login');
                },
                child: Text("Have an account?"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ButtonController extends GetxController {
  RxString _buttonText = "Register".obs;

  String get buttonText => _buttonText.value;

  ButtonController() {
    // Initialize the button text as "Register" when the controller is created.
    _buttonText.value = "Register";
  }

  void changeToLoginState() {
    _buttonText.value = "Log in";
  }
}

