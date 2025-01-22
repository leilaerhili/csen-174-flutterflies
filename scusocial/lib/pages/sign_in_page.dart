import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'event_page.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final AuthService _authService = AuthService();
  User? _user;

  Future<void> _signInWithGoogle() async {
    final user = await _authService.signInWithGoogle();
    if (user != null) {
      setState(() {
        _user = user;
      });
    }
  }

  Future<void> _signOut() async {
    await _authService.signOut();
    setState(() {
      _user = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Event Social Media App')),
      body: Center(
        child: _user == null
            ? ElevatedButton(
                onPressed: _signInWithGoogle,
                child: Text('Sign in with Google'),
              )
            : EventPage(user: _user!, signOut: _signOut),
      ),
    );
  }
}
