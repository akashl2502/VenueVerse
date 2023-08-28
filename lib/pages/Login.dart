import 'package:VenueVerse/components/Colors.dart';
import 'package:VenueVerse/pages/Userdetails.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
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
              height: height * 0.25,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Bringing convenience to campus, Book the perfect hall for your events in just a few taps!",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.ysabeau(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )),
          SizedBox(
            height: 5,
          ),
          Container(
            child: Lottie.asset('assets/login.json', fit: BoxFit.cover),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 47),
              child: Container(
                width: width * 1,
                decoration: ShapeDecoration(
                  color: Appcolor.secondgreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      topRight: Radius.circular(30.0),
                    ),
                  ),
                ),
                child: Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.rotate,
                          child: userdetails(),
                          alignment: Alignment.topCenter,
                          isIos: true,
                          duration: Duration(milliseconds: 500),
                        ),
                      );
                    },
                    icon: Image.network(
                      'https://www.freepnglogos.com/uploads/google-logo-png/google-logo-png-webinar-optimizing-for-success-google-business-webinar-13.png',
                      height: 34.0,
                    ),
                    label: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        'Sign in with Google',
                        style: GoogleFonts.ysabeau(
                          letterSpacing: 1.0,
                          color: Appcolor.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Appcolor.black,
                      padding: EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 15.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      )),
    );
  }
}
