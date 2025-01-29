import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class CalendarService {
  final _scopes = [CalendarApi.calendarScope];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<CalendarApi> _getCalendarApi() async {
    // Load the service account credentials
    final credentialsJson =
        await rootBundle.loadString('lib/utils/herd-aad12-3331e59ffa37.json');
    final credentials =
        auth.ServiceAccountCredentials.fromJson(credentialsJson);

    // Authenticate with the service account
    final client = await auth.clientViaServiceAccount(credentials, _scopes);

    // Return the Calendar API instance
    return CalendarApi(client);
  }

  // Create a new private calendar
  Future<String> _createCalendar(String userEmail) async {
    final calendarApi = await _getCalendarApi();

    // Create the calendar
    final calendar = Calendar()
      ..summary = "Private Events for $userEmail"
      ..timeZone = "UTC"; // Set default timezone

    final createdCalendar = await calendarApi.calendars.insert(calendar);
    final calendarId = createdCalendar.id!;

    // 🔹 Grant the user access to the calendar
    final aclRule = AclRule()
      ..scope = (AclRuleScope()
        ..type = "user"
        ..value = userEmail)
      ..role =
          "reader"; // User can read events, change to "writer" if they need to add events

    await calendarApi.acl.insert(aclRule, calendarId);

    return calendarId;
  }

  // Get the iCal subscription link
  String _getICalSubscriptionLink(String calendarId) {
    return "https://calendar.google.com/calendar/ical/$calendarId/public/basic.ics";
  }

  // Ensure the user has a calendar, and return the subscription link
  Future<String> ensureUserHasCalendar(String userId, String userEmail) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();

    String calendarId;

    if (userDoc.exists &&
        userDoc.data()?['calendarLink'] != null &&
        userDoc.data()?['calendarLink'] != "None") {
      calendarId = userDoc.data()?['calendarId']; // Use existing calendar
    } else {
      // Create a new private calendar for the user
      calendarId = await _createCalendar(userEmail);

      // Save it to Firestore
      await _firestore.collection('users').doc(userId).set({
        'calendarId': calendarId,
        'calendarLink': _getICalSubscriptionLink(calendarId),
      }, SetOptions(merge: true));
    }

    return _getICalSubscriptionLink(calendarId);
  }

  // Add an event to the user's private calendar
  Future<void> addEventToPrivateCalendar(
      String calendarId, String summary, DateTime start, DateTime end) async {
    final calendarApi = await _getCalendarApi();
    final event = Event()
      ..summary = summary
      ..start = EventDateTime(dateTime: start.toUtc())
      ..end = EventDateTime(dateTime: end.toUtc());

    await calendarApi.events.insert(event, calendarId);
  }
}
