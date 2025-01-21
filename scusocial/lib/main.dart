import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      title: 'Persistent Button Counter',
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        "922633706004-qmprgr02q0h82p38p31v7ofm3uigj446.apps.googleusercontent.com", // Set the clientId here
  );

  User? _user;
  int _buttonPressCount = 0;

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

      // Fetch or initialize the button press count
      final userDoc =
          _firestore.collection('users').doc(_user?.uid); // Use user's UID
      final docSnapshot = await userDoc.get();

      if (docSnapshot.exists) {
        setState(() {
          _buttonPressCount = docSnapshot.data()?['buttonPressCount'] ?? 0;
        });
      } else {
        // Initialize the button press count if the user doc doesn't exist
        await userDoc.set({'buttonPressCount': 0});
      }

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
      _buttonPressCount = 0;
    });
    print("User signed out");
  }

  // Increment the button press count and update Firestore
  Future<void> incrementButtonPressCount() async {
    setState(() {
      _buttonPressCount++;
    });

    final userDoc = _firestore.collection('users').doc(_user?.uid);
    await userDoc.update({'buttonPressCount': _buttonPressCount});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Persistent Button Counter')),
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
                  Text(
                    "Button pressed $_buttonPressCount times",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: incrementButtonPressCount,
                    child: Text('Press Me'),
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
