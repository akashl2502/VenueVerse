import 'package:com.srec.venueverse/components/Colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Aboutpage extends StatefulWidget {
  const Aboutpage({super.key});

  @override
  State<Aboutpage> createState() => _AboutpageState();
}

class _AboutpageState extends State<Aboutpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About"),
        backgroundColor: Appcolor.secondgreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'assets/venue.png',
              height: MediaQuery.of(context).size.height / 4,
              width: MediaQuery.of(context).size.width,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'VenueVerse, an innovative initiative by the Department of Artificial Intelligence and Data Science, streamlines the venue booking process for professors. This user-friendly platform allows convenient and timely venue reservations, replacing intricate paper-based methods with efficient digital solutions.',
                style: GoogleFonts.ysabeau(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    textBaseline: TextBaseline.ideographic),
                textAlign: TextAlign.justify,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Developed By',
                style: GoogleFonts.ysabeau(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    textBaseline: TextBaseline.ideographic),
                textAlign: TextAlign.start,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                '• Prasath S (2011031)',
                style: GoogleFonts.ysabeau(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    textBaseline: TextBaseline.ideographic),
                textAlign: TextAlign.start,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                '• Akash L (2011003)',
                style: GoogleFonts.ysabeau(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    textBaseline: TextBaseline.ideographic),
                textAlign: TextAlign.start,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
