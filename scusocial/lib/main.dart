import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Web Firebase Sign-In',
      home: SignInPage(),
    );
  }
}

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        "922633706004-qmprgr02q0h82p38p31v7ofm3uigj446.apps.googleusercontent.com", // Set the clientId here
  );

  User? _user;

  // Sign in with Google and Firebase
  Future<void> signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User canceled the sign-in
        return;
      }

      // Obtain the GoogleSignInAuthentication
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      setState(() {
        _user = userCredential.user;
      });

      print("Signed in as ${_user?.displayName}");
    } catch (error) {
      print("Google Sign-In error: $error");
    }
  }

  // Sign out from Google and Firebase
  Future<void> signOutGoogle() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    setState(() {
      _user = null;
    });
    print("User signed out");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Google Sign-In with Firebase')),
      body: Center(
        child: _user == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: signInWithGoogle,
                    child: Text('Sign in with Google'),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(_user?.photoURL ?? ""),
                    radius: 40,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Name: ${_user?.displayName}",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Email: ${_user?.email}",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: signOutGoogle,
                    child: Text('Sign out'),
                  ),
                ],
              ),
      ),
    );
  }
}
