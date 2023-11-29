import 'package:VenueVerse/components/Colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Peekinside extends StatefulWidget {
  const Peekinside({super.key, required this.list});
  final List list;

  @override
  State<Peekinside> createState() => _PeekinsideState();
}

class _PeekinsideState extends State<Peekinside> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Private Access"),
        centerTitle: true,
        backgroundColor: Appcolor.secondgreen,
        foregroundColor: Colors.white,
      ),
      body: widget.list.length == 0
          ? Center(
              child: Text(
              "No Booking",
              style: GoogleFonts.ysabeau(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ))
          : SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: widget.list
                    .map((data) => Peekinsidecard(
                          ft: data[0],
                          name: data[2],
                          roll: data[3],
                          tt: data[1],
                        ))
                    .toList(),
              ),
            ),
    );
  }
}

class Peekinsidecard extends StatelessWidget {
  const Peekinsidecard(
      {required this.roll,
      required this.ft,
      required this.name,
      required this.tt});
  final name;
  final roll;
  final ft;
  final tt;
  @override
  Widget build(BuildContext context) {
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
                    "${name} - ${roll}",
                    style: GoogleFonts.ysabeau(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        "Start Time - ${ft}",
                        style: GoogleFonts.ysabeau(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        "End Time - ${tt}",
                        style: GoogleFonts.ysabeau(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
