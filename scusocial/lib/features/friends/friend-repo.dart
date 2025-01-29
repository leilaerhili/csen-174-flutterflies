import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show immutable;
import '../../core/constants/firebase_constants.dart';

@immutable
class FriendRepository {
  final _myUid = FirebaseAuth.instance.currentUser!.uid;
  final _firestore = FirebaseFirestore.instance;

  // Initialize user document
  Future<void> initializeUserDocument(String uid) async {
    final docRef = _firestore.collection(FirebaseCollectionNames.users).doc(uid);
    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      await docRef.set({
        FirebaseFieldNames.uid: uid,
        FirebaseFieldNames.friends: [],
        FirebaseFieldNames.receivedRequests: [],
        FirebaseFieldNames.sentRequests: [],
        FirebaseFieldNames.buttonPressCount: 0, // Default value
      });
    }
  }

  // Send friend request
  Future<String?> sendFriendRequest({
    required String userId,
  }) async {
    try {
      // Add my uid to the other person's received requests
      await _firestore.collection(FirebaseCollectionNames.users).doc(userId).update({
        FirebaseFieldNames.receivedRequests: FieldValue.arrayUnion([_myUid]),
      });
      // Add the other person's uid to my sent requests
      await _firestore.collection(FirebaseCollectionNames.users).doc(_myUid).update({
        FirebaseFieldNames.sentRequests: FieldValue.arrayUnion([userId]),
      });
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // Accept friend request
  Future<String?> acceptFriendRequest({
    required String userId,
  }) async {
    try {
      // Add your uid to the other person's friend list
      await _firestore.collection(FirebaseCollectionNames.users).doc(userId).update({
        FirebaseFieldNames.friends: FieldValue.arrayUnion([_myUid]),
      });
      // Add the other person's id to your own friends list
      await _firestore.collection(FirebaseCollectionNames.users).doc(_myUid).update({
        FirebaseFieldNames.friends: FieldValue.arrayUnion([userId]),
      });
      // Remove the friend request after acceptance
      await removeFriendRequest(userId: userId);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // Remove friend request
  Future<String?> removeFriendRequest({
    required String userId,
  }) async {
    try {
      // Remove my uid from the other person's received requests
      await _firestore.collection(FirebaseCollectionNames.users).doc(userId).update({
        FirebaseFieldNames.receivedRequests: FieldValue.arrayRemove([_myUid]),
      });
      // Remove the other person's uid from my sent requests
      await _firestore.collection(FirebaseCollectionNames.users).doc(_myUid).update({
        FirebaseFieldNames.sentRequests: FieldValue.arrayRemove([userId]),
      });
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // Remove friend
  Future<String?> removeFriend({
    required String userId,
  }) async {
    try {
      // Remove your uid from the other person's friend list
      await _firestore.collection(FirebaseCollectionNames.users).doc(userId).update({
        FirebaseFieldNames.friends: FieldValue.arrayRemove([_myUid]),
      });
      // Remove the other person's id from your own friends list
      await _firestore.collection(FirebaseCollectionNames.users).doc(_myUid).update({
        FirebaseFieldNames.friends: FieldValue.arrayRemove([userId]),
      });
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
