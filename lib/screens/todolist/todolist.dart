import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TodoList extends StatefulWidget {
  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference usersCollection =
  FirebaseFirestore.instance.collection('users');

  TextEditingController taskController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    if (user == null) {
      // Handle the case where the user is not logged in.
      return Scaffold(
        appBar: AppBar(
          title: Text("Todo List"),
          centerTitle: true,
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
                          .add({'taskName': taskController.text});
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

                List<String> tasks = snapshot.data!.docs
                    .map((doc) => doc['taskName'].toString())
                    .toList();

                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(tasks[index]),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          // Delete the task from Firestore
                          usersCollection
                              .doc(user.uid)
                              .collection('tasks')
                              .where('taskName', isEqualTo: tasks[index])
                              .get()
                              .then((querySnapshot) {
                            querySnapshot.docs.first.reference.delete();
                          });
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
