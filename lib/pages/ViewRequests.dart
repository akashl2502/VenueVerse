import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../components/Colors.dart';

class Viewrequests extends StatefulWidget {
  const Viewrequests({super.key});

  @override
  State<Viewrequests> createState() => _ViewrequestsState();
}

class _ViewrequestsState extends State<Viewrequests> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text("Booking Status"),
        centerTitle: true,
        backgroundColor: Appcolor.secondgreen,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
          child: SingleChildScrollView(
            // Wrap with SingleChildScrollView
            child: Container(
              width: width,
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
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Set this for the Column
                  children: [
                    // Row for Name and Date
                    Flexible(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Flexible(
                            // Wrap the Text widget with another Flexible
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 5.0),
                              child: Text(
                                'Akash L(2011003) from AIDS is requesting to takeover Mech seminar Hall from 12:30 to 2:20 at 2/2/23',
                                style: GoogleFonts.ysabeau(
                                  fontSize: 19,
                                  height: 2,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 3,

                                textAlign:
                                    TextAlign.center, // Define a max line count
                                overflow: TextOverflow
                                    .ellipsis, // Use ellipsis for overflow
                                softWrap: true, // Enable soft line wrap
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Approval Pending Container
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            // Logic for approve action
                          },
                          icon: Icon(Icons.check),
                          label: Text("Approve"),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white // background color
                              ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {
                            // Logic for decline action
                          },
                          icon: Icon(Icons.close),
                          label: Text("Reject"),
                          style: OutlinedButton.styleFrom(
                              backgroundColor:
                                  Colors.red, // text and icon color
                              side: BorderSide(color: Colors.red),
                              foregroundColor: Colors.white // border color
                              ),
                        ),
                      ],
                    ), // Space between the row and the approval container
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
