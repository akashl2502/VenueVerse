import 'package:com.srec.venueverse/Api/Cloudpush.dart';
import 'package:com.srec.venueverse/components/Snackbar.dart';
import 'package:com.srec.venueverse/pages/Userdetails.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

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
    {context,
    uid,
    name,
    selectdate,
    timeslot,
    hname,
    uname,
    dept,
    email,
    reason}) async {
  TimeOfDay? selectedTime;
  bool Confirm = false;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final now = TimeOfDay.now();
  final startTime = TimeOfDay(hour: 9, minute: 0);
  final endTime = TimeOfDay(hour: 17, minute: 0);
  TimeOfDay? timeS;
  TimeOfDay? timeE;
  TextEditingController reasonController = TextEditingController();

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          "Pick Start Time",
          style: GoogleFonts.ysabeau(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
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
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Pick Time",
                      style: GoogleFonts.ysabeau(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Lottie.asset("assets/picktime.json", height: 20),
                    )
                  ]),
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
        title: Text(
          "Pick End Time",
          style: GoogleFonts.ysabeau(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
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
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Pick Time",
                      style: GoogleFonts.ysabeau(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Lottie.asset("assets/picktime.json", height: 20),
                    )
                  ]),
            ),
          ],
        ),
      );
    },
  );

  if (timeS != null &&
      timeE != null &&
      userdet['name'] != null &&
      userdet['registerno'] != null &&
      userdet['uid'] != null &&
      userdet['dept'] != null) {
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
      Showsnackbar(
          context: context,
          contentType: ContentType.failure,
          title: "Restricted Time Slot",
          message: "Please select times between 9 AM and 5 PM.");
      Navigator.pop(context);
    } else {
      if (isTimeOverlap(timeslot, timeS!, timeE!)) {
        Showsnackbar(
            context: context,
            contentType: ContentType.failure,
            title: "Overlap of slot",
            message: "The selected time overlaps with a restricted time slot.");
        Navigator.pop(context);
      } else {
        var a = timeS!.hour.toString() + ":" + timeS!.minute.toString();
        var b = timeE!.hour.toString() + ":" + timeE!.minute.toString();
        if (a.isNotEmpty && b.isNotEmpty) {
          DateTime specificDate = DateTime.parse(selectdate);
          int specificTimestamp = specificDate.millisecondsSinceEpoch;
          await _firestore.collection("request").add({
            "dor": selectdate,
            'name': userdet['name'],
            'roll': userdet['registerno'],
            'uid': userdet['uid'],
            'FT': a,
            'ET': b,
            'isapproved': 'pending',
            'Hdept': dept,
            'dept': userdet['dept'],
            'rid': uid,
            'RN': name,
            'datemill': specificTimestamp,
            'email': email,
            'reason': reason
          }).then((value) {
            Showsnackbar(
                context: context,
                contentType: ContentType.success,
                title: "Requested",
                message: "your request have been send to department Head");
          });
        }
        Navigator.pop(context);
        try {
          String searchitem = dept.toString();
          CollectionReference _cat = _firestore.collection("Admin");
          Query query = _cat.where("dept", isEqualTo: searchitem);
          QuerySnapshot querySnapshot = await query.get();
          final _docData = querySnapshot.docs.map((doc) => doc.data()).toList();
          if (_docData.isNotEmpty) {
            var emailid = (_docData[0] as Map<String, dynamic>)['email'];
            CollectionReference _cat = _firestore.collection("Userdetails");
            Query query = _cat.where("email", isEqualTo: emailid);
            QuerySnapshot querySnapshot = await query.get();

            final temp = querySnapshot.docs.map((doc) => doc.data()).toList();

            if (temp.isNotEmpty) {
              var fcm = (temp[0] as Map<String, dynamic>)['fcm'] ?? "";
              sendPushNotification(
                  email: [emailid],
                  state: 0,
                  registration_token: fcm,
                  title: "New Booking Request",
                  body:
                      "${uname} from ${dept} has requested ${hname} on ${selectdate} between ${a} to ${b} for ${reason}",
                  reason: reason);
            }
          }
        } catch (e) {
          print(e);
        }
      }
    }
  } else if (timeS != null && timeE != null) {
    Showsnackbar(
        context: context,
        contentType: ContentType.warning,
        title: "Network Error",
        message: "please try again later");
  } else {
    Showsnackbar(
        context: context,
        contentType: ContentType.warning,
        title: "Time",
        message: "please enter time for booking");
    Navigator.pop(context);
  }
}
