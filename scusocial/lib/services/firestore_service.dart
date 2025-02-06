import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService({required FirebaseFirestore firestore})
      : _firestore = firestore;

  Future<void> createEvent(
    String name,
    String description,
    String location,
    DateTime date,
    String time,
    String creatorId,
  ) async {
    await _firestore.collection('events').add({
      'name': name,
      'description': description,
      'location': location,
      'date': Timestamp.fromDate(date),
      'time': time,
      'creatorId': creatorId,
      'accepted': [],
    });
  }
}
