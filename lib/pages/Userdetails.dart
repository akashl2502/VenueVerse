import 'dart:io';

import 'package:VenueVerse/components/Snackbar.dart';
import 'package:VenueVerse/pages/Home.dart';
import 'package:VenueVerse/components/Colors.dart';
import 'package:VenueVerse/pages/Home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';

import '../components/Colors.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

Map userdet = {};

class userdetails extends StatefulWidget {
  const userdetails({required this.uid, required this.email});
  final uid;
  final email;
  @override
  State<userdetails> createState() => _userdetailsState();
}

class _userdetailsState extends State<userdetails> {
  @override
  void initState() {
    Checkuser(uid: widget.uid);
    _Emailcon.text = widget.email;
    super.initState();
  }

  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List dept = [
    'IT',
    'CSC',
    "AI&DS",
    "EIE",
    "EEE",
    "ECE",
    "CIVIL",
    "Mech",
    "AERO",
    "CDPD",
    "BME",
    "NANO"
  ];
  TextEditingController _namecon = TextEditingController();
  TextEditingController _Registercon = TextEditingController();

  TextEditingController _Emailcon = TextEditingController();
  Future<void> Checkuser({required uid}) async {
    setState(() {
      _isloading = true;
    });
    try {
      CollectionReference _cat = _firestore.collection("Userdetails");
      Query query = _cat.where("uid", isEqualTo: widget.uid);
      QuerySnapshot querySnapshot = await query.get();

      final _docData = querySnapshot.docs.map((doc) => doc.data()).toList();
      print(_docData);
      if (_docData.isNotEmpty) {
        userdet = _docData[0] as Map;
        Navigator.pushReplacement(
          context,
          PageTransition(
            type: PageTransitionType.rotate,
            child: Home(uid: widget.uid),
            alignment: Alignment.topCenter,
            isIos: true,
            duration: Duration(milliseconds: 500),
          ),
        );
      } else {
        setState(() {
          _isloading = false;
        });
      }
    } catch (e) {
      Showsnackbar(
          context: context,
          contentType: ContentType.failure,
          title: "Error",
          message: "Someting has occured please contant admin");
      print(e);
    }
  }

  String selectedDepartment = "IT";
  bool _isloading = false;
  Future<void> pushdata() async {
    setState(() {
      _isloading = true;
    });
    try {
      print(_namecon.text);
      if (_namecon.text.trim().isNotEmpty &&
          _Registercon.text.trim().isNotEmpty &&
          _Emailcon.text.trim().isNotEmpty &&
          selectedDepartment.trim().isNotEmpty) {
        var data = {
          "name": _namecon.text.trim(),
          "registerno": _Registercon.text.trim(),
          "email": _Emailcon.text.trim(),
          "dept": selectedDepartment.trim(),
          "uid": widget.uid
        };
        await _firestore.collection("Userdetails").add(data).then((e) {
          Navigator.pushReplacement(
            context,
            PageTransition(
              type: PageTransitionType.rotate,
              child: Home(uid: widget.uid),
              alignment: Alignment.topCenter,
              isIos: true,
              duration: Duration(milliseconds: 500),
            ),
          );
        });
      }
    } catch (e) {
      setState(() {
        _isloading = false;
      });
      Showsnackbar(
          context: context,
          contentType: ContentType.failure,
          title: "User Details",
          message: "Error while updating user details");
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isloading
        ? Center(
            child: CircularProgressIndicator(
              color: Appcolor.firstgreen,
            ),
          )
        : Scaffold(
            resizeToAvoidBottomInset: false,
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
                      controller: _namecon,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        hintText: 'Enter your Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _Registercon,
                      decoration: InputDecoration(
                        labelText: 'Register No',
                        hintText: 'Enter your Register No',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _Emailcon,
                      enabled: false,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email ID',
                        hintText: 'Enter your email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: selectedDepartment,
                      items: dept.map((e) {
                        return DropdownMenuItem(
                            value: e.toString(), child: Text(e.toString()));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedDepartment = value.toString();
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
                          pushdata();
                        },
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all(
                              EdgeInsets.symmetric(
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
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              side: BorderSide.none,
                            ),
                          ),
                          elevation: MaterialStateProperty.all(5),
                          shadowColor: MaterialStateProperty.all(
                              Colors.grey.withOpacity(0.5)),
                          textStyle: MaterialStateProperty.all(TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                          foregroundColor:
                              MaterialStateProperty.all(Colors.white),
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
