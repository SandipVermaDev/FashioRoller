import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageUsers extends StatefulWidget {
  @override
  _ManageUsersState createState() => _ManageUsersState();
}

class _ManageUsersState extends State<ManageUsers> {
  List<Map<String, dynamic>> users = [];
  String editedName = '';
  String editedAge = '';
  String editedGender = '';
  String editedDob = '';
  String editedPhone = '';


  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> userCollection =
      await FirebaseFirestore.instance.collection('users-form-data').get();

      final List<Map<String, dynamic>> fetchedUsers = userCollection.docs
          .map((DocumentSnapshot<Map<String, dynamic>> doc) {
        final data = doc.data()!;
        data['collectionId'] = doc.id;
        return data;
      })
          .toList();

      setState(() {
        users = fetchedUsers;
      });
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  Future<void> deleteUser(String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users-form-data')
          .doc(documentId)
          .delete();
      fetchData();
    } catch (e) {
      print('Error deleting user: $e');
    }
  }

  Future<void> editUser(String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users-form-data')
          .doc(documentId)
          .update({
        'name': editedName,
        'age': editedAge,
        'gender': editedGender,
        'dob': editedDob,
        'phone': editedPhone,
      });

      fetchData();
    } catch (e) {
      print('Error editing user: $e');
    }
  }

  Future<void> showEditDialog(BuildContext context, String documentId, Map<String, dynamic> userData) async {

    final initialName = userData['name'];
    final initialAge = userData['age'];
    final initialGender = userData['gender'];
    final initialDob = userData['dob'];
    final initialPhone = userData['phone'];


    editedName = initialName ?? '';
    editedAge = initialAge ?? '';
    editedGender = initialGender ?? '';
    editedDob = initialDob ?? '';
    editedPhone = initialPhone ?? '';

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit User Information'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Name'),
                  onChanged: (value) {
                    editedName = value;
                  },
                  initialValue: initialName,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Age'),
                  onChanged: (value) {
                    editedAge = value;
                  },
                  initialValue: initialAge,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Gender'),
                  onChanged: (value) {
                    editedGender = value;
                  },
                  initialValue: initialGender,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'DOB'),
                  onChanged: (value) {
                    editedDob = value;
                  },
                  initialValue: initialDob,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Phone'),
                  onChanged: (value) {
                    editedPhone = value;
                  },
                  initialValue: initialPhone,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                editUser(documentId); // Call the edit function
                Navigator.of(context).pop();
              },
              child: Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Users'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final userData = users[index];
          final documentId = userData['collectionId'];

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              color: Colors.orangeAccent.shade100,
              child: ListTile(
                title: Text('Email: ${userData['collectionId'] ?? 'N/A'}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Name: ${userData['name'] ?? 'N/A'}'),
                    Text('Age: ${userData['age'] ?? 'N/A'}'),
                    Text('Gender: ${userData['gender'] ?? 'N/A'}'),
                    Text('DOB: ${userData['dob'] ?? 'N/A'}'),
                    Text('Phone: ${userData['phone'] ?? 'N/A'}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        showEditDialog(context, documentId, userData);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Confirm Deletion'),
                              content: Text('Are you sure you want to delete this user?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    deleteUser(documentId);
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Delete'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
