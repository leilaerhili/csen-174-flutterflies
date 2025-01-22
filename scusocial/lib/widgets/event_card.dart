import 'package:flutter/material.dart';

class EventCard extends StatelessWidget {
  final Map<String, dynamic> event;
  final String userId;
  final dynamic firestoreService; // Replace with FirestoreService type

  EventCard({
    required this.event,
    required this.userId,
    required this.firestoreService,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event['name'],
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Date: ${event['date']}'),
            Text('Time: ${event['time']}'),
            SizedBox(height: 8),
            Text('Location: ${event['location']}'),
            SizedBox(height: 8),
            Text('Description: ${event['description']}'),
          ],
        ),
      ),
    );
  }
}
