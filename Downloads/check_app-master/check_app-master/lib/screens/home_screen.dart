import 'package:check/service/check_service.dart';
import 'package:check/service/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    User? user = context.watch<UserService>().user();
    if (user != null) {
      context.read<CheckSerivce>().isExists(user!.uid);
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("체육관 명"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            Row(
              children: [
                RichText(
                  text: const TextSpan(
                    text: "오늘 참석",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 18,
                    ),
                    children: [
                      TextSpan(
                        text: " 하실 건가요?",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                        ),
                      )
                    ],
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    if (user != null) {
                      context.read<CheckSerivce>().check(user.uid);
                    }
                  },
                  child: Text(
                      context.watch<CheckSerivce>().isCheck ? "출석완료" : "출석하기"),
                )
              ],
            ),
            Expanded(
              child: FutureBuilder<QuerySnapshot>(
                future: context.watch<CheckSerivce>().getChecks(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var itemCount =
                        (snapshot.data!.docs.length % 8).toInt() != 0
                            ? (snapshot.data!.docs.length / 8).toInt() + 1
                            : (snapshot.data!.docs.length / 8).toInt();

                    return Stack(
                      children: [
                        PageView.builder(
                          itemCount: itemCount,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return GridView.builder(
                              itemCount: 8,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4),
                              itemBuilder: (context, index) {
                                if (snapshot.data!.docs.length >
                                    index + 8 * currentPage) {
                                  String name =
                                      snapshot.data?.docs[index].get("name");
                                  String? profileImg = snapshot
                                      .data?.docs[index]
                                      .get("profile_image");
                                  return Column(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: SizedBox(
                                          width: 50,
                                          height: 50,
                                          child: profileImg != null
                                              ? Image.network(
                                                  profileImg,
                                                  fit: BoxFit.cover,
                                                )
                                              : Image.asset(
                                                  "assets/image/user.png",
                                                  fit: BoxFit.cover,
                                                ),
                                        ),
                                      ),
                                      Text(name)
                                    ],
                                  );
                                }
                              },
                            );
                          },
                          onPageChanged: (index) {
                            setState(() {
                              currentPage = index;
                            });
                          },
                        ),
                        if (snapshot.data!.docs.length > 0)
                          Positioned(
                            bottom: 10,
                            left: 0,
                            right: 0,
                            child: DotsIndicator(
                              dotsCount: itemCount,
                              decorator: const DotsDecorator(
                                size: Size.square(6),
                                activeColor: Colors.amber,
                                activeSize: Size.square(8),
                                color: Colors.grey,
                              ),
                              position: currentPage,
                            ),
                          )
                      ],
                    );
                  } else {
                    return const Text("아무도 출석하지 않았습니다.");
                  }
                },
              ),
            ),
            const SizedBox(height: 10),
            Expanded(child: Text("기능2"))
          ],
        ),
      ),
    );
  }
}
