import 'package:flutter/material.dart';
import 'package:todo_list/screens/todolist/todolist.dart';

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
                // Navigate to the TodoList screen or any other screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => TodoList()),
                );
              },
              child: Text('Finish'),
            ),
          ],
        ),
      ),
    );
  }
}
