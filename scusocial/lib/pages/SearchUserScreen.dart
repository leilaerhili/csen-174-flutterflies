import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../friends/friend-repo.dart'; // Make sure to use the correct path to your FriendRepository

class SearchUserScreen extends StatefulWidget {
  const SearchUserScreen({Key? key}) : super(key: key);

  @override
  _SearchUserScreenState createState() => _SearchUserScreenState();
}

class _SearchUserScreenState extends State<SearchUserScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;

  // Function to search users by `uid`
  void _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Query Firestore for users whose `uid` matches or starts with the search input
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('uid', isGreaterThanOrEqualTo: query)
          .where('uid', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      setState(() {
        _searchResults = snapshot.docs.map((doc) {
          return doc.data() as Map<String, dynamic>;
        }).toList();
      });
    } catch (e) {
      print("Error during search: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Users'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by UID',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onChanged: (query) {
                _searchUsers(query); // Trigger search on text change
              },
            ),
            const SizedBox(height: 20),

            // Show loading indicator
            if (_isLoading) const CircularProgressIndicator(),

            // Display search results
            Expanded(
              child: _searchResults.isEmpty
                  ? const Center(child: Text('No results found'))
                  : ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final user = _searchResults[index];
                        return ListTile(
                          title: Text(user['uid'] ?? 'No UID'),
                          subtitle: Text(
                            'Friends: ${user['friends']?.length ?? 0}', // Show number of friends
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.person_add),
                            onPressed: () async {
                              // Send friend request using FriendRepository
                              final friendRepo = FriendRepository();
                              final result = await friendRepo.sendFriendRequest(
                                userId: user['uid'],
                              );
                              if (result == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Friend request sent!')),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $result')),
                                );
                              }
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
