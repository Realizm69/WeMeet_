import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wemeet/screens/auth/register_screen.dart';
import 'package:wemeet/screens/home/home.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
String? error;
  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    return GestureDetector( 
      onTap: () {FocusManager.instance.primaryFocus?.unfocus();},
      child: Scaffold(
      body: SafeArea( 
        child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("WeMeet", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue)),
            SizedBox(height: 4),
            Text("우리가 만나는 날", style: TextStyle(fontSize: 14, color: Colors.grey)),
            SizedBox(height: 40),

            TextField(
              controller: emailController,
              obscureText: false,
              decoration: InputDecoration(hintText: "Email", 
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black))
              ),
            ),
            SizedBox(height: 16),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(hintText: "Password", border: OutlineInputBorder() ,
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color : Colors.black))),
            ),
            SizedBox(height: 24),

            ElevatedButton(
              onPressed: () async {
                if (error != null) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => 
                    Container(
                      height: 50,
                      width: 100,
                      margin: EdgeInsets.symmetric(vertical: 20 ),
                      child:  AlertDialog(
                    backgroundColor: Colors.white,
                  title:  Text(
                     error!,
                style: const TextStyle(color: Colors.black , fontSize: 20)
                  )
              ),
                    )
            );
                }
                String email = emailController.text;
                String password = passwordController.text;
                if (email.isEmpty || password.isEmpty ) {
                  setState(() => error = "이메일과 비밀번호를 입력해주세요.");
                }
                try{
                final user = await authService.signIn(email, password);

                if (user != null && context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const Home()),
                    );
                    }
                  } on FirebaseAuthException catch (e) {
                    if (e.code == ' user.not.found') {
                    setState(()=> error = '등록되지 않은 계정입니다.' ,);
                    } else if (e.code == 'wrong-password') {
                      setState(() => error = '비밀번호가 틀렸습니다.');
                    } else if (e.code == 'user-not-found-in-firestore') {
                      setState(() => error = '회원가입 정보가 존재하지 않습니다.');
                    } 
                  } catch(e) {
                    setState(() => error = '일수 없는 오류가 발생했습니다.');
                  }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, padding: EdgeInsets.symmetric(vertical: 12, horizontal: 100)),
              child: Text("Sign In", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
            SizedBox(height: 20),

            

            Text("아이디가 없으신가요?", style: TextStyle(fontSize: 14)),
            SizedBox(height: 5,),
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUpScreen())
                );// 회원가입 화면으로 이동 (다음 단계에서 추가)
              },
              style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 12, horizontal: 80)),
              child: Text("회원가입", style: TextStyle(fontSize: 16 , color: Colors.black)),
            ),
          ],
        ),
      ),
    )
      )
      );
  }
}

