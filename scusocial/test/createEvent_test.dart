import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scusocial/services/firestore_service.dart' as firestore_service;

void main() {
  test('Fake Firestore: Add and Retrieve Events', () async {
    final fakeFirestore = FakeFirebaseFirestore();
    // create an event page object
    final firestore_service.FirestoreService testfirestoreService =
        firestore_service.FirestoreService(isTesting: true);
    // Add a test event
  BuildContext somecontext  = new BuildContext();
  String someuserId = "testUserId";
  
  testfirestoreService.createEvent(BuildContext somecontext, String someuserId);

    // Fetch events


    final snapshot = await fakeFirestore.collection('events').get();
    expect(actual, matcher)

  });
}
