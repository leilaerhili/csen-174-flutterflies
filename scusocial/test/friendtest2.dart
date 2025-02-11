import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scusocial/features/friends/friend-repo.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;
  late FriendRepository friendRepo;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth(
        signedIn: true, mockUser: MockUser(uid: 'testUser123'));
    friendRepo = FriendRepository(auth: mockAuth, firestore: fakeFirestore);
  });

  test('Initialize user document if it does not exist', () async {
    final userId = 'newUser456';
    await friendRepo.initializeUserDocument(userId);

    final userDoc = await fakeFirestore.collection('users').doc(userId).get();
    expect(userDoc.exists, true);
    expect(userDoc.data(), {
      'uid': userId,
      'friends': [],
      'receivedRequests': [],
      'sentRequests': [],
      'buttonPressCount': 0,
    });
  });

  test('Send a friend request', () async {
    final targetUserId = 'friend456';

    await friendRepo.sendFriendRequest(userId: targetUserId);

    final receiverDoc =
        await fakeFirestore.collection('users').doc(targetUserId).get();
    final senderDoc = await fakeFirestore
        .collection('users')
        .doc(mockAuth.currentUser!.uid)
        .get();

    expect(receiverDoc.data()?['receivedRequests'], contains('testUser123'));
    expect(senderDoc.data()?['sentRequests'], contains(targetUserId));
  });
}
