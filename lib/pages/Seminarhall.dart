import 'package:VenueVerse/components/Colors.dart';
import 'package:VenueVerse/components/Rooms.dart';
import 'package:VenueVerse/components/Snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import '../components/Custompopup.dart';

class Seminarhall extends StatefulWidget {
  const Seminarhall({required this.Selectdate});
  final String Selectdate;

  @override
  State<Seminarhall> createState() => _SeminarhallState();
}

class _SeminarhallState extends State<Seminarhall> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isloading = true;
  List Rooms = [];

  @override
  void initState() {
    Getdata();
    super.initState();
  }

  void Getdata() async {
    await Getrooms(context: context).then((value) {
      setState(() {
        print(value['hall']);
        Rooms = value['hall'];
        _isloading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    print(widget.Selectdate);
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: (Text("Seminar Halls")),
        centerTitle: true,
        backgroundColor: Appcolor.secondgreen,
        foregroundColor: Colors.white,
      ),
      body: _isloading
          ? Center(
              child: CircularProgressIndicator(
              color: Appcolor.firstgreen,
            ))
          : SafeArea(
              child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: StreamBuilder(
                  stream: _firestore.collection('Booking').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                          child: CircularProgressIndicator(
                        color: Appcolor.firstgreen,
                      ));
                    } else if (snapshot.hasError) {
                      return Column(
                        children: [
                          Center(child: Text('Error: ${snapshot.error}'))
                        ],
                      ); // If there's an error
                    }
                    // else if (!snapshot.hasData ||
                    //     snapshot.data!.docs.isEmpty) {
                    //   return Column(
                    //     children: [Center(child: Text('No data available.'))],
                    //   );
                    // }

                    final orderDocs = snapshot.data!.docs;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: Rooms.map((e) {
                        return Hallrefactor(
                            width: width, height: height, name: e.toString());
                      }).toList(),
                    );
                  }),
            )),
    );
  }
}

class Hallrefactor extends StatefulWidget {
  const Hallrefactor(
      {super.key,
      required this.width,
      required this.height,
      required this.name});

  final double width;
  final double height;
  final String name;

  @override
  State<Hallrefactor> createState() => _HallrefactorState();
}

class _HallrefactorState extends State<Hallrefactor> {
  TimeOfDay? selectedTime;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Container(
          width: widget.width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ5p9dK3e3YMC-Wpks6xCk_nx47AqtnVasd4Q&usqp=CAU',
                    height: (widget.height * 0.25) * 0.65,
                    width: widget.width,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(
                    height:
                        8.0), // To provide some space between the image and the row.
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: widget.width * 0.5, // 80% of the width
                      child: Text(
                        widget.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.ysabeau(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: OutlinedButton(
                        onPressed: () {
                          _pickTime();
                          // showDialog(
                          //   context: context,
                          //   builder: (context) => CustomPopupDialog(
                          //     title: "Select Time",
                          //     confirmButtonText: "Confirm",
                          //     onConfirm: (selectedTime) {
                          //       // Handle the selected time here
                          //       print("Selected Time: $selectedTime");
                          //     },
                          //   ),
                          // );
                        },
                        child: Text('Book'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 1.0, vertical: 2.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: BorderSide(width: 1.0, color: Colors.black),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 8.0), // To provide some space at the bottom.
              ],
            ),
          ),
        ));
  }

  _pickTime() async {
    final now = TimeOfDay.now();
    final startTime = TimeOfDay(hour: 9, minute: 0);
    final endTime = TimeOfDay(hour: 17, minute: 0);

    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? now,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (time != null) {
      final selectedDateTime = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        time.hour,
        time.minute,
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

      if (selectedDateTime.isBefore(startDateTime) ||
          selectedDateTime.isAfter(endDateTime)) {
        // Show an error message or inform the user that the selected time is outside the allowed range.
        // You can use a SnackBar or AlertDialog for this purpose.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Please select a time between 9 AM and 5 PM."),
          ),
        );
      } else {
        setState(() {
          // selectedTime = time;
        });
      }
    }
  }
}
