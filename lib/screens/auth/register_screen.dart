import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wemeet/screens/auth/login_screen.dart';
import '../../services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});


  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordCheckController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  String? error;

  @override
  Widget build(BuildContext context) {
      final authService = context.read<AuthService>();

      return GestureDetector( onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      }, child: Scaffold(
        resizeToAvoidBottomInset: false,
        body:  SafeArea(
          child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            SizedBox(height: 60),
            Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [Text("회원가입", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black)),]
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: usernameController,
              decoration: const InputDecoration(
                hintText: 'Username',
                prefixIcon: Icon(Icons.person , color: Colors.blue,),
                fillColor: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 10),

            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                hintText: 'Email',
                prefixIcon: Icon(Icons.email , color: Colors.blue,)
              ),
            ),
            SizedBox(height: 10),

            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Password',
                prefixIcon: Icon(Icons.password_rounded , color: Colors.blue,)
              ),
            ),
            SizedBox(height: 10),

            TextFormField(
              controller: passwordCheckController,
              obscureText: true,
              decoration:  InputDecoration(
                hintText: 'Write your password again',
                prefixIcon: Icon(Icons.password_sharp , color: Colors.blue,)
              ),
            ),
            SizedBox(height: 10),

            TextFormField(
              controller: phoneController,
              decoration:  InputDecoration(
                hintText: 'Phone number',
                prefixIcon: Icon(Icons.phone , color: Colors.blue,)
              ),
            ),
            
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async{
                if (error != null) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                    backgroundColor: Colors.white,
                  title:  Text(
                     error!,
                style: const TextStyle(color: Colors.black , fontSize: 25)
                  )
              ),
            );
                }
                String username = usernameController.text.trim();
                String email = emailController.text.trim();
                String password = passwordController.text.trim();
                String passwordCheck = passwordCheckController.text.trim();
                String phone = phoneController.text.trim();
                String defaultProfileImageUrl = 'https://i.pravatar.cc/150?img=3';

                if (password != passwordCheck) {
                  setState(() => error = "비밀번호가 일치하지 않아요");
                  return;
                }
                if (email.isEmpty || password.isEmpty || passwordCheck.isEmpty) {
                  setState(() => error = "모든 필드를 입력해주세요.");
                  return;
                }


                try {
                  await authService.signUp(email, password , username ,phone , defaultProfileImageUrl );
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  log("회원가입 실패 이유: $e");
                  setState(() => error = "회원가입 실패");
                }

              },
                    style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shadowColor: Colors.blueGrey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                ),
              child: Text("Sign In", style: TextStyle(color: Colors.white, fontSize: 16)),
             ),
            SizedBox(height: 32),
            Text('계정이 있으신가요?' , style: TextStyle(fontSize: 10 , color: Colors.black )),
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen())
                );
              },
              style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 12, horizontal: 80)),
              child: Text("로그인", style: TextStyle(fontSize: 14 , color: Colors.black))
              ),
            ]
        )
      )
        )
    ),
      );
      
  }
}
