import 'package:VenueVerse/components/Snackbar.dart';
import 'package:VenueVerse/pages/Userdetails.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

int timeOfDayToMinutes(TimeOfDay time) {
  return time.hour * 60 + time.minute;
}

bool isTimeOverlap(timeSlots, TimeOfDay selectedStart, TimeOfDay selectedEnd) {
  int selectedStartMinutes = timeOfDayToMinutes(selectedStart);
  int selectedEndMinutes = timeOfDayToMinutes(selectedEnd);

  for (var slot in timeSlots) {
    int slotStartMinutes = timeOfDayToMinutes(TimeOfDay(
        hour: int.parse(slot[0].split(":")[0]),
        minute: int.parse(slot[0].split(":")[1])));
    int slotEndMinutes = timeOfDayToMinutes(TimeOfDay(
        hour: int.parse(slot[1].split(":")[0]),
        minute: int.parse(slot[1].split(":")[1])));

    if (!(selectedEndMinutes < slotStartMinutes ||
        selectedStartMinutes > slotEndMinutes)) {
      return true;
    }
  }

  return false;
}

Future<void> Picktime_Bookvenue(
    {context, uid, name, selectdate, timeslot}) async {
  TimeOfDay? selectedTime;

  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final now = TimeOfDay.now();
  final startTime = TimeOfDay(hour: 9, minute: 0);
  final endTime = TimeOfDay(hour: 17, minute: 0);

  TimeOfDay? timeS;
  TimeOfDay? timeE;

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Select Start Time"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () async {
                timeS = await showTimePicker(
                  context: context,
                  initialTime: selectedTime ?? now,
                  builder: (BuildContext context, Widget? child) {
                    return MediaQuery(
                      data: MediaQuery.of(context)
                          .copyWith(alwaysUse24HourFormat: false),
                      child: child!,
                    );
                  },
                );

                Navigator.of(context).pop();
              },
              child: Text("Pick Time"),
            ),
          ],
        ),
      );
    },
  );

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Select End Time"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () async {
                timeE = await showTimePicker(
                  context: context,
                  initialTime: selectedTime ?? now,
                  builder: (BuildContext context, Widget? child) {
                    return MediaQuery(
                      data: MediaQuery.of(context)
                          .copyWith(alwaysUse24HourFormat: false),
                      child: child!,
                    );
                  },
                );

                Navigator.of(context).pop();
              },
              child: Text("Pick Time"),
            ),
          ],
        ),
      );
    },
  );

  if (timeS != null && timeE != null) {
    final selectedDateTimeStart = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      timeS!.hour,
      timeS!.minute,
    );

    final selectedDateTimeEnd = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      timeE!.hour,
      timeE!.minute,
    );

    final startDateTime = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      startTime.hour,
      startTime.minute,
    );

    final endDateTime = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      endTime.hour,
      endTime.minute,
    );

    if (selectedDateTimeStart.isBefore(startDateTime) ||
        selectedDateTimeStart.isAfter(endDateTime) ||
        selectedDateTimeEnd.isBefore(startDateTime) ||
        selectedDateTimeEnd.isAfter(endDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please select times between 9 AM and 5 PM."),
        ),
      );
    } else {
      if (isTimeOverlap(timeslot, timeS!, timeE!)) {
        Showsnackbar(
            context: context,
            contentType: ContentType.failure,
            title: "Overlap of slot",
            message: "The selected time overlaps with a restricted time slot.");
      } else {
        var a = timeS!.hour.toString() + ":" + timeS!.minute.toString();
        var b = timeE!.hour.toString() + ":" + timeE!.minute.toString();
        await _firestore.collection("request").add({
          "dor": selectdate,
          'name': userdet['name'],
          'roll': userdet['registerno'],
          'uid': userdet['uid'],
          'FT': a,
          'ET': b,
          'isapproved': 'pending',
          'dept': userdet['dept'],
          'rid': uid,
          'RN': name,
          "timestamp": FieldValue.serverTimestamp()
        }).then((value) {
          Showsnackbar(
              context: context,
              contentType: ContentType.success,
              title: "Requested",
              message: "your request have been send to department Head");
        });
      }
    }
  }
}
