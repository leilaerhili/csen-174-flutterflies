import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import calendar servcie
import '../services/calendar_service.dart';

class EventPage extends StatelessWidget {
  final User user;
  final Future<void> Function() signOut;

  EventPage({required this.user, required this.signOut});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${user.displayName}'),
        leading: IconButton(
          icon: Icon(Icons.calendar_today),
          onPressed: () => _showCalendarSubscriptionLink(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _createEvent(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('events').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final events = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    final eventId = event.id;
                    final eventData = event.data() as Map<String, dynamic>;
                    final eventName = eventData['name'];
                    final eventDate = (eventData['date'] as Timestamp).toDate();
                    final eventTime = eventData['time'];
                    final eventDescription = eventData['description'];
                    final eventLocation = eventData['location'];
                    final acceptedUsers =
                        List<String>.from(eventData['accepted'] ?? []);
                    final eventCreatorId = eventData['creatorId'];

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              eventName,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text('Date: ${eventDate.toLocal()}'),
                            Text('Time: $eventTime'),
                            SizedBox(height: 8),
                            Text('Location: $eventLocation'),
                            SizedBox(height: 8),
                            Text('Description: $eventDescription'),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${acceptedUsers.length} accepted'),
                                Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () =>
                                          _respondToEvent(eventId, true),
                                      child: Text('Accept'),
                                    ),
                                    SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () =>
                                          _respondToEvent(eventId, false),
                                      child: Text('Decline'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                                if (user.uid == eventCreatorId)
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () =>
                                        _deleteEvent(eventId, context),
                                    color: Colors.red,
                                  ),
                              ],
                            ),
                            SizedBox(height: 16),
                            GestureDetector(
                              onTap: () =>
                                  _goToEventDetailsPage(context, eventId),
                              child: Text(
                                'View Comments',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: signOut,
            child: Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  /// Fetch and show the user's calendar subscription link
  void _showCalendarSubscriptionLink(BuildContext context) async {
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final calendarId = doc.data()?['calendarId'];
      print('Calendar ID: $calendarId');
      if (calendarId == null || calendarId == 'none') {
        _showDialog(context, 'No Calendar Found',
            'You do not have a calendar set up yet.');
        return;
      }

      final iCalLink =
          "https://calendar.google.com/calendar/ical/$calendarId/public/basic.ics";

      _showDialog(
        context,
        'Subscribe to Your Calendar',
        'To subscribe to your events:\n\n'
            '1️⃣ Open **Google Calendar**\n'
            '2️⃣ Click on **"Other calendars"** in the left panel\n'
            '3️⃣ Select **"From URL"**\n'
            '4️⃣ Paste this link:\n\n'
            '**$iCalLink**\n\n'
            '5️⃣ Click **"Add calendar"** ✅\n\n'
            'Your events will now automatically sync!',
      );
    } catch (e) {
      _showDialog(context, 'Error', 'Failed to retrieve calendar link.');
    }
  }

  /// Show a dialog with information
  void _showDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SelectableText(message), // Allows copying the link
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _createEvent(BuildContext context) {
    final _nameController = TextEditingController();
    final _descriptionController = TextEditingController();
    final _locationController = TextEditingController();
    DateTime? _selectedDate;
    TimeOfDay? _selectedTime;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Create Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Event Name'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'Location'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  _selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                },
                child: Text('Select Date'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  _selectedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                },
                child: Text('Select Time'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (_nameController.text.isNotEmpty &&
                    _selectedDate != null &&
                    _selectedTime != null &&
                    _descriptionController.text.isNotEmpty &&
                    _locationController.text.isNotEmpty) {
                  final eventTime = _selectedTime!.format(context);

                  await _firestore.collection('events').add({
                    'name': _nameController.text,
                    'date': _selectedDate,
                    'time': eventTime,
                    'description': _descriptionController.text,
                    'location': _locationController.text,
                    'accepted': [],
                    'creatorId': user.uid,
                  });

                  Navigator.pop(context);
                } else {
                  print("Please fill out all fields!");
                }
              },
              child: Text('Post'),
            ),
          ],
        );
      },
    );
  }

  void _respondToEvent(String eventId, bool accept) async {
    final eventDoc = _firestore.collection('events').doc(eventId);
    final userId = user.uid;

    if (accept) {
      await eventDoc.update({
        'accepted': FieldValue.arrayUnion([userId]),
      });

      // Fetch event details
      final eventSnapshot = await eventDoc.get();
      final eventData = eventSnapshot.data();
      if (eventData == null) return;

      final eventName = eventData['name'];
      final eventDescription = eventData['description'];
      final eventLocation = eventData['location'];
      final eventDate = (eventData['date'] as Timestamp).toDate();
      final eventTime = eventData['time'];

      final eventStartTime = _parseEventTime(eventDate, eventTime);
      final eventEndTime = eventStartTime.add(Duration(hours: 1));

      final userDoc = await _firestore.collection('users').doc(userId).get();
      final calendarId = userDoc.data()?['calendarId'];
      if (calendarId == null) return;

      final calendarService = CalendarService();
      final gcalEventId = await calendarService.addEventToPrivateCalendar(
        calendarId,
        eventName,
        eventStartTime,
        eventEndTime,
      );

      // 🔹 Store the mapping (local event ID → Google Calendar event ID)
      await _firestore.collection('users').doc(userId).update({
        'gcalEventMappings.$eventId': gcalEventId,
      });
    } else {
      await eventDoc.update({
        'accepted': FieldValue.arrayRemove([userId]),
      });

      // 🔹 Retrieve the gcalEventId
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final calendarId = userDoc.data()?['calendarId'];
      final gcalEventId = userDoc.data()?['gcalEventMappings']?[eventId];

      if (calendarId != null && gcalEventId != null) {
        final calendarService = CalendarService();
        await calendarService.removeEventFromPrivateCalendar(
            calendarId, gcalEventId);

        // 🔹 Remove the mapping after deletion
        await _firestore.collection('users').doc(userId).update({
          'gcalEventMappings.$eventId': FieldValue.delete(),
        });
      }
    }
  }

  /// Helper function to parse time string into DateTime
  DateTime _parseEventTime(DateTime eventDate, String eventTime) {
    final timeParts = eventTime.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1].split(' ')[0]);
    final isPM = eventTime.toLowerCase().contains('pm');

    return DateTime(
      eventDate.year,
      eventDate.month,
      eventDate.day,
      isPM ? (hour % 12) + 12 : hour,
      minute,
    );
  }

  void _deleteEvent(String eventId, BuildContext context) async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Event'),
        content: Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: Text('Delete'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmation == true) {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final calendarId = userDoc.data()?['calendarId'];
      final gcalEventId = userDoc.data()?['gcalEventMappings']?[eventId];

      if (calendarId != null && gcalEventId != null) {
        final calendarService = CalendarService();
        await calendarService.removeEventFromPrivateCalendar(
            calendarId, gcalEventId);

        // Remove mapping from Firestore
        await _firestore.collection('users').doc(user.uid).update({
          'gcalEventMappings.$eventId': FieldValue.delete(),
        });
      }

      await _firestore.collection('events').doc(eventId).delete();
    }
  }

  void _goToEventDetailsPage(BuildContext context, String eventId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailsPage(eventId: eventId, user: user),
      ),
    );
  }
}

class EventDetailsPage extends StatelessWidget {
  final String eventId;
  final User user;

  EventDetailsPage({required this.eventId, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _CommentSection(eventId: eventId, user: user),
          ),
        ],
      ),
    );
  }
}

class _CommentSection extends StatefulWidget {
  final String eventId;
  final User user;

  _CommentSection({required this.eventId, required this.user});

  @override
  __CommentSectionState createState() => __CommentSectionState();
}

class __CommentSectionState extends State<_CommentSection> {
  final _commentController = TextEditingController();

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown time';
    final dateTime = timestamp.toDate();
    return '${dateTime.toLocal()}'
        .split('.')[0]; // Format as "YYYY-MM-DD HH:MM:SS"
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('events')
              .doc(widget.eventId)
              .collection('comments')
              .orderBy('timestamp')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            final comments = snapshot.data!.docs;
            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index].data() as Map<String, dynamic>;
                final userName = comment['userName'] ?? 'Anonymous';
                final message = comment['message'] ?? '[No message]';
                final timestamp = comment['timestamp'] as Timestamp?;

                return ListTile(
                  title: Text('$userName (${_formatTimestamp(timestamp)})'),
                  subtitle: Text(message),
                );
              },
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(labelText: 'Write a comment...'),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () async {
                  final commentText = _commentController.text;
                  if (commentText.isNotEmpty) {
                    await FirebaseFirestore.instance
                        .collection('events')
                        .doc(widget.eventId)
                        .collection('comments')
                        .add({
                      'userName': widget.user.displayName ?? 'Anonymous',
                      'message':
                          commentText.isNotEmpty ? commentText : '[No message]',
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
  }
}
