import 'package:VenueVerse/pages/Home.dart';
import 'package:VenueVerse/components/Colors.dart';
import 'package:VenueVerse/pages/Home.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';

import '../components/Colors.dart';

class userdetails extends StatefulWidget {
  const userdetails({super.key});

  @override
  State<userdetails> createState() => _userdetailsState();
}

class _userdetailsState extends State<userdetails> {
  String? selectedDepartment;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("User Details"),
          centerTitle: true,
          backgroundColor: Appcolor.secondgreen,
          foregroundColor: Colors.white,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Fill The Required Details",
                  style: GoogleFonts.ysabeau(
                    letterSpacing: 1.0,
                    color: Appcolor.black,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Name',
                    hintText: 'Enter your Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Register No',
                    hintText: 'Enter your Register No',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Email ID',
                    hintText: 'Enter your email',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: selectedDepartment,
                  items: [
                    DropdownMenuItem(value: "IT", child: Text("IT")),
                    DropdownMenuItem(value: "CSC", child: Text("CSC")),
                    DropdownMenuItem(value: "AI&DS", child: Text("AI&DS")),
                    DropdownMenuItem(value: "EIE", child: Text("EIE")),
                    DropdownMenuItem(value: "EEE", child: Text("EEE")),
                    DropdownMenuItem(value: "ECE", child: Text("ECE")),
                    DropdownMenuItem(value: "CIVIL", child: Text("CIVIL")),
                    DropdownMenuItem(
                        value: "ROBOTICS", child: Text("ROBOTICS")),
                    DropdownMenuItem(value: "Mech", child: Text("Mech")),
                    DropdownMenuItem(value: "AERO", child: Text("AERO")),
                    DropdownMenuItem(value: "CDPD", child: Text("CDPD")),
                    DropdownMenuItem(value: "BME", child: Text("BME")),
                    DropdownMenuItem(value: "NANO", child: Text("NANO")),
                    // Add more departments as needed
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedDepartment = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Department',
                    hintText: 'Select a department',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.rotate,
                          child: Home(),
                          alignment: Alignment.topCenter,
                          isIos: true,
                          duration: Duration(milliseconds: 500),
                        ),
                      );
                    },
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 30.0)),
                      backgroundColor:
                          MaterialStateProperty.resolveWith<Color?>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.pressed)) {
                            return Appcolor.secondgreen.withOpacity(0.8);
                          }
                          return Appcolor.secondgreen;
                        },
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: BorderSide.none,
                        ),
                      ),
                      elevation: MaterialStateProperty.all(5),
                      shadowColor: MaterialStateProperty.all(
                          Colors.grey.withOpacity(0.5)),
                      textStyle: MaterialStateProperty.all(
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                    ),
                    child: Text("Submit"),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
