import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo_list/screens/login-register/login.dart';
import 'package:todo_list/colors.dart';


class TodoList extends StatefulWidget {
  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference usersCollection =
  FirebaseFirestore.instance.collection('users');

  TextEditingController taskController = TextEditingController();

  // Function to sign out and navigate to the login page
  Future<void> _signOut() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/auth/login');
  }

  // Function to show a confirmation dialog
  Future<void> _showSignOutConfirmationDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Sign Out"),
          content: Text("Are you sure you want to sign out?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _signOut(); // Sign out the user
              },
              child: Text(
                "Sign Out",
                style: TextStyle(
                  color: ColorConstants.red, // Style the button with red color
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    if (user == null) {
      // Handle the case where the user is not logged in.
      return Scaffold(
        appBar: AppBar(
          title: Text("Todo List"),
          centerTitle: true,
          actions: [
            // Add a Sign Out icon to the app bar
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () {
                _showSignOutConfirmationDialog(); // Show the confirmation dialog
              },
            ),
          ],
        ),
        body: Center(
          child: Text("Please log in to use the Todo List."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Todo List"),
        centerTitle: true,
        actions: [
          // Add a Sign Out icon to the app bar
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              _showSignOutConfirmationDialog(); // Show the confirmation dialog
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: taskController,
                    decoration: InputDecoration(
                      labelText: "Add a new task",
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    // Add the task to Firestore
                    if (taskController.text.isNotEmpty) {
                      usersCollection
                          .doc(user.uid)
                          .collection('tasks')
                          .add({'taskName': taskController.text, 'isDone': false});
                      taskController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: usersCollection.doc(user.uid).collection('tasks').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }

                List<DocumentSnapshot> taskDocs = snapshot.data!.docs;
                List<Widget> taskWidgets = [];

                for (int index = 0; index < taskDocs.length; index++) {
                  DocumentSnapshot taskDoc = taskDocs[index];
                  String taskName = taskDoc['taskName'].toString();
                  bool isDone = taskDoc['isDone'];

                  // Display the task and a checkbox
                  taskWidgets.add(
                    ListTile(
                      title: Text(taskName),
                      trailing: Checkbox(
                        value: isDone,
                        onChanged: (bool? newValue) {
                          // Update the "isDone" field in Firestore
                          taskDoc.reference.update({'isDone': newValue});
                          if (newValue == true) {
                            // Remove the task after 2 seconds
                            Timer(Duration(seconds: 2), () {
                              taskDoc.reference.delete();
                            });
                          }
                        },
                      ),
                    ),
                  );
                }
                return ListView(
                  children: taskWidgets,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
