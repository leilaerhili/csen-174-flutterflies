import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class EventDetailsPage extends StatefulWidget {
  final String eventId;
  final User user;

  EventDetailsPage({required this.eventId, required this.user});

  @override
  _EventDetailsPageState createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: _firestore
                  .collection('events')
                  .doc(widget.eventId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final event = snapshot.data!;
                final eventData = event.data() as Map<String, dynamic>;
                final eventName = eventData['name'];
                final eventDate = (eventData['date'] as Timestamp).toDate();
                final eventTime = eventData['time'];
                final eventDescription = eventData['description'];
                final eventLocation = eventData['location'];

                return ListView(
                  padding: EdgeInsets.all(8),
                  children: [
                    Text(
                      eventName,
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text('Date: ${eventDate.toLocal()}'),
                    Text('Time: $eventTime'),
                    Text('Location: $eventLocation'),
                    Text('Description: $eventDescription'),
                    SizedBox(height: 16),
                    Text('Comments:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('events')
                          .doc(widget.eventId)
                          .collection('comments')
                          .orderBy('timestamp')
                          .snapshots(),
                      builder: (context, commentSnapshot) {
                        if (!commentSnapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }

                        final comments = commentSnapshot.data!.docs;
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: comments.length,
                          itemBuilder: (context, index) {
                            final comment =
                                comments[index].data() as Map<String, dynamic>;
                            final userName = comment['userName'] ??
                                'Anonymous'; // Default to 'Anonymous'
                            final message = comment['message'] ??
                                '[No message]'; // Default message if missing
                            final timestamp =
                                comment['timestamp'] as Timestamp?;
                            final formattedTime = timestamp != null
                                ? DateFormat.yMMMd()
                                    .add_jm()
                                    .format(timestamp.toDate())
                                : 'Unknown time';

                            return ListTile(
                              title: Text('$userName • $formattedTime'),
                              subtitle: Text(message),
                            );
                          },
                        );
                      },
                    ),
                    SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              decoration: InputDecoration(
                                  labelText: 'Write a comment...'),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.send),
                            onPressed: () async {
                              final commentText = _commentController.text;
                              if (commentText.isNotEmpty) {
                                await _firestore
                                    .collection('events')
                                    .doc(widget.eventId)
                                    .collection('comments')
                                    .add({
                                  'userName':
                                      widget.user.displayName ?? 'Anonymous',
                                  'message': commentText,
                                  'timestamp': FieldValue.serverTimestamp(),
                                });
                                _commentController.clear();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
