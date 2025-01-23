import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'pages/sign_in_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Herd',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SignInPage(),
    );
  }
}
