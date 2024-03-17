import 'package:com.srec.venueverse/components/Colors.dart';
import 'package:com.srec.venueverse/pages/Login.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';

class Getstarted extends StatefulWidget {
  const Getstarted({super.key});

  @override
  State<Getstarted> createState() => _GetstartedState();
}

class _GetstartedState extends State<Getstarted> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                height: height * 0.2,
                width: width * 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Presented by",
                      style: GoogleFonts.ysabeau(
                        letterSpacing: 1.0,
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Dept of AI&DS",
                      style: GoogleFonts.ysabeau(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  ],
                )),
            Container(
              height: height * 0.5,
              child: Lottie.asset('assets/getstarted.json'),
            ),
            Container(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: Text(
                  "Books may guide our path, but passion and purpose give life its worth.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.ysabeau(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Container(
                  width: width * 0.7,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.rotate,
                          child: Login(),
                          alignment: Alignment.topCenter,
                          isIos: true,
                          duration: Duration(milliseconds: 500),
                        ),
                      );
                    },
                    child: Text(
                      "Get Started",
                      style: GoogleFonts.ysabeau(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Appcolor.firstgreen,
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
