import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../components/Colors.dart';
import '../components/Custompopup.dart';

class Private extends StatefulWidget {
  @override
  State<Private> createState() => _PrivateState();
}

class _PrivateState extends State<Private> {
  List<Map<String, String>> data = [
    {'email': 'akash.2011003@srec.ac.in', 'department': 'AI&DS'},
    {'email': 'prasath.2011031@srec.ac.in', 'department': 'IT'},
    //... add more entries as required
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Private Access"),
        centerTitle: true,
        backgroundColor: Appcolor.secondgreen,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 5,
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data[index]['email']!,
                          style: GoogleFonts.ysabeau(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          data[index]['department']!,
                          style: GoogleFonts.ysabeau(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                      color: Appcolor.firstgreen,
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => CustomPopupDialog(
                            title: "Select Time",
                            confirmButtonText: "Confirm",
                            onConfirm: (selectedTime) {
                              // Handle the selected time here
                              print("Selected Time: $selectedTime");
                            },
                          ),
                        );
                      }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
