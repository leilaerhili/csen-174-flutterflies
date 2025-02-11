import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scusocial/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('Friend Request Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late FirestoreService firestoreService;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      firestoreService = FirestoreService(firestore: fakeFirestore);
    });

    test('Send Friend Request', () async {
      const String senderId = "testSender123";
      const String receiverId = "testReceiver456";

      // Create test users
      await fakeFirestore.collection('users').doc(senderId).set({
        'sentRequests': [],
        'receivedRequests': [],
      });

      await fakeFirestore.collection('users').doc(receiverId).set({
        'sentRequests': [],
        'receivedRequests': [],
      });

      // Send a friend request
      await firestoreService.sendFriendRequest(senderId, receiverId);

      // Fetch updated user data
      final senderSnapshot = await fakeFirestore.collection('users').doc(senderId).get();
      final receiverSnapshot = await fakeFirestore.collection('users').doc(receiverId).get();

      // Verify that the friend request was sent and received correctly
      expect(senderSnapshot.data()?['sentRequests'], contains(receiverId));
      expect(receiverSnapshot.data()?['receivedRequests'], contains(senderId));
    });

    test('Send Friend Request to Non-Existent User', () async {
      const String senderId = "testSender123";
      const String nonExistentUserId = "nonExistentUser456";

      // Create test sender user
      await fakeFirestore.collection('users').doc(senderId).set({
        'sentRequests': [],
        'receivedRequests': [],
      });

      // Attempt to send a friend request to a non-existent user
      expect(
        () async => await firestoreService.sendFriendRequest(senderId, nonExistentUserId),
        throwsException,
      );
    });

  });
}