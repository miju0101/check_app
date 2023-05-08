import 'package:check/service/user_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController name = TextEditingController();
    TextEditingController email = TextEditingController();
    TextEditingController password = TextEditingController();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("회원가입"),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("*이름"),
            TextField(
              controller: name,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "이름을 입력하세요",
              ),
            ),
            const SizedBox(height: 10),
            const Text("*이메일"),
            TextField(
              controller: email,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "ex)honggildong@email.com",
              ),
            ),
            const SizedBox(height: 10),
            const Text("*비밀번호"),
            TextField(
              controller: password,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "비밀번호를 입력하세요",
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: ElevatedButton(
        onPressed: () {
          context.read<UserService>().singup(
                name: name.text,
                email: email.text,
                password: password.text,
                onSuccess: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("회원가입 성공"),
                    ),
                  );
                  Navigator.pop(context);
                },
              );
        },
        child: const Text("회원가입"),
        style: ElevatedButton.styleFrom(
          shape: const BeveledRectangleBorder(),
        ),
      ),
    );
  }
}
