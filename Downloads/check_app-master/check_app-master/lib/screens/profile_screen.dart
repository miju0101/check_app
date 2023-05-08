import 'dart:io';
import 'package:check/screens/login_screen.dart';
import 'package:check/service/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  XFile? file;

  @override
  Widget build(BuildContext context) {
    User? user = context.watch<UserService>().user();
    if (user != null) {
      context.read<UserService>().getUserInfo(user!.uid);
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: InkWell(
                  onTap: () async {
                    file = await ImagePicker()
                        .pickImage(source: ImageSource.gallery);
                    if (file != null) {
                      context.read<UserService>().changeImage(user!.uid, file!);
                    }
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: SizedBox(
                      height: 50,
                      width: 50,
                      child: context.watch<UserService>().profile_image != null
                          ? Image.network(
                              context.watch<UserService>().profile_image!,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              "assets/image/user.png",
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),
                title: Text(context.watch<UserService>().name ?? ""),
                subtitle: const Text(""),
              ),
              const Divider(),
              Column(
                children: [
                  TextButton(
                    onPressed: () {
                      context.read<UserService>().signOut();
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()));
                    },
                    child: const Text("로그아웃"),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      "탈퇴하기",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
