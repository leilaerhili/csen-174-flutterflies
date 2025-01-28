import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:scusocial/core/constants/firebase_constants.dart';

@immutable
class FriendRepository {
  final _myUid = FirebaseAuth.instance.currentUser!.uid;
  final _firestore = FirebaseFirestore.instance;

  //Send friend request
  Future<String?> sendFriendRequest({
    required String userId,
  }) async {
    try {
      //Add my uid to the other person's received requests
      _firestore.collection(FirebaseCollectionNames.users).doc(userId).update({
        FirebaseFieldNames.receivedRequests: FieldValue.arrayUnion(
          [_myUid],
        ),
      });
      //Add other person's uid inside uid inside my own sent requests
      _firestore.collection(FirebaseCollectionNames.users).doc(_myUid).update({
        FirebaseFieldNames.receivedRequests: FieldValue.arrayUnion(
          [userId],
        ),
      });
      return null;
    } catch(e) {
      return e.toString();
    }
  }

  // Accept friend request
  Future<String?> acceptFriendRequest({
    required String userId,
  }) async {
    try {
      // add your uid to other person's friend list
      await _firestore
      .collection(FirebaseCollectionNames.users)
      .doc(userId)
      .update({
        FirebaseFieldNames.friends: FieldValue.arrayUnion([_myUid])
      });
      //add other person's id inside your own friends list
      await _firestore
      .collection(FirebaseCollectionNames.users)
      .doc(_myUid)
      .update({
        FirebaseFieldNames.friends: FieldValue.arrayUnion([userId])
      });
      // remove sent and received friend requests
      removeFriendRequest(userId: userId);
      return null;
    } catch(e) {
      return e.toString();
    }
  }

  //remove friend request
  Future<String?> removeFriendRequest({
    required String userId,
  }) async {
    try {
      //Add my uid to the other person's received requests
      _firestore.collection(FirebaseCollectionNames.users).doc(userId).update({
        FirebaseFieldNames.receivedRequests: FieldValue.arrayRemove([_myUid]),
        FirebaseFieldNames.sentRequests: FieldValue.arrayRemove([_myUid]),
      });
      //Add other person's uid inside uid inside my own sent requests
      _firestore.collection(FirebaseCollectionNames.users).doc(_myUid).update({
        FirebaseFieldNames.sentRequests: FieldValue.arrayRemove([userId]),
        FirebaseFieldNames.receivedRequests: FieldValue.arrayRemove([userId]),
      });
      return null;
    } catch(e) {
      return e.toString();
    }
  }

  // Remove friend
  Future<String?> removeFriend({
    required String userId,
  }) async {
    try {
      // add your uid to other person's friend list
      await _firestore
      .collection(FirebaseCollectionNames.users)
      .doc(userId)
      .update({
        FirebaseFieldNames.friends: FieldValue.arrayRemove([_myUid])
      });
      //add other person's id inside your own friends list
      await _firestore
      .collection(FirebaseCollectionNames.users)
      .doc(_myUid)
      .update({
        FirebaseFieldNames.friends: FieldValue.arrayRemove([userId])
      });

      return null;
    } catch(e) {
      return e.toString();
    }
  }

}