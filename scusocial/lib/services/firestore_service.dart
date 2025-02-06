import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirestoreService {
  late final FirebaseFirestore _firestore;

  FirestoreService({required bool isTesting})
      : _firestore =
            isTesting ? FakeFirebaseFirestore() : FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> getEventsStream() {
    return _firestore.collection('events').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
  }

  Future<void> createEvent(BuildContext context, String userId) async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final locationController = TextEditingController();
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Event Name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    selectedDate = date;
                  }
                },
                child: const Text('Select Date'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) {
                    selectedTime = time;
                  }
                },
                child: const Text('Select Time'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    selectedDate != null &&
                    selectedTime != null &&
                    descriptionController.text.isNotEmpty &&
                    locationController.text.isNotEmpty) {
                  final eventTime = selectedTime!.format(context);

                  await _firestore.collection('events').add({
                    'name': nameController.text,
                    'description': descriptionController.text,
                    'location': locationController.text,
                    'date': Timestamp.fromDate(selectedDate!),
                    'time': eventTime,
                    'creatorId': userId,
                    'accepted': [],
                  });

                  Navigator.pop(context);
                } else {
                  print('Please fill all fields.');
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}
