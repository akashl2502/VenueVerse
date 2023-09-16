import 'package:VenueVerse/components/Bookvenue.dart';
import 'package:VenueVerse/components/Colors.dart';
import 'package:VenueVerse/components/Rooms.dart';
import 'package:VenueVerse/components/Snackbar.dart';
import 'package:VenueVerse/pages/Userdetails.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import '../components/Custompopup.dart';

class Seminarhall extends StatefulWidget {
  const Seminarhall({required this.Selectdate});
  final String Selectdate;

  @override
  State<Seminarhall> createState() => _SeminarhallState();
}

class _SeminarhallState extends State<Seminarhall> {
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
        print(value['Halls']);
        Rooms = value['Halls'];
        _isloading = false;
      });
    }).catchError((e) {
      print(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    print(widget.Selectdate);
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: (Text("Seminar Halls")),
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
                      ); // If there's an error
                    }
                    // else if (!snapshot.hasData ||
                    //     snapshot.data!.docs.isEmpty) {
                    //   return Column(
                    //     children: [Center(child: Text('No data available.'))],
                    //   );
                    // }

                    final orderDocs = snapshot.data;
                    final bookrecord = orderDocs?.data();
                    List<Widget> Bookinglist = [];
                    // print(bookrecord);
                    // for (Map i in Rooms) {
                    //   if (bookrecord!.containsKey(i['uid'])) {
                    //     List timeslot = bookrecord[i['uid']].values.toList();
                    //   }
                    // }

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
                        return Hallrefactor(
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

class Hallrefactor extends StatefulWidget {
  const Hallrefactor(
      {super.key,
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
  final uid;
  final selectdate;
  @override
  State<Hallrefactor> createState() => _HallrefactorState();
}

class _HallrefactorState extends State<Hallrefactor> {
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
                  child: Image.network(
                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ5p9dK3e3YMC-Wpks6xCk_nx47AqtnVasd4Q&usqp=CAU',
                    height: (widget.height * 0.25) * 0.65,
                    width: widget.width,
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
                      width: widget.width * 0.5, // 80% of the width
                      child: Text(
                        widget.name,
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
                          List timeslot = [];
                          for (var i in widget.timeslot) {
                            timeslot.add([i[0], i[1]]);
                          }
                          Picktime_Bookvenue(
                              context: context,
                              name: widget.name,
                              selectdate: widget.selectdate,
                              uid: widget.uid,
                              timeslot: timeslot);
                        },
                        child: Text('Book'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 1.0, vertical: 2.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: BorderSide(width: 1.0, color: Colors.black),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 8.0),
                for (var i in widget.timeslot)
                  Text("${i[2]}(${i[3]}) has booked from ${i[0]} to ${i[1]}")
              ],
            ),
          ),
        ));
  }
}
