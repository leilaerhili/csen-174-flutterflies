// import 'package:flutter/material.dart';
// // have to install dependencies flutter pub add flutter_riverpod
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class ProfileScreen extends ConsumerWidget {
//   const ProfileScreen({super.key, required this.userId,});

//   final String userID;

//   static const routeName = '/profile';

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final myUid = FirebaseAuth.instance.currentUser!.uid;
//     final userInfo = ref.watch(getUserInfoByIdProvider(userId));

//     return userInfo.when(
//       data: (user) {
//         return SafeArea(child: Scaffold(
//           backgroundColor: Colors.white,
//           body: Padding(
//             padding: EdgeInsets.all(10),
//             child: Column(
//               children: [
//                 CircleAvatar(
//                   radius: 50,
//                   backgroundImage: NetworkImage(user.profilePicUrl),
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   user.fullName,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.w400,
//                     fontSize: 21,
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//               ],
//             ),
//           ),
//           ),
//         ),
//       },
//       error: (error, stackTrace) {
//         return ErrorScreen(error: error.toString());
//       },
//       loading: () {
//         return const Loader();
//       },
//     );
//   }
// }
