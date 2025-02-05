import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  test('Fake Firestore: Add and Retrieve Events', () async {
    final fakeFirestore = FakeFirebaseFirestore();

    // Add a test event
    await fakeFirestore.collection('events').add({
      'name': 'Test Event',
      'date': Timestamp.now(),
      'time': '10:00 AM',
      'description': 'A test event',
      'location': 'Online',
      'accepted': [],
      'creatorId': 'testUserId',
    });

    // Fetch events
    final snapshot = await fakeFirestore.collection('events').get();

    // Validate
    expect(snapshot.docs.length, 1);
    expect(snapshot.docs.first.data()['name'], 'Test Event');
  });
}
