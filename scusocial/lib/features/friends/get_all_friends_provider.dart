import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scusocial/core/constants/firebase_constants.dart';
import 'package:scusocial/features/user.dart';
import 'package:firebase_auth/firebase_auth.dart';

// have to install dependencies flutter pub add flutter_riverpod
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getAllFriendsProvider = StreamProvider.autoDispose((ref) {
  final myUid = FirebaseAuth.instance.currentUser!.uid;
  
  final controller = StreamController<Iterable<String>>();

  final sub = FirebaseFirestore.instance
      .collection(FirebaseCollectionNames.users)
      .where(FirebaseCollectionNames.uid, isEqualTo: myUid)
      .limit(1)
      .snapshots()
      .listen((snapshot) {

    final userData = snapshot.docs.first;
    final user = UserModel.fromMap(userData.data());
    controller.sink.add(user.friends);
  });

  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });
  return controller.stream;
});
