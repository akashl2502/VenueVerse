import 'package:VenueVerse/Api/Cloudpush.dart';
import 'package:VenueVerse/components/Snackbar.dart';
import 'package:VenueVerse/pages/Userdetails.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/v4.dart';
import '../components/Colors.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class Pastviewrequests extends StatefulWidget {
  const Pastviewrequests({super.key});

  @override
  State<Pastviewrequests> createState() => _PastviewrequestsState();
}

class _PastviewrequestsState extends State<Pastviewrequests> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text("Past Booking Status"),
        centerTitle: true,
        backgroundColor: Appcolor.secondgreen,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
          child: SingleChildScrollView(
            child: SafeArea(
                child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: StreamBuilder(
                  stream: _firestore
                      .collection('request')
                      .where('dept', isEqualTo: userdet['dept'])
                      .orderBy('datemill', descending: true)
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

                    final orderDocs = snapshot.data!.docs;
                    List<Widget> Reqcard = [];
                    for (var doc in orderDocs) {
                      Reqcard.add(Requestcard(
                          width: width, data: doc.data(), docid: doc.id));
                    }
                    return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: Reqcard);
                  }),
            )),
          ),
        ),
      ),
    );
  }
}

class Requestcard extends StatefulWidget {
  const Requestcard(
      {super.key,
      required this.width,
      required this.data,
      required this.docid});

  final double width;
  final data;
  final docid;

  @override
  State<Requestcard> createState() => _RequestcardState();
}

class _RequestcardState extends State<Requestcard> {
  @override
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.only(bottom: 20),
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
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 5.0),
                      child: Text(
                        '${widget.data['name']}(${widget.data['roll']}) from ${widget.data['dept']} is requesting to takeover ${widget.data['RN']} from ${widget.data['FT']} to ${widget.data['ET']} at ${widget.data['dor']} because ${widget.data['reason']}',
                        style: GoogleFonts.ysabeau(
                          fontSize: 19,
                          height: 2,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 10,
                        textAlign: TextAlign.center,
                        overflow:
                            TextOverflow.ellipsis, // Use ellipsis for overflow
                        // Remove or set softWrap to false
                        // softWrap: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Approval Pending Container

            Container(
              width: width * 0.8,
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: widget.data['isapproved'] == 'pending'
                    ? Colors.orangeAccent
                    : widget.data['isapproved'] == 'Approved'
                        ? Colors.greenAccent
                        : Colors.red,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                widget.data['isapproved'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
