import 'package:VenueVerse/components/Bookvenue.dart';
import 'package:VenueVerse/components/Colors.dart';
import 'package:VenueVerse/components/Rooms.dart';
import 'package:VenueVerse/pages/Peekinside.dart';
import 'package:VenueVerse/pages/Userdetails.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import '../components/Colors.dart';
import '../components/Custompopup.dart';

class Labs extends StatefulWidget {
  const Labs({required this.Selectdate});
  final String Selectdate;
  @override
  State<Labs> createState() => _LabsState();
}

class _LabsState extends State<Labs> {
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
        print(value['Labs']);
        Rooms = value['Labs'];
        _isloading = false;
      });
    });
  }

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
      body: _isloading
          ? Center(
              child: CircularProgressIndicator(
              color: Appcolor.firstgreen,
            ))
          : SafeArea(
              child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: StreamBuilder(
                  stream: _firestore
                      .collection('Booking')
                      .doc(widget.Selectdate)
                      .snapshots(),
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
                      );
                    }

                    final orderDocs = snapshot.data;
                    final bookrecord = orderDocs?.data();
                    List<Widget> Bookinglist = [];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: Rooms.map((e) {
                        List timeslot = [];
                        if (bookrecord != null && bookrecord.isNotEmpty) {
                          if (bookrecord.containsKey(e['uid'])) {
                            timeslot = bookrecord[e['uid']].values.toList();
                          }
                        }
                        return Labsrefactor(
                          dept: e['dept'],
                          width: width,
                          height: height,
                          name: e['name'],
                          selectdate: widget.Selectdate,
                          uid: e['uid'],
                          timeslot: timeslot,
                        );
                      }).toList(),
                    );
                  }),
            )),
    );
  }
}

class Labsrefactor extends StatefulWidget {
  const Labsrefactor(
      {super.key,
      required this.dept,
      required this.width,
      required this.height,
      required this.name,
      required this.selectdate,
      required this.uid,
      required this.timeslot});
  final List timeslot;
  final double width;
  final double height;
  final String name;
  final dept;
  final uid;
  final selectdate;
  @override
  State<Labsrefactor> createState() => _LabsrefactorState();
}

class _LabsrefactorState extends State<Labsrefactor> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    print(widget.timeslot);
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
                  child: Image.asset(
                    "assets/labs.jpg",
                    height: (widget.height * 0.25) * 0.65,
                    width: widget.width,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(
                    height:
                        8.0), // To provide some space between the image and the row.
                Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: widget.width *0.8, // 80% of the width
                          child: Text(
                            widget.name,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.ysabeau(
                                fontSize: 23,
                                fontWeight: FontWeight.bold,
                                textBaseline: TextBaseline.ideographic),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: OutlinedButton(
                              onPressed: () {
                                List timeslot = [];
                                for (var i in widget.timeslot) {
                                  timeslot.add([i[0], i[1]]);
                                }
                                Picktime_Bookvenue(
                                    dept: widget.dept,
                                    context: context,
                                    name: widget.name,
                                    selectdate: widget.selectdate,
                                    uid: widget.uid,
                                    timeslot: timeslot,
                                    hname: widget.name,
                                    uname: userdet['name']);
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
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            Peekinside(list: widget.timeslot)));
                              },
                              child: Text('Peek Inside'),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 2.0),
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
                    )
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
