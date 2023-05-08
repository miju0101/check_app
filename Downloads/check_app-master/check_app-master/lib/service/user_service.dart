import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserService with ChangeNotifier {
  User? user() {
    return FirebaseAuth.instance.currentUser;
  }

  void signOut() async {
    await FirebaseAuth.instance.signOut();
    notifyListeners();
  }

  void singup(
      {required String name,
      required String email,
      required String password,
      required Function() onSuccess}) async {
    if (name.isEmpty) {
      print("이름 미입력");
      return;
    } else if (email.isEmpty) {
      print("이메일 미입력");
      return;
    } else if (password.isEmpty) {
      print("패스워드 미입력");
      return;
    }

    try {
      UserCredential user = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await FirebaseFirestore.instance
          .collection('users')
          .add({"uid": user.user!.uid, "name": name, "profile_image": null});
      onSuccess();
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  void signIn(
      {required String email,
      required String password,
      required Function() onSuccess}) async {
    if (email.isEmpty) {
      return;
    } else if (password.isEmpty) {
      return;
    }
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      onSuccess();
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  void changeImage(String uid, XFile file) {
    var task = uploadXFile(file, '$uid/profile.${file.path.split('.').last}');

    task.snapshotEvents.listen((event) async {
      if (event.bytesTransferred == event.totalBytes &&
          event.state == TaskState.success) {
        var downloadUrl = await event.ref.getDownloadURL();

        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection("users")
            .where("uid", isEqualTo: uid)
            .get();

        var docId = snapshot.docs[0].id;

        await FirebaseFirestore.instance
            .collection("users")
            .doc(docId)
            .update({"profile_image": downloadUrl});

        notifyListeners();
      }
    });
  }

  UploadTask uploadXFile(XFile file, String fileName) {
    var f = File(file.path);
    var ref = FirebaseStorage.instance.ref().child("users").child(fileName);
    final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'picked-file-path': file.path});
    return ref.putFile(f, metadata);
  }

  String? profile_image = null;
  String? name = null;

  void getUserInfo(String? uid) async {
    if (uid == null) {
      return;
    }

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("users")
        .where("uid", isEqualTo: uid)
        .get();

    profile_image = snapshot.docs[0].get("profile_image");
    name = snapshot.docs[0].get("name");

    notifyListeners();
  }
}
