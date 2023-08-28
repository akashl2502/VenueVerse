import 'package:VenueVerse/components/Colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import '../components/Colors.dart';
import '../components/Custompopup.dart';

class Labs extends StatefulWidget {
  const Labs({super.key});

  @override
  State<Labs> createState() => _LabsState();
}

class _LabsState extends State<Labs> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: (Text("Labs")),
        centerTitle: true,
        backgroundColor: Appcolor.secondgreen,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 20,
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          'https://www.christenseninstitute.org/wp-content/uploads/2018/06/Computer-lab_800x400.jpg',
                          height: (height * 0.25) * 0.65,
                          width: width,
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
                            width: width * 0.5, // 80% of the width
                            child: Text(
                              'IT lab - 2',
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
                                showDialog(
                                  context: context,
                                  builder: (context) => CustomPopupDialog(
                                    title: "Confirm Action !",
                                    message:
                                        "Are you sure you want to proceed?",
                                    confirmButtonText: "Yes",
                                    showDateTime: true,
                                    onConfirm: () {
                                      final snackBar = SnackBar(
                                        elevation: 0,
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: Colors.transparent,
                                        content: AwesomeSnackbarContent(
                                          title: 'Booking Send',
                                          message:
                                              'Check your mail for the approval',
                                          contentType: ContentType.success,
                                        ),
                                      );

                                      ScaffoldMessenger.of(context)
                                        ..hideCurrentSnackBar()
                                        ..showSnackBar(snackBar);
                                    },
                                  ),
                                );
                              },
                              child: Text('Book'),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 1.0, vertical: 2.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                side:
                                    BorderSide(width: 1.0, color: Colors.black),
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                          height: 8.0), // To provide some space at the bottom.
                    ],
                  ),
                ),
              )),
        ],
      )),
    );
  }
}
