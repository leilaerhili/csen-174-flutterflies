import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart'; // For date formatting

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Social Media App',
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

  // Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      setState(() {
        _user = userCredential.user;
      });
    } catch (error) {
      print("Google Sign-In error: $error");
    }
  }

  Future<void> signOutGoogle() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
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
                onPressed: signInWithGoogle,
                child: Text('Sign in with Google'),
              )
            : EventPage(
                user: _user!,
                signOut: signOutGoogle), // Pass signOut function to EventPage
      ),
    );
  }
}

class EventPage extends StatelessWidget {
  final User user;
  final Future<void> Function() signOut;

  EventPage({required this.user, required this.signOut});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${user.displayName}'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _createEvent(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('events').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final events = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    final eventId = event.id;
                    final eventData = event.data() as Map<String, dynamic>;
                    final eventName = eventData['name'];
                    final eventDate = (eventData['date'] as Timestamp).toDate();
                    final acceptedUsers =
                        List<String>.from(eventData['accepted'] ?? []);

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              eventName,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(
                                'Date: ${DateFormat.yMMMd().format(eventDate)}'),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${acceptedUsers.length} accepted'),
                                Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () =>
                                          _respondToEvent(eventId, true),
                                      child: Text('Accept'),
                                    ),
                                    SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () =>
                                          _respondToEvent(eventId, false),
                                      child: Text('Decline'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors
                                            .red, // Correctly set color here
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await signOut(); // Calls the signOut function passed from SignInPage
            },
            child: Text('Sign Out'),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  Colors.blue, // Set color here, previously was 'primary'
            ),
          ),
        ],
      ),
    );
  }

  void _createEvent(BuildContext context) {
    final _nameController = TextEditingController();
    DateTime? _selectedDate;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Create Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Event Name'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  _selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                },
                child: Text('Select Date'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (_nameController.text.isNotEmpty && _selectedDate != null) {
                  await _firestore.collection('events').add({
                    'name': _nameController.text,
                    'date': _selectedDate,
                    'accepted': [],
                  });
                  Navigator.pop(context);
                } else {
                  print("Event name or date is missing!");
                }
              },
              child: Text('Post'),
            ),
          ],
        );
      },
    );
  }

  void _respondToEvent(String eventId, bool accept) async {
    final eventDoc = _firestore.collection('events').doc(eventId);
    final userId = user.uid;

    if (accept) {
      await eventDoc.update({
        'accepted': FieldValue.arrayUnion([userId]),
      });
    } else {
      await eventDoc.update({
        'accepted': FieldValue.arrayRemove([userId]),
      });
    }
  }
}
