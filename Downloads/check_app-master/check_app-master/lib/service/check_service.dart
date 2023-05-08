import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CheckSerivce with ChangeNotifier {
  bool isCheck = false;
  List<Map<String, dynamic>> checks = [];

  Future isExists(String uid) async {
    var now = DateTime.now();
    var start = DateTime(now.year, now.month, now.day, 0, 0, 0);
    var end = DateTime(now.year, now.month, now.day, 23, 59, 59);

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("today")
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThanOrEqualTo: end)
        .where('uid', isEqualTo: uid)
        .get();

    if (snapshot.docs.isNotEmpty) {
      isCheck = true;
    } else {
      isCheck = false;
    }

    notifyListeners();
  }

  void check(String uid) async {
    await isExists(uid);

    if (isCheck == true) {
      print("이미 체크했습니다.");
      return;
    } else {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("users")
          .where("uid", isEqualTo: uid)
          .get();

      String? profile_image = snapshot.docs[0].get("profile_image");
      String name = snapshot.docs[0].get("name");

      await FirebaseFirestore.instance.collection("today").add({
        "name": name,
        "profile_image": profile_image,
        "uid": uid,
        "date": DateTime.now()
      });

      isCheck = true;
      notifyListeners();
    }
  }

  Future<QuerySnapshot> getChecks() async {
    var now = DateTime.now();
    var start = DateTime(now.year, now.month, now.day, 0, 0, 0);
    var end = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return FirebaseFirestore.instance
        .collection("today")
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThanOrEqualTo: end)
        .get();
  }
}
