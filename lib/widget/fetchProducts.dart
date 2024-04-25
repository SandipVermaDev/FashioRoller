import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_roller/screen/show_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget fetchData(String collectionName) {
  return StreamBuilder(
    stream: FirebaseFirestore.instance
        .collection(collectionName)
        .doc(FirebaseAuth.instance.currentUser!.email)
        .collection("items")
        .snapshots(),
    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
      if (snapshot.hasError) {
        return Center(
          child: Text("Something is wrong"),
        );
      }

      return ListView.builder(
        itemCount: snapshot.data == null ? 0 : snapshot.data!.docs.length,
        itemBuilder: (_, index) {
          DocumentSnapshot _documentSnapshot = snapshot.data!.docs[index];

          return Card(
            elevation: 5,
            child: ListTile(
              leading: GestureDetector(
                onTap: () {
                  showImageDialog(context,collectionName, _documentSnapshot.id);
                },
                child: Image.network(
                  _documentSnapshot['images'],
                  width: 50,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(_documentSnapshot['name']),
              subtitle: Text(
                "Rs : ${_documentSnapshot['price']}/-",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              trailing: GestureDetector(
                child: CircleAvatar(
                  child: Icon(
                    Icons.remove_circle,
                    color: Colors.orangeAccent.shade100,
                  ),
                ),
                onTap: () {
                  FirebaseFirestore.instance
                      .collection(collectionName)
                      .doc(FirebaseAuth.instance.currentUser!.email)
                      .collection("items")
                      .doc(_documentSnapshot.id)
                      .delete();
                },
              ),
            ),
          );
        },
      );
    },
  );
}