import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase/screens/home.dart';
import 'package:flutter_firebase/screens/login.dart';

//สร้างฟังก์ชันสำหรับดึงข้อมูล user login จาก firebase
final _auth = FirebaseAuth.instance;

void main() async {
//ต้องใส่อันนี้เสมอถ้าต้องการทำ async ที่ method main
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  //set min sdk 21

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      //obj currentUser ไม่มีทางเป็น null แต่
      home: _auth.currentUser != null ? HomeScreen() : LoginScreen(),
    );
  }
}
