import 'package:flutter/material.dart';
import 'package:todo_list/screens/todolist/todolist.dart';
import 'package:todo_list/colors.dart';

class VerifySuccessful extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Email Verified"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.check_circle,
              color: ColorConstants.green,
              size: 100,
            ),
            Text(
              'Your account is ready to use!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to the TodoList screen or any other screen
                Navigator.pushReplacementNamed(context, '/todolist');
              },
              child: Text('Finish'),
            ),
          ],
        ),
      ),
    );
  }
}
